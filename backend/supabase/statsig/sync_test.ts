import { syncManifest, validateManifest } from "./sync.ts";

Deno.test("sync creates missing definitions and patches existing ones", async () => {
  const requests: Array<{ method: string; url: string; body: unknown }> = [];
  const fetcher: typeof fetch = (input, init) => {
    const url = String(input);
    const method = init?.method ?? "GET";
    const body = typeof init?.body === "string" ? JSON.parse(init.body) : null;
    requests.push({ method, url, body });
    if (method === "GET" && url.endsWith("/new_gate")) {
      return Promise.resolve(new Response("not found", { status: 404 }));
    }
    return Promise.resolve(Response.json({ data: {} }));
  };
  const manifest = validateManifest({
    gates: [{
      id: "new_gate",
      name: "New gate",
      description: "new",
      isEnabled: true,
    }],
    dynamicConfigs: [{
      id: "existing_config",
      name: "Existing config",
      description: "existing",
      isEnabled: true,
      defaultValue: { limit: 10 },
    }],
  });

  await syncManifest(manifest, "console-test", fetcher);

  assertEquals(requests.map((request) => request.method), [
    "GET",
    "POST",
    "GET",
    "PATCH",
  ]);
  assertEquals(
    (requests[1].body as Record<string, unknown>).rules,
    [],
  );
  assertEquals(
    "rules" in (requests[3].body as Record<string, unknown>),
    false,
  );
});

Deno.test("sync leaves matching definitions unchanged", async () => {
  const methods: string[] = [];
  const definition = {
    id: "matching_gate",
    name: "Matching gate",
    description: "already current",
    isEnabled: true,
  };
  const fetcher: typeof fetch = (_input, init) => {
    methods.push(init?.method ?? "GET");
    return Promise.resolve(Response.json({ data: definition }));
  };

  await syncManifest(
    validateManifest({ gates: [definition], dynamicConfigs: [] }),
    "console-test",
    fetcher,
  );

  assertEquals(methods, ["GET"]);
});

function assertEquals(actual: unknown, expected: unknown) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
