import { createClient } from "jsr:@supabase/supabase-js@2";
import type { SupabaseClientAny } from "../../functions/_shared/supabase.ts";

const baseUrl = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const serviceRoleKey = requiredEnv("SUPABASE_SERVICE_ROLE_KEY");
const anonKey = requiredEnv("SUPABASE_ANON_KEY");

Deno.test("signed account deletion removes service state and processing media", async () => {
  const admin = createClient(baseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const email = `delete-${crypto.randomUUID()}@example.com`;
  const password = `Fixture-${crypto.randomUUID()}`;
  const { data: created, error: createError } = await admin.auth.admin
    .createUser({ email, password, email_confirm: true });
  if (createError != null || created.user == null) {
    throw new Error(`create signed account: ${createError?.message}`);
  }
  const userId = created.user.id;
  const signedClient = createClient(baseUrl, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: signedIn, error: signInError } = await signedClient.auth
    .signInWithPassword({ email, password });
  if (signInError != null || signedIn.session == null) {
    throw new Error(`sign in fixture: ${signInError?.message}`);
  }

  const jobId = crypto.randomUUID();
  const assetId = crypto.randomUUID();
  const storagePath = `${userId}/${jobId}/${assetId}.jpg`;
  await insertOrThrow(admin, "service_entitlements", {
    user_id: userId,
    plan_key: "pro",
  });
  await insertOrThrow(admin, "processing_jobs", {
    id: jobId,
    user_id: userId,
    operation: "capture_grouping",
    status: "created",
    idempotency_key: crypto.randomUUID(),
    input_schema_version: "capture-grouping-input-v2",
    result_schema_version: "capture-grouping-result-v2",
    privacy_notice_version: "2026-08-04-cover-v1",
  });
  await insertOrThrow(admin, "processing_assets", {
    job_id: jobId,
    user_id: userId,
    asset_id: assetId,
    storage_path: storagePath,
    content_type: "image/jpeg",
    byte_size: 4,
  });
  const { error: uploadError } = await admin.storage.from("processing-media")
    .upload(
      storagePath,
      new Blob([new Uint8Array([0xff, 0xd8, 0xff, 0xd9])], {
        type: "image/jpeg",
      }),
    );
  if (uploadError != null) {
    throw new Error(`upload fixture: ${uploadError.message}`);
  }

  const response = await fetch(`${baseUrl}/functions/v1/service-account`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${signedIn.session.access_token}`,
    },
    body: JSON.stringify({ action: "delete" }),
  });
  assertEquals(response.status, 200);
  assertEquals(await response.json(), { deleted: true });

  const authLookup = await admin.auth.admin.getUserById(userId);
  assertEquals(authLookup.data.user, null);
  assertEquals(await countOwned(admin, "service_entitlements", userId), 0);
  assertEquals(await countOwned(admin, "processing_jobs", userId), 0);
  assertEquals(await countOwned(admin, "processing_assets", userId), 0);
  const download = await admin.storage.from("processing-media").download(
    storagePath,
  );
  assertEquals(download.data, null);
});

Deno.test("account deletion rejects guests and missing authentication", async () => {
  const missing = await fetch(`${baseUrl}/functions/v1/service-account`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ action: "delete" }),
  });
  assertEquals(missing.status, 401);

  const guest = createClient(baseUrl, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data, error } = await guest.auth.signInAnonymously();
  if (error != null || data.session == null) {
    throw new Error(`create guest: ${error?.message}`);
  }
  const rejected = await fetch(`${baseUrl}/functions/v1/service-account`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${data.session.access_token}`,
    },
    body: JSON.stringify({ action: "delete" }),
  });
  assertEquals(rejected.status, 403);
  const admin = createClient(baseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const lookup = await admin.auth.admin.getUserById(data.user!.id);
  assertEquals(lookup.data.user?.id, data.user!.id);
  await admin.auth.admin.deleteUser(data.user!.id);
});

async function insertOrThrow(
  client: SupabaseClientAny,
  table: string,
  values: Record<string, unknown>,
) {
  const { error } = await client.from(table).insert(values);
  if (error != null) {
    throw new Error(`insert ${table}: ${error.message}`);
  }
}

async function countOwned(
  client: SupabaseClientAny,
  table: string,
  userId: string,
) {
  const { count, error } = await client.from(table).select("*", {
    count: "exact",
    head: true,
  }).eq("user_id", userId);
  if (error != null) {
    throw new Error(`count ${table}: ${error.message}`);
  }
  return count;
}

function requiredEnv(name: string) {
  const value = Deno.env.get(name);
  if (value == null || value.length === 0) {
    throw new Error(`Missing ${name}`);
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
