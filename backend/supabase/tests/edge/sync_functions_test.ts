import { createClient } from "jsr:@supabase/supabase-js@2";

const baseUrl = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const serviceRoleKey = requireTestEnv("SUPABASE_SERVICE_ROLE_KEY");
const authApiKey = Deno.env.get("SUPABASE_ANON_KEY") ?? serviceRoleKey;

Deno.test("sync-pull returns ordered signal events", async () => {
  const fixture = await createFixture();

  const firstPage = await postJson(fixture.session, "sync-pull", {
    afterCursor: 0,
    limit: 1,
  });

  assertEquals(firstPage.hasMore, true);
  const firstEvents = arrayValue(firstPage, "events");
  assertEquals(firstEvents.length, 1);
  assertEquals(
    objectValue(firstEvents[0], "entityIds").captureId,
    fixture.captureId,
  );

  const secondPage = await postJson(fixture.session, "sync-pull", {
    afterCursor: numberValue(firstPage, "cursor"),
    limit: 10,
  });

  assertEquals(secondPage.hasMore, false);
  assertEquals(secondPage.requiresBootstrap, false);
  assertEquals(arrayValue(secondPage, "events").length, 1);
  assertEquals(arrayValue(secondPage, "events")[0].type, "dish.upsert");
});

Deno.test("get-captures returns captures and missing ids", async () => {
  const fixture = await createFixture();
  const missingId = crypto.randomUUID();

  const body = await postJson(fixture.session, "get-captures", {
    ids: [fixture.captureId, missingId],
  });

  assertEquals(body.missingIds, [missingId]);
  const item = objectValue(arrayValue(body, "items")[0]);
  assertEquals(item.id, fixture.captureId);
  assertEquals(item.kind, "photo");
  assertEquals(item.status, "applied");
  assertEquals(item.appliedDishId, fixture.dishId);
  assertEquals(objectValue(item, "image").id, fixture.imageId);
  assertSignedUrl(objectValue(item, "image").mediaRef);
});

Deno.test("prepare-photo-upload can resume an existing storage object", async () => {
  const session = await createSession();
  const adminClient = createClient(baseUrl, serviceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });
  const captureId = crypto.randomUUID();
  const storagePath =
    `users/${session.userId}/captures/${captureId}/original.jpg`;
  const firstBytes = new Uint8Array([0xff, 0xd8, 0x01, 0xd9]);
  const resumedBytes = new Uint8Array([0xff, 0xd8, 0x02, 0xd9]);

  await checked(
    adminClient.storage.from("menu-media").upload(
      storagePath,
      new Blob([firstBytes], { type: "image/jpeg" }),
      {
        contentType: "image/jpeg",
        upsert: true,
      },
    ),
    "upload interrupted capture image",
  );

  const prepared = await postJson(session, "prepare-photo-upload", {
    captureId,
    contentType: "image/jpeg",
    byteSize: resumedBytes.length,
  });
  const upload = objectValue(prepared, "upload");
  await checked(
    adminClient.storage.from("menu-media").uploadToSignedUrl(
      storagePath,
      stringValue(upload, "token"),
      new Blob([resumedBytes], { type: "image/jpeg" }),
      {
        contentType: "image/jpeg",
        upsert: true,
      },
    ),
    "resume interrupted capture image",
  );
});

