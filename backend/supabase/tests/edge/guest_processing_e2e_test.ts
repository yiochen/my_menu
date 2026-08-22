import { createClient } from "jsr:@supabase/supabase-js@2";
import type {
  ProcessingPolicy,
  ProcessingPolicyProvider,
} from "../../functions/_shared/processing_policy.ts";
import { createProcessingJobsHandler } from "../../functions/processing-jobs/handler.ts";

const baseUrl = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const serviceRoleKey = requiredEnv("SUPABASE_SERVICE_ROLE_KEY");
const anonKey = requiredEnv("SUPABASE_ANON_KEY");
const workerKey = requiredEnv("AI_WORKER_KEY");
const freePolicy: ProcessingPolicy = {
  captureOrganizationLimit: 10,
  captureOrganizationBypass: false,
  dishCoverLimit: 10,
  dishCoverBypass: false,
};
const processingJobsHandler = createProcessingJobsHandler(
  fixedPolicyProvider(freePolicy),
);

Deno.test("guest capture grouping is ephemeral and idempotent", async () => {
  const session = await createGuestSession();
  const admin = createClient(baseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const idempotencyKey = crypto.randomUUID();
  const assetId = crypto.randomUUID();
  const createBody = {
    action: "create",
    operation: "capture_grouping",
    idempotencyKey,
    inputSchemaVersion: "capture-grouping-input-v2",
    resultSchemaVersion: "capture-grouping-result-v2",
    privacyNoticeVersion: "2026-08-04-cover-v1",
    assets: [{ assetId, contentType: "image/jpeg", byteSize: 4 }],
  };

  const first = await post(session.headers, "processing-jobs", createBody);
  assertEquals(first.status, 200);
  const firstBody = await jsonBody(first);
  const repeated = await post(session.headers, "processing-jobs", createBody);
  const repeatedBody = await jsonBody(repeated);
  assertEquals(
    objectValue(repeatedBody, "job").id,
    objectValue(firstBody, "job").id,
  );
  const { data: usageRows, error: usageError } = await admin
    .from("ai_usage_records")
    .select("operation,units,outcome,idempotency_key,created_at,expires_at")
    .eq("user_id", session.userId)
    .eq("idempotency_key", idempotencyKey);
  if (usageError != null) {
    throw new Error(`read usage record: ${usageError.message}`);
  }
  assertEquals(usageRows?.length, 1);
  assertEquals(usageRows?.[0].operation, "capture_grouping");
  assertEquals(
    JSON.stringify(usageRows).includes("Private fixture noodles"),
    false,
  );

  const job = objectValue(firstBody, "job");
  const jobId = stringValue(job, "id");
  const target = objectValue(arrayValue(firstBody, "uploadTargets")[0]);
  const upload = await session.client.storage.from("processing-media")
    .uploadToSignedUrl(
      stringValue(target, "storagePath"),
      stringValue(target, "token"),
      new Blob([new Uint8Array([0xff, 0xd8, 0xff, 0xd9])], {
        type: "image/jpeg",
      }),
      { contentType: "image/jpeg", upsert: true },
    );
  if (upload.error != null) {
    throw new Error(`signed processing upload: ${upload.error.message}`);
  }

  const invalidSubmit = await post(session.headers, "processing-jobs", {
    action: "submit",
    jobId,
    input: {
      captures: [{
        id: assetId,
        kind: "photo",
        ordinal: 0,
        assetId: crypto.randomUUID(),
      }],
      dishes: [],
    },
  });
  assertEquals(invalidSubmit.status, 400);

  const submit = await post(session.headers, "processing-jobs", {
    action: "submit",
    jobId,
    input: {
      captures: [{
        id: assetId,
        kind: "photo",
        ordinal: 0,
        capturedLocalDate: "2026-08-02",
        assetId,
      }],
      dishes: [{
        localId: crypto.randomUUID(),
        title: "Private fixture noodles",
        description: "Never persist this fixture menu content",
        ingredients: ["secret scallions"],
        recipeSteps: ["private step"],
        notes: ["private note"],
      }],
    },
  });
  assertEquals(submit.status, 200);

  const worker = await post(
    { "Content-Type": "application/json", "x-mymenu-worker-key": workerKey },
    "process-ai-jobs",
    {},
  );
  assertEquals(worker.status, 202);

  const completed = await waitForStatus(session.headers, jobId, "succeeded");
  assertEquals(objectValue(completed, "job").operation, "capture_grouping");
  const resultResponse = await post(session.headers, "processing-jobs", {
    action: "result",
    jobId,
  });
  assertEquals(resultResponse.status, 200);
  const result = objectValue(await jsonBody(resultResponse), "result");
  assertEquals(result.operation, "capture_grouping");
  const decisions = arrayValue(result, "decisions");
  assertEquals(decisions.length, 1);
  assertEquals("confidence" in objectValue(decisions[0]), false);

  const acknowledge = await post(session.headers, "processing-jobs", {
    action: "acknowledge",
    jobId,
  });
  assertEquals(acknowledge.status, 200);
  const acknowledged = await post(session.headers, "processing-jobs", {
    action: "status",
    jobId,
  });
  assertEquals(acknowledged.status, 404);
  assertEquals(await countRows(admin, "processing_jobs", "id", jobId), 0);
  assertEquals(await countRows(admin, "processing_assets", "job_id", jobId), 0);
  assertEquals(await countJobObjects(admin, jobId), 0);

  const canceledJob = await createJob(session.headers, crypto.randomUUID());
  const canceled = await post(session.headers, "processing-jobs", {
    action: "cancel",
    jobId: canceledJob,
  });
  assertEquals(canceled.status, 200);
  const canceledStatus = await post(session.headers, "processing-jobs", {
    action: "status",
    jobId: canceledJob,
  });
  assertEquals(canceledStatus.status, 404);

  const expirySession = session;
  const expiryAssetId = crypto.randomUUID();
  const expiryCreate = await post(expirySession.headers, "processing-jobs", {
    ...createBody,
    idempotencyKey: crypto.randomUUID(),
    assets: [{
      assetId: expiryAssetId,
      contentType: "image/jpeg",
      byteSize: 4,
    }],
  });
  assertEquals(expiryCreate.status, 200);
  const expiryCreateBody = await jsonBody(expiryCreate);
  const expiringJob = stringValue(objectValue(expiryCreateBody, "job"), "id");
  const expiryTarget = objectValue(
    arrayValue(expiryCreateBody, "uploadTargets")[0],
  );
  const expiryUpload = await expirySession.client.storage.from(
    "processing-media",
  ).uploadToSignedUrl(
    stringValue(expiryTarget, "storagePath"),
    stringValue(expiryTarget, "token"),
    new Blob([new Uint8Array([0xff, 0xd8, 0xff, 0xd9])], {
      type: "image/jpeg",
    }),
    { contentType: "image/jpeg", upsert: true },
  );
  if (expiryUpload.error != null) {
    throw new Error(`signed expiry upload: ${expiryUpload.error.message}`);
  }
  const expirySubmit = await post(expirySession.headers, "processing-jobs", {
    action: "submit",
    jobId: expiringJob,
    input: {
      captures: [{
        id: expiryAssetId,
        kind: "photo",
        ordinal: 0,
        capturedLocalDate: "2026-08-02",
        assetId: expiryAssetId,
      }],
      dishes: [{
        localId: crypto.randomUUID(),
        title: "Expired private fixture ramen",
        description: "Must disappear during expiry cleanup",
        ingredients: ["private broth"],
        recipeSteps: ["private step"],
        notes: ["private note"],
      }],
    },
  });
  assertEquals(expirySubmit.status, 200);
  const { error: expireError } = await admin.from("processing_jobs").update({
    expires_at: "2026-08-01T00:00:00Z",
  }).eq("id", expiringJob);
  if (expireError != null) {
    throw new Error(`expire processing job fixture: ${expireError.message}`);
  }
  const cleanup = await post(
    { "Content-Type": "application/json", "x-mymenu-worker-key": workerKey },
    "cleanup-processing-jobs",
    {},
  );
  assertEquals(cleanup.status, 200);
  const cleanupBody = await jsonBody(cleanup);
  assertEquals(cleanupBody.expired, 1);
  assertEquals(cleanupBody.expiredGuests, 0);
  assertEquals(cleanupBody.deletedOrphanAssets, 0);
  const expiredStatus = await post(expirySession.headers, "processing-jobs", {
    action: "status",
    jobId: expiringJob,
  });
  assertEquals(expiredStatus.status, 404);
  assertEquals(await countRows(admin, "processing_jobs", "id", expiringJob), 0);
  assertEquals(
    await countRows(admin, "processing_assets", "job_id", expiringJob),
    0,
  );
  assertEquals(await countJobObjects(admin, expiringJob), 0);

  for (let index = 0; index < 6; index += 1) {
    await createJob(session.headers, crypto.randomUUID());
  }
  const concurrentAllowance = await Promise.all([
    post(session.headers, "processing-jobs", {
      ...createBody,
      idempotencyKey: crypto.randomUUID(),
      assets: [],
    }),
    post(session.headers, "processing-jobs", {
      ...createBody,
      idempotencyKey: crypto.randomUUID(),
      assets: [],
    }),
  ]);
  assertEquals(
    concurrentAllowance.map((response) => response.status).sort(),
    [200, 429],
  );
  const overAllowance = await post(session.headers, "processing-jobs", {
    ...createBody,
    idempotencyKey: crypto.randomUUID(),
    assets: [],
  });
  assertEquals(overAllowance.status, 429);
});

Deno.test("processing jobs are isolated to their service owner", async () => {
  const owner = await createGuestSession();
  const other = await createGuestSession();
  const jobId = await createJob(owner.headers, crypto.randomUUID());

  for (const action of ["status", "result", "acknowledge", "cancel"]) {
    const response = await post(other.headers, "processing-jobs", {
      action,
      jobId,
    });
    assertEquals(response.status, 404);
  }

  const ownerStatus = await post(owner.headers, "processing-jobs", {
    action: "status",
    jobId,
  });
  assertEquals(ownerStatus.status, 200);
  const canceled = await post(owner.headers, "processing-jobs", {
    action: "cancel",
    jobId,
  });
  assertEquals(canceled.status, 200);
});

Deno.test("guest idea cover uses the bounded contract and charges on acknowledgement", async () => {
  const session = await createGuestSession();
  const admin = createClient(baseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const idempotencyKey = crypto.randomUUID();
  const createBody = {
    action: "create",
    operation: "cover_generation",
    idempotencyKey,
    inputSchemaVersion: "cover-generation-input-v1",
    resultSchemaVersion: "cover-generation-result-v1",
    privacyNoticeVersion: "2026-08-04-cover-v1",
    assets: [],
  };
  const reservedOutput = await post(session.headers, "processing-jobs", {
    ...createBody,
    idempotencyKey: crypto.randomUUID(),
    assets: [{
      assetId: "cover-output",
      contentType: "image/png",
      byteSize: 12,
    }],
  });
  assertEquals(reservedOutput.status, 400);
  const created = await post(session.headers, "processing-jobs", createBody);
  assertEquals(created.status, 200);
  const jobId = stringValue(
    objectValue(await jsonBody(created), "job"),
    "id",
  );
  const submitted = await post(session.headers, "processing-jobs", {
    action: "submit",
    jobId,
    input: {
      dishTitle: "Golden curry",
      sources: [],
      notes: [{
        body: "Glossy golden sauce",
        position: 0,
        createdAt: "2026-08-04T00:00:00Z",
        updatedAt: "2026-08-04T00:00:00Z",
      }],
      treatment: {
        look: "warm_cozy",
        view: "auto",
        finish: "menu_ready",
      },
      origin: "manual",
      contractVersion: "cover-generation-v1",
    },
  });
  assertEquals(submitted.status, 200);
  const worker = await post(
    { "Content-Type": "application/json", "x-mymenu-worker-key": workerKey },
    "process-ai-jobs",
    {},
  );
  assertEquals(worker.status, 202);
  await waitForStatus(session.headers, jobId, "succeeded");
  const delivered = await post(session.headers, "processing-jobs", {
    action: "result",
    jobId,
  });
  const result = objectValue(await jsonBody(delivered), "result");
  assertEquals(result.operation, "cover_generation");
  assertEquals(objectValue(result, "validation").valid, true);
  const output = objectValue(result, "output");
  assertEquals("imageBase64" in output, false);
  assertEquals(output.contentType, "image/png");
  const coverDownload = await fetch(stringValue(output, "downloadUrl"));
  assertEquals(coverDownload.status, 200);
  const coverBytes = new Uint8Array(await coverDownload.arrayBuffer());
  assertEquals(coverBytes.length, output.byteSize);
  assertEquals(Array.from(coverBytes.subarray(0, 4)), [0x89, 0x50, 0x4e, 0x47]);
  assertEquals(await countJobObjects(admin, jobId), 1);
  const repeated = await post(session.headers, "processing-jobs", createBody);
  const repeatedBody = await jsonBody(repeated);
  assertEquals(stringValue(objectValue(repeatedBody, "job"), "id"), jobId);
  assertEquals(arrayValue(repeatedBody, "uploadTargets"), []);
  const before = await usageFor(admin, session.userId, idempotencyKey);
  assertEquals(before.units, 0);
  assertEquals(before.outcome, "reserved");
  const acknowledged = await post(session.headers, "processing-jobs", {
    action: "acknowledge",
    jobId,
  });
  assertEquals(acknowledged.status, 200);
  assertEquals(await countJobObjects(admin, jobId), 0);
  const after = await usageFor(admin, session.userId, idempotencyKey);
  assertEquals(after.units, 1);
  assertEquals(after.outcome, "succeeded");
  const allowance = await post(session.headers, "processing-jobs", {
    action: "allowances",
  });
  assertEquals(allowance.status, 200);
  assertEquals(
    objectValue(await jsonBody(allowance), "cover").remaining,
    9,
  );
});

Deno.test("allowance status exposes a Statsig account bypass", async () => {
  const session = await createGuestSession();

  const initial = await postProcessing(processingJobsHandler, session.headers, {
    action: "allowances",
    plan_key: "pro",
    capture_auto_organization_limit: 999,
    capture_auto_organization_bypass: true,
  });
  assertEquals(initial.status, 200);
  const initialOrganization = objectValue(
    await jsonBody(initial),
    "organization",
  );
  assertEquals(initialOrganization.status, "enforced");
  assertEquals(initialOrganization.enforced, true);
  assertEquals(initialOrganization.remaining, 10);

  const bypassedHandler = createProcessingJobsHandler(fixedPolicyProvider({
    ...freePolicy,
    captureOrganizationBypass: true,
  }));
  const bypassed = await postProcessing(bypassedHandler, session.headers, {
    action: "allowances",
  });
  assertEquals(bypassed.status, 200);
  const bypassedOrganization = objectValue(
    await jsonBody(bypassed),
    "organization",
  );
  assertEquals(bypassedOrganization.status, "enforcement_disabled");
  assertEquals(bypassedOrganization.enforced, false);
  assertEquals(bypassedOrganization.remaining, null);
  assertEquals(bypassedOrganization.limit, 10);
  assertEquals(bypassedOrganization.used, 0);
});

Deno.test("processing policy uses only the trusted entitlement plan", async () => {
  const session = await createGuestSession();
  const admin = createClient(baseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const plans: string[] = [];
  const provider: ProcessingPolicyProvider = {
    async evaluate(context) {
      plans.push(context.planKey);
      return freePolicy;
    },
    async flush() {},
  };
  const handler = createProcessingJobsHandler(provider);

  await postProcessing(handler, session.headers, {
    action: "allowances",
    plan_key: "client-controlled",
  });
  const { error: insertError } = await admin.from("service_entitlements")
    .insert({ user_id: session.userId, plan_key: "pro", status: "active" });
  if (insertError != null) throw insertError;
  await postProcessing(handler, session.headers, { action: "allowances" });
  const { error: updateError } = await admin.from("service_entitlements")
    .update({ status: "inactive" }).eq("user_id", session.userId);
  if (updateError != null) throw updateError;
  await postProcessing(handler, session.headers, { action: "allowances" });

  assertEquals(plans, ["free", "pro", "free"]);
});

Deno.test("unavailable processing policy returns 503 before job creation", async () => {
  const session = await createGuestSession();
  const admin = createClient(baseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const handler = createProcessingJobsHandler({
    async evaluate() {
      throw new Error("processing_policy_unavailable");
    },
    async flush() {},
  });
  const response = await postProcessing(handler, session.headers, {
    action: "create",
    operation: "capture_grouping",
    idempotencyKey: crypto.randomUUID(),
    inputSchemaVersion: "capture-grouping-input-v2",
    resultSchemaVersion: "capture-grouping-result-v2",
    privacyNoticeVersion: "2026-08-04-cover-v1",
    assets: [],
  });

  assertEquals(response.status, 503);
  assertEquals(
    (await jsonBody(response)).error,
    "processing_policy_unavailable",
  );
  assertEquals(await countOwned(admin, "processing_jobs", session.userId), 0);
});

async function usageFor(client: any, userId: string, idempotencyKey: string) {
  const { data, error } = await client.from("ai_usage_records")
    .select("units,outcome").eq("user_id", userId)
    .eq("idempotency_key", idempotencyKey).single();
  if (error != null) throw error;
  return data as { units: number; outcome: string };
}

async function createJob(headers: HeadersInit, idempotencyKey: string) {
  const response = await post(headers, "processing-jobs", {
    action: "create",
    operation: "capture_grouping",
    idempotencyKey,
    inputSchemaVersion: "capture-grouping-input-v2",
    resultSchemaVersion: "capture-grouping-result-v2",
    privacyNoticeVersion: "2026-08-04-cover-v1",
    assets: [],
  });
  assertEquals(response.status, 200);
  return stringValue(objectValue(await jsonBody(response), "job"), "id");
}

async function waitForStatus(
  headers: HeadersInit,
  jobId: string,
  expected: string,
) {
  for (let attempt = 0; attempt < 50; attempt += 1) {
    const response = await post(headers, "processing-jobs", {
      action: "status",
      jobId,
    });
    const body = await jsonBody(response);
    if (objectValue(body, "job").status === expected) {
      return body;
    }
    await new Promise((resolve) => setTimeout(resolve, 100));
  }
  throw new Error(`processing job ${jobId} did not reach ${expected}`);
}

async function createGuestSession() {
  const client = createClient(baseUrl, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data, error } = await client.auth.signInAnonymously();
  if (error != null || data.session == null || data.user == null) {
    throw new Error(
      `create guest session: ${error?.message ?? "missing session"}`,
    );
  }
  return {
    userId: data.user.id,
    client,
    headers: {
      apikey: anonKey,
      Authorization: `Bearer ${data.session.access_token}`,
      "Content-Type": "application/json",
    },
  };
}

function post(headers: HeadersInit, functionName: string, body: unknown) {
  if (functionName === "processing-jobs") {
    return postProcessing(processingJobsHandler, headers, body);
  }
  return fetch(`${baseUrl}/functions/v1/${functionName}`, {
    method: "POST",
    headers,
    body: JSON.stringify(body),
  });
}

function postProcessing(
  handler: (request: Request) => Promise<Response>,
  headers: HeadersInit,
  body: unknown,
) {
  return handler(
    new Request(`${baseUrl}/functions/v1/processing-jobs`, {
      method: "POST",
      headers,
      body: JSON.stringify(body),
    }),
  );
}

function fixedPolicyProvider(
  policy: ProcessingPolicy,
): ProcessingPolicyProvider {
  return {
    async evaluate() {
      return policy;
    },
    async flush() {},
  };
}

async function jsonBody(response: Response) {
  const text = await response.text();
  return text.length === 0 ? {} : JSON.parse(text) as Record<string, unknown>;
}

async function countOwned(client: any, table: string, userId: string) {
  const { count, error } = await client.from(table).select("id", {
    count: "exact",
    head: true,
  }).eq("user_id", userId);
  if (error != null) {
    throw new Error(`count ${table}: ${error.message}`);
  }
  return count;
}

async function countJobObjects(client: any, jobId: string) {
  const { data, error } = await client.storage.from("processing-media").list(
    jobId,
  );
  if (error != null) {
    throw new Error(`list processing objects: ${error.message}`);
  }
  return data.length;
}

async function countRows(
  client: any,
  table: string,
  column: string,
  value: string,
) {
  const { count, error } = await client.from(table).select("*", {
    count: "exact",
    head: true,
  }).eq(column, value);
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

function objectValue(value: unknown, key?: string): Record<string, unknown> {
  const item = key == null ? value : objectValue(value)[key];
  if (typeof item !== "object" || item == null || Array.isArray(item)) {
    throw new Error(`Expected object${key == null ? "" : ` at ${key}`}`);
  }
  return item as Record<string, unknown>;
}

function arrayValue(value: Record<string, unknown>, key: string) {
  const item = value[key];
  if (!Array.isArray(item)) {
    throw new Error(`Expected array at ${key}`);
  }
  return item;
}

function stringValue(value: Record<string, unknown>, key: string) {
  const item = value[key];
  if (typeof item !== "string" || item.length === 0) {
    throw new Error(`Expected string at ${key}`);
  }
  return item;
}

function assertEquals(actual: unknown, expected: unknown) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
