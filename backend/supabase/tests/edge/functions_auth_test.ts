const baseUrl = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";

Deno.test("preparePhotoUpload requires a user session", async () => {
  const response = await fetch(`${baseUrl}/functions/v1/preparePhotoUpload`, {
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

function assertEquals(actual: unknown, expected: unknown) {
  if (actual !== expected) {
    throw new Error(`Expected ${expected}, got ${actual}`);
  }
}

Deno.test("process_capture_async requires the worker key", async () => {
  const response = await fetch(
    `${baseUrl}/functions/v1/process_capture_async`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-mymenu-worker-key": "not-the-worker-key",
      },
      body: JSON.stringify({
        userId: "00000000-0000-4000-8000-000000000001",
        captureId: "10000000-0000-4000-8000-000000000011",
      }),
    },
  );

  assertEquals(response.status, 403);
  await response.body?.cancel();
});