Deno.test("create-photo records an ordered batch item idempotently", async () => {
  const session = await createSession();
  const adminClient = createClient(baseUrl, serviceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });
  const batchId = crypto.randomUUID();
  const captureId = crypto.randomUUID();
  const storagePath =
    `users/${session.userId}/captures/${captureId}/original.jpg`;

  await postRpc(session, "api_upsert_capture_batch", {
    p_batch_id: batchId,
    p_item_count: 1,
    p_created_at: "2026-07-25T12:00:00Z",
  });
  await checked(
    adminClient.storage.from("menu-media").upload(
      storagePath,
      new Blob([new Uint8Array([0xff, 0xd8, 0xff, 0xd9])], {
        type: "image/jpeg",
      }),
      {
        contentType: "image/jpeg",
        upsert: true,
      },
    ),
    "upload ordered capture image",
  );

  const request = {
    batchId,
    captureId,
    ordinal: 0,
    storagePath,
    contentType: "image/jpeg",
    byteSize: 4,
    capturedAt: "2026-07-25T12:00:00Z",
  };
  const first = await postJson(session, "create-photo", request);
  const second = await postJson(session, "create-photo", request);

  assertEquals(objectValue(first, "capture").batchId, batchId);
  assertEquals(objectValue(first, "capture").ordinal, 0);
  assertEquals(objectValue(first, "capture").status, "uploaded");
  assertEquals(
    objectValue(second, "capture").id,
    objectValue(first, "capture").id,
  );
  assertEquals(
    objectValue(second, "capture").imageId,
    objectValue(first, "capture").imageId,
  );

  const { count: captureCount, error: captureError } = await adminClient
    .from("captures")
    .select("id", { count: "exact", head: true })
    .eq("id", captureId)
    .eq("batch_id", batchId);
  if (captureError != null) {
    throw new Error(`count ordered captures: ${captureError.message}`);
  }
  assertEquals(captureCount, 1);

  const { count: imageCount, error: imageError } = await adminClient
    .from("dish_images")
    .select("id", { count: "exact", head: true })
    .eq("capture_id", captureId)
    .eq("storage_path", storagePath);
  if (imageError != null) {
    throw new Error(`count ordered capture images: ${imageError.message}`);
  }
  assertEquals(imageCount, 1);
});

Deno.test("get-dishes returns hydrated dishes and missing ids", async () => {
  const fixture = await createFixture();
  const missingId = crypto.randomUUID();

  const body = await postJson(fixture.session, "get-dishes", {
    ids: [fixture.dishId, missingId],
  });

  assertEquals(body.missingIds, [missingId]);
  const item = objectValue(arrayValue(body, "items")[0]);
  assertEquals(item.id, fixture.dishId);
  assertEquals(item.title, "Sync Test Noodles");
  assertEquals(item.labels, ["weeknight", "test"]);
  assertEquals(item.prepMinutes, 25);
  assertEquals(item.difficulty, "easy");
  assertEquals(item.isFavorite, true);
  assertEquals(item.madeCount, 1);
  assertEquals(typeof item.createdAt, "string");
  assertEquals(objectValue(item, "coverImage").id, fixture.imageId);
  assertEquals(arrayValue(item, "ingredients"), ["noodles", "soy sauce"]);
  assertEquals(arrayValue(item, "steps"), ["boil noodles", "toss with sauce"]);
  assertEquals(arrayValue(item, "notes"), ["Use less salt next time."]);

  const sourcePhoto = objectValue(arrayValue(item, "sourcePhotos")[0]);
  assertEquals(sourcePhoto.id, fixture.imageId);
  assertEquals(sourcePhoto.captureId, fixture.captureId);
  assertEquals(sourcePhoto.cookingOccasionId, null);
  assertEquals("note" in sourcePhoto, false);
  assertEquals(sourcePhoto.confidenceLabel, "high");
  assertSignedUrl(sourcePhoto.mediaRef);
});

Deno.test("get-dishes allows a deliberately blank description", async () => {
  const fixture = await createFixture();
  const adminClient = createClient(baseUrl, serviceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });

  await checked(
    adminClient.from("dishes").update({ description: "" }).eq(
      "id",
      fixture.dishId,
    ),
    "clear dish description",
  );

  const body = await postJson(fixture.session, "get-dishes", {
    ids: [fixture.dishId],
  });

  const item = objectValue(arrayValue(body, "items")[0]);
  assertEquals(item.description, "");
});

Deno.test("get-review-items returns review items and missing ids", async () => {
  const fixture = await createFixture();
  const missingId = crypto.randomUUID();

  const body = await postJson(fixture.session, "get-review-items", {
    ids: [fixture.reviewItemId, missingId],
  });

  assertEquals(body.missingIds, [missingId]);
  const item = objectValue(arrayValue(body, "items")[0]);
  assertEquals(item.id, fixture.reviewItemId);
  assertEquals(item.captureId, fixture.captureId);
  assertEquals(item.status, "open");
  assertEquals(item.summary, "Review whether this should update noodles.");
  assertEquals(item.suggestedDishIds, [fixture.dishId]);
  assertEquals(objectValue(item, "suggestedNewDish").title, "Maybe Noodles");
  assertEquals(item.confidenceLabel, "medium");
});

