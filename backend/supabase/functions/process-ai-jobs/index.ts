import { handleOptions, json, type JsonRecord } from "../_shared/http.ts";
import { requireEnv, supabaseFor } from "../_shared/supabase.ts";

const maxJobsPerInvocation = 10;

Deno.serve(async (request: Request) => {
  const options = handleOptions(request);
  if (options != null) {
    return options;
  }

  const serviceRoleKey = requireEnv("SUPABASE_SERVICE_ROLE_KEY");
  if (request.headers.get("x-mymenu-worker-key") !== serviceRoleKey) {
    return json({ error: "Forbidden" }, 403);
  }

  const client = supabaseFor(`Bearer ${serviceRoleKey}`, true);
  let processed = 0;
  let failed = 0;

  for (let index = 0; index < maxJobsPerInvocation; index += 1) {
    const job = await claimJob(client);
    if (job == null) {
      break;
    }

    const jobId = stringField(job, "id");
    const leaseToken = stringField(job, "lease_token");
    try {
      const { error } = await client.rpc(
        "internal_complete_capture_grouping_job",
        {
          p_job_id: jobId,
          p_lease_token: leaseToken,
        },
      );
      if (error != null) {
        throw error;
      }
      processed += 1;
    } catch (error) {
      failed += 1;
      const message = error instanceof Error ? error.message : String(error);
      const { error: failError } = await client.rpc("internal_fail_ai_job", {
        p_job_id: jobId,
        p_lease_token: leaseToken,
        p_retryable: isRetryable(message),
        p_normalized_error: {
          code: isRetryable(message)
            ? "capture_grouping_transient"
            : "capture_grouping_invalid",
          message,
        },
      });
      if (failError != null) {
        console.error("Failed to persist AI job failure", failError);
      }
    }
  }

  return json({ processed, failed });
});

async function claimJob(client: any): Promise<JsonRecord | null> {
  const { data, error } = await client.rpc("internal_claim_ai_job", {
    p_job_types: ["batch_grouping"],
  });
  if (error != null) {
    throw error;
  }
  if (!Array.isArray(data) || data.length === 0) {
    return null;
  }
  return data[0] as JsonRecord;
}

function stringField(row: JsonRecord, key: string) {
  const value = row[key];
  if (typeof value !== "string" || value.length === 0) {
    throw new Error(`Missing ${key} on claimed AI job`);
  }
  return value;
}

function isRetryable(message: string) {
  const normalized = message.toLowerCase();
  return !normalized.includes("no active captures") &&
    !normalized.includes("does not exist") &&
    !normalized.includes("not ready") &&
    !normalized.includes("invalid");
}
