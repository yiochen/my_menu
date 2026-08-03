import { sanitizeOperationalMetadata } from "../../functions/_shared/operational_log.ts";
import { rpcOne } from "../../functions/_shared/supabase.ts";

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

Deno.test("schema cache retries do not log raw database errors", async () => {
  const entries: unknown[][] = [];
  const originalLog = console.log;
  console.log = (...values: unknown[]) => entries.push(values);
  let calls = 0;
  try {
    await rpcOne(
      {
        rpc: () => {
          calls += 1;
          return calls === 1
            ? {
              data: null,
              error: {
                code: "PGRST002",
                message: "private-noodles.jpg signed URL secret",
              },
            }
            : { data: [{ id: "opaque-job-id" }], error: null };
        },
      },
      "internal_test_processing_job",
      {},
    );
  } finally {
    console.log = originalLog;
  }

  const output = JSON.stringify(entries);
  assertEquals(output.includes("private-noodles.jpg"), false);
  assertEquals(output.includes("signed URL secret"), false);
  assertEquals(output.includes("schema_cache_retry"), true);
});

function assertEquals(actual: unknown, expected: unknown) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