type Session = {
  headers: Record<string, string>;
  userId: string;
};

type Fixture = {
  captureId: string;
  dishId: string;
  imageId: string;
  reviewItemId: string;
  session: Session;
};

async function createFixture(): Promise<Fixture> {
  const session = await createSession();
  const adminClient = createClient(baseUrl, serviceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });

  const captureId = crypto.randomUUID();
  const dishId = crypto.randomUUID();
  const imageId = crypto.randomUUID();
  const reviewItemId = crypto.randomUUID();
  const capturedAt = "2026-06-24T12:00:00Z";
  const storagePath =
    `users/${session.userId}/captures/${captureId}/original.jpg`;

  await checked(
    adminClient.storage.from("menu-media").upload(
      storagePath,
      new Blob([new Uint8Array([0xff, 0xd8, 0xff, 0xd9])], {
        type: "image/jpeg",
      }),
      {
        contentType: "image/jpeg",
        upsert: true,
      },
    ),
    "upload capture image",
  );

  await checked(
    adminClient.from("dishes").insert({
      id: dishId,
      user_id: session.userId,
      title: "Sync Test Noodles",
      description: "Hydrated through the batch fetch endpoint.",
      labels: ["weeknight", "test"],
      prep_minutes: 25,
      difficulty: "easy",
      is_favorite: true,
      creation_source: "ai_capture",
    }),
    "insert dish",
  );

  await checked(
    adminClient.from("captures").insert({
      id: captureId,
      user_id: session.userId,
      kind: "photo",
      status: "applied",
      applied_dish_id: dishId,
      captured_at: capturedAt,
    }),
    "insert capture",
  );

  await checked(
    adminClient.from("dish_images").insert({
      id: imageId,
      user_id: session.userId,
      dish_id: dishId,
      capture_id: captureId,
      kind: "source_photo",
      storage_bucket: "menu-media",
      storage_path: storagePath,
      content_type: "image/jpeg",
      byte_size: 4,
      width: 1,
      height: 1,
      confidence_label: "high",
      captured_at: capturedAt,
    }),
    "insert dish image",
  );

  await checked(
    adminClient.from("dishes").update({ cover_image_id: imageId }).eq(
      "id",
      dishId,
    ),
    "set dish cover image",
  );

  await checked(
    adminClient.from("dish_ingredients").insert([
      {
        id: crypto.randomUUID(),
        user_id: session.userId,
        dish_id: dishId,
        body: "noodles",
        position: 0,
      },
      {
        id: crypto.randomUUID(),
        user_id: session.userId,
        dish_id: dishId,
        body: "soy sauce",
        position: 1,
      },
    ]),
    "insert dish ingredients",
  );

  await checked(
    adminClient.from("dish_steps").insert([
      {
        id: crypto.randomUUID(),
        user_id: session.userId,
        dish_id: dishId,
        body: "boil noodles",
        position: 0,
      },
      {
        id: crypto.randomUUID(),
        user_id: session.userId,
        dish_id: dishId,
        body: "toss with sauce",
        position: 1,
      },
    ]),
    "insert dish steps",
  );

  await checked(
    adminClient.from("dish_notes").insert({
      id: crypto.randomUUID(),
      user_id: session.userId,
      dish_id: dishId,
      body: "Use less salt next time.",
      position: 0,
    }),
    "insert dish note",
  );

  await checked(
    adminClient.from("review_items").insert({
      id: reviewItemId,
      user_id: session.userId,
      capture_id: captureId,
      status: "open",
      summary: "Review whether this should update noodles.",
      suggested_dish_ids: [dishId],
      suggested_new_dish: { title: "Maybe Noodles" },
      confidence_label: "medium",
    }),
    "insert review item",
  );

  await checked(
    adminClient.from("sync_events").insert([
      {
        user_id: session.userId,
        entity_type: "capture",
        entity_id: captureId,
        operation: "applied_to_existing_dish",
        payload: {
          captureId,
          dishId,
          sourceImageId: imageId,
        },
      },
      {
        user_id: session.userId,
        entity_type: "dish",
        entity_id: dishId,
        operation: "upsert",
        payload: { dishId },
      },
    ]),
    "insert sync events",
  );

  return {
    captureId,
    dishId,
    imageId,
    reviewItemId,
    session,
  };
}

