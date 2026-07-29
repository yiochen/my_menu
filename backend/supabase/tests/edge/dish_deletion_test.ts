import { createClient } from "jsr:@supabase/supabase-js@2";
import type { SupabaseClientAny } from "../../functions/_shared/supabase.ts";

const baseUrl = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const serviceRoleKey = requireTestEnv("SUPABASE_SERVICE_ROLE_KEY");
const authApiKey = Deno.env.get("SUPABASE_ANON_KEY") ?? serviceRoleKey;

type Session = {
  headers: Record<string, string>;
  userId: string;
};

Deno.test(
  "delete-dishes removes owned storage and relational data idempotently",
  async () => {
    const bucket = "menu-media";
    const bytes = new Uint8Array([0xff, 0xd8, 0xff, 0xd9]);
    const contentType = "image/jpeg";
    const title = "Edge deletion test";
    const otherTitle = "Other user's valid idea";
    const storageCount = 2;
    const expectedDeletedDishes = 2;
    const expectedDeletedCaptures = 1;
    const expectedOtherDishCount = 1;
    const expectedZero = 0;

    const session = await createSession();
    const otherSession = await createSession();
    const adminClient = createClient(baseUrl, serviceRoleKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    });
    const ideaDishId = crypto.randomUUID();
    const cookedDishId = crypto.randomUUID();
    const otherDishId = crypto.randomUUID();
    const captureId = crypto.randomUUID();
    const sourceImageId = crypto.randomUUID();
    const coverImageId = crypto.randomUUID();
    const sourcePath =
      `users/${session.userId}/captures/${captureId}/delete-source.jpg`;
    const coverPath =
      `users/${session.userId}/covers/${cookedDishId}/delete-cover.jpg`;

    await checked(
      adminClient.storage.from(bucket).upload(
        sourcePath,
        new Blob([bytes], { type: contentType }),
        { contentType, upsert: true },
      ),
      "upload deletion source",
    );
    await checked(
      adminClient.storage.from(bucket).upload(
        coverPath,
        new Blob([bytes], { type: contentType }),
        { contentType, upsert: true },
      ),
      "upload deletion cover",
    );
    await checked(
      adminClient.from("dishes").insert([
        {
          id: ideaDishId,
          user_id: session.userId,
          title: `${title} idea`,
          creation_source: "manual",
        },
        {
          id: cookedDishId,
          user_id: session.userId,
          title: `${title} cooked`,
          creation_source: "ai_capture",
        },
        {
          id: otherDishId,
          user_id: otherSession.userId,
          title: otherTitle,
          creation_source: "manual",
        },
      ]),
      "insert deletion dishes",
    );
    await checked(
      adminClient.from("captures").insert({
        id: captureId,
        user_id: session.userId,
        kind: "photo",
        status: "applied",
        applied_dish_id: cookedDishId,
      }),
      "insert deletion capture",
    );
    await checked(
      adminClient.from("dish_images").insert([
        {
          id: sourceImageId,
          user_id: session.userId,
          dish_id: cookedDishId,
          capture_id: captureId,
          kind: "source_photo",
          storage_bucket: bucket,
          storage_path: sourcePath,
          content_type: contentType,
        },
        {
          id: coverImageId,
          user_id: session.userId,
          dish_id: cookedDishId,
          kind: "ai_generated",
          storage_bucket: bucket,
          storage_path: coverPath,
          content_type: contentType,
        },
      ]),
      "insert deletion image rows",
    );
    await checked(
      adminClient.from("dishes").update({ cover_image_id: coverImageId }).eq(
        "id",
        cookedDishId,
      ),
      "set deletion cover",
    );
    await checked(
      adminClient.from("dish_notes").insert({
        id: crypto.randomUUID(),
        user_id: session.userId,
        dish_id: cookedDishId,
        body: "Delete this note.",
      }),
      "insert deletion note",
    );

    const result = await postJson(session, "delete-dishes", {
      dishIds: [ideaDishId, cookedDishId, otherDishId],
    });

    assertEquals(
      arrayValue(result, "deletedDishIds").length,
      expectedDeletedDishes,
    );
    assertEquals(
      arrayValue(result, "deletedCaptureIds").length,
      expectedDeletedCaptures,
    );
    assertEquals(result.deletedStorageObjects, storageCount);
    await assertMissingStorageObject(adminClient, bucket, sourcePath);
    await assertMissingStorageObject(adminClient, bucket, coverPath);

    const { count: ownedCount, error: ownedError } = await adminClient
      .from("dishes")
      .select("id", { count: "exact", head: true })
      .in("id", [ideaDishId, cookedDishId]);
    if (ownedError != null) {
      throw new Error(`count deleted dishes: ${ownedError.message}`);
    }
    assertEquals(ownedCount, expectedZero);

    const { count: otherCount, error: otherError } = await adminClient
      .from("dishes")
      .select("id", { count: "exact", head: true })
      .eq("id", otherDishId);
    if (otherError != null) {
      throw new Error(`count other user's dish: ${otherError.message}`);
    }
    assertEquals(otherCount, expectedOtherDishCount);

    const repeated = await postJson(session, "delete-dishes", {
      dishIds: [ideaDishId, cookedDishId],
    });
    assertEquals(arrayValue(repeated, "deletedDishIds"), []);
    assertEquals(repeated.deletedStorageObjects, expectedZero);
  },
);

Deno.test("delete-dishes validates authenticated requests", async () => {
  const session = await createSession();
  const response = await fetch(`${baseUrl}/functions/v1/delete-dishes`, {
    method: "POST",
    headers: session.headers,
    body: JSON.stringify({ dishIds: [] }),
  });

  assertEquals(response.status, 400);
  await response.body?.cancel();
});

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
    throw new Error("create anonymous session: missing session data");
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

async function assertMissingStorageObject(
  adminClient: SupabaseClientAny,
  bucket: string,
  path: string,
) {
  const { error } = await adminClient.storage.from(bucket).download(path);
  if (error == null) {
    throw new Error(`Expected deleted storage object: ${bucket}/${path}`);
  }
}

async function checked<T extends { error: unknown }>(
  request: PromiseLike<T>,
  context: string,
) {
  const result = await request;
  if (result.error != null) {
    throw new Error(`${context}: ${messageFrom(result.error)}`);
  }
}

function arrayValue(row: Record<string, unknown>, key: string) {
  const value = row[key];
  if (!Array.isArray(value)) {
    throw new Error(`Expected array at ${key}`);
  }
  return value;
}

function requireTestEnv(name: string) {
  const value = Deno.env.get(name);
  if (value == null || value.length === 0) {
    throw new Error(`Missing required test environment variable: ${name}`);
  }
  return value;
}

function messageFrom(error: unknown) {
  if (typeof error === "object" && error != null && "message" in error) {
    return String((error as { message: unknown }).message);
  }
  return String(error);
}

function assertEquals(actual: unknown, expected: unknown) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
