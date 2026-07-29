import { createClient } from "jsr:@supabase/supabase-js@2";
import type { SupabaseClientAny } from "../../functions/_shared/supabase.ts";

const baseUrl = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const serviceRoleKey = requireTestEnv("SUPABASE_SERVICE_ROLE_KEY");
const authApiKey = Deno.env.get("SUPABASE_ANON_KEY") ?? serviceRoleKey;

Deno.test("delete-dishes removes relational and Storage data but preserves a shared batch dish", async () => {
  const session = await createSession();
  const admin = createClient(baseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const batchId = crypto.randomUUID();
  const deletedDishId = crypto.randomUUID();
  const keeperDishId = crypto.randomUUID();
  const deletedCaptureId = crypto.randomUUID();
  const keeperCaptureId = crypto.randomUUID();
  const deletedPath =
    `users/${session.userId}/captures/${deletedCaptureId}/original.jpg`;
  const keeperPath =
    `users/${session.userId}/captures/${keeperCaptureId}/original.jpg`;

  await checked(
    admin.from("capture_batches").insert({
      id: batchId,
      user_id: session.userId,
      status: "applied",
      item_count: 2,
    }),
    "insert capture batch",
  );
  await checked(
    admin.from("dishes").insert([
      {
        id: deletedDishId,
        user_id: session.userId,
        title: "Dish to delete",
        creation_source: "ai_capture",
      },
      {
        id: keeperDishId,
        user_id: session.userId,
        title: "Dish to keep",
        creation_source: "ai_capture",
      },
    ]),
    "insert dishes",
  );
  await checked(
    admin.from("captures").insert([
      {
        id: deletedCaptureId,
        user_id: session.userId,
        batch_id: batchId,
        ordinal: 0,
        kind: "photo",
        status: "applied",
        applied_dish_id: deletedDishId,
      },
      {
        id: keeperCaptureId,
        user_id: session.userId,
        batch_id: batchId,
        ordinal: 1,
        kind: "photo",
        status: "applied",
        applied_dish_id: keeperDishId,
      },
    ]),
    "insert captures",
  );
  await checked(
    admin.storage.from("menu-media").upload(
      deletedPath,
      new Blob([new Uint8Array([0xff, 0xd8, 0x01, 0xd9])], {
        type: "image/jpeg",
      }),
    ),
    "upload deleted source",
  );
  await checked(
    admin.storage.from("menu-media").upload(
      keeperPath,
      new Blob([new Uint8Array([0xff, 0xd8, 0x02, 0xd9])], {
        type: "image/jpeg",
      }),
    ),
    "upload keeper source",
  );
  await checked(
    admin.from("dish_images").insert([
      {
        id: crypto.randomUUID(),
        user_id: session.userId,
        dish_id: deletedDishId,
        capture_id: deletedCaptureId,
        kind: "source_photo",
        storage_path: deletedPath,
        content_type: "image/jpeg",
      },
      {
        id: crypto.randomUUID(),
        user_id: session.userId,
        dish_id: keeperDishId,
        capture_id: keeperCaptureId,
        kind: "source_photo",
        storage_path: keeperPath,
        content_type: "image/jpeg",
      },
    ]),
    "insert source image rows",
  );
  await checked(
    admin.from("dish_notes").insert({
      id: crypto.randomUUID(),
      user_id: session.userId,
      dish_id: deletedDishId,
      body: "Delete this note.",
    }),
    "insert note",
  );
  await checked(
    admin.from("dish_ingredients").insert({
      id: crypto.randomUUID(),
      user_id: session.userId,
      dish_id: deletedDishId,
      body: "Delete this ingredient.",
    }),
    "insert ingredient",
  );
  await checked(
    admin.from("dish_steps").insert({
      id: crypto.randomUUID(),
      user_id: session.userId,
      dish_id: deletedDishId,
      body: "Delete this step.",
    }),
    "insert step",
  );
  await checked(
    admin.from("planned_meals").insert({
      id: crypto.randomUUID(),
      user_id: session.userId,
      dish_id: deletedDishId,
      day_key: "2026-07-30",
    }),
    "insert planned meal",
  );

  const result = await postJson(session, "delete-dishes", {
    dishIds: [deletedDishId],
  });

  assertEquals(result.deletedDishIds, [deletedDishId]);
  assertEquals(objectValue(result, "counts").notes, 1);
  await assertRowCount(admin, "dishes", "id", deletedDishId, 0);
  await assertRowCount(admin, "dishes", "id", keeperDishId, 1);
  await assertRowCount(admin, "captures", "id", deletedCaptureId, 0);
  await assertRowCount(admin, "captures", "id", keeperCaptureId, 1);
  await assertRowCount(admin, "dish_notes", "dish_id", deletedDishId, 0);
  await assertRowCount(
    admin,
    "dish_ingredients",
    "dish_id",
    deletedDishId,
    0,
  );
  await assertRowCount(admin, "dish_steps", "dish_id", deletedDishId, 0);
  await assertRowCount(admin, "planned_meals", "dish_id", deletedDishId, 0);
  await assertRowCount(admin, "capture_batches", "id", batchId, 1);

  const deletedObjects = await checkedData(
    admin.storage.from("menu-media").list(
      `users/${session.userId}/captures/${deletedCaptureId}`,
    ),
    "list deleted storage directory",
  );
  const keeperObjects = await checkedData(
    admin.storage.from("menu-media").list(
      `users/${session.userId}/captures/${keeperCaptureId}`,
    ),
    "list keeper storage directory",
  );
  assertEquals(deletedObjects.length, 0);
  assertEquals(keeperObjects.length, 1);
});

Deno.test("delete-dishes rejects an empty selection", async () => {
  const session = await createSession();
  const response = await fetch(`${baseUrl}/functions/v1/delete-dishes`, {
    method: "POST",
    headers: session.headers,
    body: JSON.stringify({ dishIds: [] }),
  });
  assertEquals(response.status, 400);
  await response.body?.cancel();
});

type Session = {
  headers: Record<string, string>;
  userId: string;
};

async function createSession(): Promise<Session> {
  const client = createClient(baseUrl, authApiKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data, error } = await client.auth.signInAnonymously();
  if (error != null) {
    throw new Error(`create anonymous session: ${error.message}`);
  }
  const token = data.session?.access_token;
  const userId = data.user?.id;
  if (token == null || userId == null) {
    throw new Error("create anonymous session: missing session");
  }
  return {
    userId,
    headers: {
      apikey: authApiKey,
      Authorization: `Bearer ${token}`,
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
  const data = await response.json() as Record<string, unknown>;
  if (response.status !== 200) {
    throw new Error(
      `${functionName} returned ${response.status}: ${JSON.stringify(data)}`,
    );
  }
  return data;
}

async function assertRowCount(
  client: SupabaseClientAny,
  table: string,
  column: string,
  value: string,
  expected: number,
) {
  const { count, error } = await client.from(table).select(
    "id",
    { count: "exact", head: true },
  ).eq(column, value);
  if (error != null) {
    throw new Error(`count ${table}: ${error.message}`);
  }
  assertEquals(count, expected);
}

async function checked<T extends { error: unknown }>(
  request: PromiseLike<T>,
  context: string,
) {
  const result = await request;
  if (result.error != null) {
    throw new Error(`${context}: ${JSON.stringify(result.error)}`);
  }
}

async function checkedData<T>(
  request: PromiseLike<{ data: T | null; error: unknown }>,
  context: string,
) {
  const result = await request;
  if (result.error != null || result.data == null) {
    throw new Error(`${context}: ${JSON.stringify(result.error)}`);
  }
  return result.data;
}

function objectValue(data: Record<string, unknown>, key: string) {
  const value = data[key];
  if (typeof value !== "object" || value == null || Array.isArray(value)) {
    throw new Error(`Expected object at ${key}`);
  }
  return value as Record<string, unknown>;
}

function requireTestEnv(name: string) {
  const value = Deno.env.get(name);
  if (value == null || value.length === 0) {
    throw new Error(`Missing required test environment variable: ${name}`);
  }
  return value;
}

function assertEquals(actual: unknown, expected: unknown) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
