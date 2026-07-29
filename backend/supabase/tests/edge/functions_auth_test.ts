const baseUrl = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const aiWorkerKey = Deno.env.get("AI_WORKER_KEY") ?? serviceRoleKey;

Deno.test("prepare-photo-upload requires a user session", async () => {
  const response = await fetch(`${baseUrl}/functions/v1/prepare-photo-upload`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      captureId: "10000000-0000-4000-8000-000000000010",
      contentType: "image/jpeg",
    }),
  });

  assertEquals(response.status, 401);
  await response.body?.cancel();
});

Deno.test("sync-pull requires a user session", async () => {
  const response = await fetch(`${baseUrl}/functions/v1/sync-pull`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ afterCursor: 0 }),
  });

  assertEquals(response.status, 401);
  await response.body?.cancel();
});

Deno.test("get-captures requires a user session", async () => {
  const response = await fetch(`${baseUrl}/functions/v1/get-captures`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ ids: [] }),
  });

  assertEquals(response.status, 401);
  await response.body?.cancel();
});

Deno.test("get-dishes requires a user session", async () => {
  const response = await fetch(`${baseUrl}/functions/v1/get-dishes`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ ids: [] }),
  });

  assertEquals(response.status, 401);
  await response.body?.cancel();
});

Deno.test("delete-dishes requires a user session", async () => {
  const response = await fetch(`${baseUrl}/functions/v1/delete-dishes`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      dishIds: ["70000000-0000-4000-8000-000000000001"],
    }),
  });

  assertEquals(response.status, 401);
  await response.body?.cancel();
});

Deno.test("delete-capture-batch requires a user session", async () => {
  const response = await fetch(
    `${baseUrl}/functions/v1/delete-capture-batch`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        batchId: "70000000-0000-4000-8000-000000000001",
      }),
    },
  );

  assertEquals(response.status, 401);
  await response.body?.cancel();
});

Deno.test("get-review-items requires a user session", async () => {
  const response = await fetch(`${baseUrl}/functions/v1/get-review-items`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ ids: [] }),
  });

  assertEquals(response.status, 401);
  await response.body?.cancel();
});

Deno.test("finalize-capture-batch requires a user session", async () => {
  const response = await fetch(
    `${baseUrl}/functions/v1/finalize-capture-batch`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        batchId: "30000000-0000-4000-8000-000000000010",
        kind: "photo",
        job: {},
      }),
    },
  );

  assertEquals(response.status, 401);
  await response.body?.cancel();
});

function assertEquals(actual: unknown, expected: unknown) {
  if (actual !== expected) {
    throw new Error(`Expected ${expected}, got ${actual}`);
  }
}

Deno.test("process-ai-jobs requires the worker key", async () => {
  const response = await fetch(
    `${baseUrl}/functions/v1/process-ai-jobs`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${serviceRoleKey}`,
        "Content-Type": "application/json",
        "x-mymenu-worker-key": "not-the-worker-key",
      },
      body: "{}",
    },
  );

  assertEquals(response.status, 403);
  await response.body?.cancel();
});

Deno.test("process-ai-jobs accepts the dedicated worker key", async () => {
  const response = await fetch(
    `${baseUrl}/functions/v1/process-ai-jobs`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-mymenu-worker-key": aiWorkerKey,
      },
      body: "{}",
    },
  );

  assertEquals(response.status, 202);
  await response.body?.cancel();
});
