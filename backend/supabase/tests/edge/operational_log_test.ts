import { sanitizeOperationalMetadata } from "../../functions/_shared/operational_log.ts";

Deno.test("routine processing metadata excludes fixture content and URLs", () => {
  const sanitized = sanitizeOperationalMetadata({
    action: "submit",
    operation: "capture_grouping",
    jobId: "opaque-job-id",
    status: 200,
    filename: "private-noodles.jpg",
    prompt: "Classify Private fixture noodles",
    signedUrl: "https://storage.example/private-token",
    providerBody: { private: "secret scallions" },
    menuText: "Never persist this fixture menu content",
  });

  assertEquals(sanitized, {
    action: "submit",
    operation: "capture_grouping",
    jobId: "opaque-job-id",
    status: 200,
  });
});

function assertEquals(actual: unknown, expected: unknown) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
