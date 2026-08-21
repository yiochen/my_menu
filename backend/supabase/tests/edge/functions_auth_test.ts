const baseUrl = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const aiWorkerKey = Deno.env.get("AI_WORKER_KEY") ?? serviceRoleKey;

Deno.test("processing-jobs requires a user session", async () => {
  const response = await post("processing-jobs", {}, {
    action: "allowances",
  });

  assertEquals(response.status, 401);
  await response.body?.cancel();
});

Deno.test("service-account requires a user session", async () => {
  const response = await post("service-account", {}, { action: "delete" });

  assertEquals(response.status, 401);
  await response.body?.cancel();
});

Deno.test("cleanup-processing-jobs requires the worker key", async () => {
  const response = await post(
    "cleanup-processing-jobs",
    { "x-mymenu-worker-key": "not-the-worker-key" },
    {},
  );

  assertEquals(response.status, 403);
  await response.body?.cancel();
});

Deno.test("process-ai-jobs requires the worker key", async () => {
  const response = await post(
    "process-ai-jobs",
    {
      Authorization: `Bearer ${serviceRoleKey}`,
      "x-mymenu-worker-key": "not-the-worker-key",
    },
    {},
  );

  assertEquals(response.status, 403);
  await response.body?.cancel();
});

Deno.test("process-ai-jobs accepts the dedicated worker key", async () => {
  const response = await post(
    "process-ai-jobs",
    { "x-mymenu-worker-key": aiWorkerKey },
    {},
  );

  assertEquals(response.status, 202);
  await response.body?.cancel();
});

function post(
  functionName: string,
  headers: Record<string, string>,
  body: unknown,
) {
  return fetch(`${baseUrl}/functions/v1/${functionName}`, {
    method: "POST",
    headers: { "Content-Type": "application/json", ...headers },
    body: JSON.stringify(body),
  });
}

function assertEquals(actual: unknown, expected: unknown) {
  if (actual !== expected) {
    throw new Error(`Expected ${expected}, got ${actual}`);
  }
}
