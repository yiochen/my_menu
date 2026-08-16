import { buildRoutingContent } from "../../functions/_shared/ai/routing_content.ts";

Deno.test("routing content sends processing photos as inline bytes", async () => {
  const expected = new Uint8Array([0xff, 0xd8, 0xff, 0xd9]);
  let loadCount = 0;
  const content = await buildRoutingContent([
    {
      id: "70c8ba83-908f-46e8-b49c-3b72b8f1191a",
      ordinal: 0,
      kind: "photo",
      ideaText: null,
      capturedLocalDate: "2026-08-11",
      media: {
        contentType: "image/jpeg",
        filename: "processing.jpg",
        loadBytes: () => {
          loadCount += 1;
          return Promise.resolve(expected);
        },
      },
    },
  ], []);

  const file = content.find((part) => part.type === "file");
  assertEquals(loadCount, 1);
  if (!(file?.data instanceof Uint8Array)) {
    throw new Error("expected inline Uint8Array data");
  }
  assertEquals(
    JSON.stringify([...file.data]),
    JSON.stringify([...expected]),
  );
});

function assertEquals(actual: unknown, expected: unknown) {
  if (actual !== expected) {
    throw new Error(`Expected ${String(expected)}, got ${String(actual)}`);
  }
}