async function createSession(): Promise<Session> {
  const authClient = createClient(baseUrl, authApiKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });

  const { data, error } = await authClient.auth.signInAnonymously();
  if (error != null) {
    throw new Error(`create anonymous session: ${error.message}`);
  }

  const accessToken = data.session?.access_token;
  const userId = data.user?.id;
  if (accessToken == null || userId == null) {
    throw new Error(
      "create anonymous session: missing access token or user id",
    );
  }

  return {
    userId,
    headers: {
      apikey: authApiKey,
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
  };
}

async function postJson(
  session: Session,
  functionName: string,
  body: Record<string, unknown>,
) {
  const response = await fetch(`${baseUrl}/functions/v1/${functionName}`, {
    method: "POST",
    headers: session.headers,
    body: JSON.stringify(body),
  });

  const text = await response.text();
  const data = text.length === 0
    ? {}
    : JSON.parse(text) as Record<string, unknown>;
  if (response.status !== 200) {
    throw new Error(
      `${functionName} returned ${response.status}: ${JSON.stringify(data)}`,
    );
  }
  return data;
}

async function postRpc(
  session: Session,
  functionName: string,
  body: Record<string, unknown>,
) {
  const response = await fetch(`${baseUrl}/rest/v1/rpc/${functionName}`, {
    method: "POST",
    headers: session.headers,
    body: JSON.stringify(body),
  });
  const text = await response.text();
  if (response.status !== 200) {
    throw new Error(`${functionName} returned ${response.status}: ${text}`);
  }
}

async function checked<T extends { error: unknown }>(
  request: PromiseLike<T>,
  context: string,
) {
  const result = await request;
  const error = result.error;
  if (error != null) {
    throw new Error(`${context}: ${messageFrom(error)}`);
  }
}

function requireTestEnv(name: string) {
  const value = Deno.env.get(name);
  if (value == null || value.length === 0) {
    throw new Error(`Missing required test environment variable: ${name}`);
  }
  return value;
}

function assertEquals(actual: unknown, expected: unknown) {
  if (!deepEquals(actual, expected)) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}

function assertSignedUrl(value: unknown) {
  if (
    typeof value !== "string" || !value.includes("/storage/v1/object/sign/")
  ) {
    throw new Error(
      `Expected signed storage URL, got ${JSON.stringify(value)}`,
    );
  }
}

function arrayValue(row: Record<string, unknown>, key: string) {
  const value = row[key];
  if (!Array.isArray(value)) {
    throw new Error(`Expected array at ${key}`);
  }
  return value;
}

function objectValue(
  value: unknown,
  key?: string,
): Record<string, unknown> {
  const item = key == null ? value : objectValue(value)[key];
  if (typeof item !== "object" || item == null || Array.isArray(item)) {
    throw new Error(
      `Expected object${key == null ? "" : ` at ${key}`}: ${
        JSON.stringify(item)
      }`,
    );
  }
  return item as Record<string, unknown>;
}

function numberValue(row: Record<string, unknown>, key: string) {
  const value = row[key];
  if (typeof value !== "number" || !Number.isFinite(value)) {
    throw new Error(`Expected number at ${key}: ${JSON.stringify(value)}`);
  }
  return value;
}

function stringValue(row: Record<string, unknown>, key: string) {
  const value = row[key];
  if (typeof value !== "string" || value.length === 0) {
    throw new Error(`Expected string at ${key}: ${JSON.stringify(value)}`);
  }
  return value;
}

function messageFrom(error: unknown) {
  if (typeof error === "object" && error != null && "message" in error) {
    return String((error as { message: unknown }).message);
  }
  return String(error);
}

function deepEquals(actual: unknown, expected: unknown): boolean {
  return JSON.stringify(actual) === JSON.stringify(expected);
}
