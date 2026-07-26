import { handleOptions, json, type JsonRecord } from "../_shared/http.ts";
import {
  AiProviderFailure,
  createGroupingProvider,
} from "../_shared/ai/grouping_provider.ts";
import type { GroupingCaptureInput } from "../_shared/ai/grouping_contract.ts";
import { requireAiWorkerKey } from "../_shared/ai/worker_config.ts";
import { requireEnv, supabaseFor } from "../_shared/supabase.ts";

declare const EdgeRuntime:
  | { waitUntil(promise: Promise<unknown>): void }
  | undefined;

Deno.serve(async (request: Request) => {
  const options = handleOptions(request);
  if (options != null) {
    return options;
  }

  if (
    request.headers.get("x-mymenu-worker-key") !==
      requireAiWorkerKey()
  ) {
    return json({ error: "Forbidden" }, 403);
  }

  const work = processOneJob();
  if (typeof EdgeRuntime !== "undefined") {
    EdgeRuntime.waitUntil(work);
    return json({ accepted: true }, 202);
  }

  return json(await work);
});

async function processOneJob() {
  const serviceRoleKey = requireEnv("SUPABASE_SERVICE_ROLE_KEY");
  const client = supabaseFor(`Bearer ${serviceRoleKey}`, true);
  const job = await claimJob(client);
  if (job == null) {
    return { processed: 0, failed: 0 };
  }

  const jobId = stringField(job, "id");
  const leaseToken = stringField(job, "lease_token");
  try {
    const captures = await loadGroupingInput(client, jobId, leaseToken);
    const provider = createGroupingProvider(
      stringField(job, "provider"),
      stringField(job, "model_version"),
    );
    const result = await provider.group(captures);
    const { error } = await client.rpc(
      "internal_apply_capture_grouping_job",
      {
        p_job_id: jobId,
        p_lease_token: leaseToken,
        p_normalized_result: {
          groups: result.output.groups,
          rejectedCaptures: result.output.rejectedCaptures,
          provenance: result.provenance,
        },
      },
    );
    if (error != null) {
      throw error;
    }
    return { processed: 1, failed: 0, jobId };
  } catch (error) {
    const failure = normalizeFailure(error);
    console.error(`AI job ${jobId} failed`, failure);
    const { error: failError } = await client.rpc("internal_fail_ai_job", {
      p_job_id: jobId,
      p_lease_token: leaseToken,
      p_retryable: failure.retryable,
      p_normalized_error: {
        code: failure.code,
        message: failure.message,
      },
    });
    if (failError != null) {
      console.error("Failed to persist AI job failure", failError);
    }
    return { processed: 0, failed: 1, jobId };
  }
}

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

async function loadGroupingInput(
  client: any,
  jobId: string,
  leaseToken: string,
): Promise<GroupingCaptureInput[]> {
  const { data, error } = await client.rpc(
    "internal_get_capture_grouping_input",
    {
      p_job_id: jobId,
      p_lease_token: leaseToken,
    },
  );
  if (error != null) {
    throw error;
  }
  if (!Array.isArray(data) || data.length === 0) {
    throw new AiProviderFailure(
      "capture_grouping_input_empty",
      "The capture batch has no active captures",
      false,
    );
  }

  return await Promise.all(data.map(async (value: unknown) => {
    const row = recordValue(value);
    const kind = stringField(row, "kind");
    if (kind !== "photo" && kind !== "idea") {
      throw new AiProviderFailure(
        "capture_kind_invalid",
        `Unsupported capture kind: ${kind}`,
        false,
      );
    }

    const capture: GroupingCaptureInput = {
      id: stringField(row, "capture_id"),
      ordinal: numberField(row, "ordinal"),
      kind,
      ideaText: nullableString(row.idea_text),
      capturedLocalDate: nullableString(row.captured_local_date),
    };
    if (kind === "photo") {
      const bucket = stringField(row, "storage_bucket");
      const path = stringField(row, "storage_path");
      const contentType = stringField(row, "content_type");
      const { data: signed, error: signedError } = await client.storage
        .from(bucket)
        .createSignedUrl(path, 300);
      if (signedError != null || signed?.signedUrl == null) {
        throw new AiProviderFailure(
          "capture_media_unavailable",
          `Could not read capture media ${capture.id}`,
          true,
          { cause: signedError ?? undefined },
        );
      }
      capture.media = {
        contentType,
        signedUrl: signed.signedUrl,
        filename: path.split("/").at(-1) ?? `${capture.id}.image`,
      };
    }
    return capture;
  }));
}

function normalizeFailure(error: unknown) {
  if (error instanceof AiProviderFailure) {
    return error;
  }
  const message = error instanceof Error ? error.message : String(error);
  const normalized = message.toLowerCase();
  const invalid = normalized.includes("exact partition") ||
    normalized.includes("invalid capture") ||
    normalized.includes("duplicate capture") ||
    normalized.includes("foreign capture") ||
    normalized.includes("omits capture") ||
    normalized.includes("no active capture");
  return new AiProviderFailure(
    invalid ? "capture_grouping_invalid" : "capture_grouping_worker_error",
    message,
    !invalid,
    error instanceof Error ? { cause: error } : undefined,
  );
}

function recordValue(value: unknown): JsonRecord {
  if (typeof value !== "object" || value == null || Array.isArray(value)) {
    throw new AiProviderFailure(
      "capture_grouping_input_invalid",
      "Capture grouping input row is invalid",
      false,
    );
  }
  return value as JsonRecord;
}

function stringField(row: JsonRecord, key: string) {
  const value = row[key];
  if (typeof value !== "string" || value.length === 0) {
    throw new AiProviderFailure(
      "capture_grouping_input_invalid",
      `Missing ${key}`,
      false,
    );
  }
  return value;
}

function numberField(row: JsonRecord, key: string) {
  const value = row[key];
  if (typeof value !== "number" || !Number.isInteger(value)) {
    throw new AiProviderFailure(
      "capture_grouping_input_invalid",
      `Missing ${key}`,
      false,
    );
  }
  return value;
}

function nullableString(value: unknown) {
  return typeof value === "string" ? value : null;
}
