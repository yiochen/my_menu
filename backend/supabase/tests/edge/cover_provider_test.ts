import { inspectImageIntegrity } from "../../functions/_shared/ai/image_integrity.ts";
import { encode as encodePng } from "npm:fast-png@7.0.1";

Deno.test("cover integrity rejects truncated and undersized images", () => {
  assertEquals(
    inspectImageIntegrity(new Uint8Array([0x89, 0x50]), "image/png").valid,
    false,
  );
  assertEquals(
    inspectImageIntegrity(pngFixture(1, 1), "image/png").valid,
    false,
  );
});

Deno.test("cover integrity accepts a complete bounded PNG structure", () => {
  const result = inspectImageIntegrity(pngFixture(1024, 768), "image/png");
  assertEquals(result.valid, true);
  assertEquals(result.width, 1024);
  assertEquals(result.height, 768);
});

Deno.test("cover integrity rejects corrupted encoded image data", () => {
  const bytes = pngFixture(256, 256);
  const idat = findChunk(bytes, "IDAT");
  bytes[idat + 4] ^= 0xff;
  assertEquals(inspectImageIntegrity(bytes, "image/png").valid, false);
});

function pngFixture(width: number, height: number) {
  return encodePng({
    width,
    height,
    data: new Uint8Array(width * height * 4).fill(180),
  });
}

function findChunk(bytes: Uint8Array, type: string) {
  const expected = [...type].map((value) => value.charCodeAt(0));
  for (let index = 0; index <= bytes.length - 4; index += 1) {
    if (expected.every((value, offset) => bytes[index + offset] === value)) {
      return index;
    }
  }
  throw new Error(`Missing ${type} chunk`);
}

function assertEquals(actual: unknown, expected: unknown) {
  if (actual !== expected) {
    throw new Error(`Expected ${String(expected)}, got ${String(actual)}`);
  }
}
