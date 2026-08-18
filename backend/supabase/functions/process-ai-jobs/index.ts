import { handleOptions, json, type JsonRecord } from "../_shared/http.ts";
import {
  AiProviderFailure,
  createGroupingProvider,
} from "../_shared/ai/grouping_provider.ts";
import type { GroupingCaptureInput } from "../_shared/ai/grouping_contract.ts";
import { createRoutingProvider } from "../_shared/ai/routing_provider.ts";
import type { RoutingDishInput } from "../_shared/ai/routing_contract.ts";
import {
  type CoverSourceInput,
  createCoverProvider,
} from "../_shared/ai/cover_provider.ts";
import { requireAiWorkerKey } from "../_shared/ai/worker_config.ts";
import {
  operationalError,
  operationalLog,
} from "../_shared/operational_log.ts";
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
  const processingJob = await claimProcessingJob(client);
  if (processingJob != null) {
    return await processProcessingJob(client, processingJob);
  }
  return { processed: 0, failed: 0 };
}

async function claimProcessingJob(client: any): Promise<JsonRecord | null> {
  const { data, error } = await client.rpc("internal_claim_processing_job");
  if (error != null) {
    if (String(error.message ?? error).includes("does not exist")) {
      return null;
    }
    throw error;
  }
  if (!Array.isArray(data) || data.length === 0) {
    return null;
  }
  return data[0] as JsonRecord;
}

async function processProcessingJob(client: any, job: JsonRecord) {
  const jobId = stringField(job, "id");
  const leaseToken = stringField(job, "lease_token");
  try {
    const input = recordValue(job.input_payload);
    if (stringField(job, "operation") === "cover_generation") {
      return await processCoverJob(client, job, input);
    }
    const captures = await processingCaptures(client, jobId, input);
    if (
      stringField(job, "result_schema_version") === "capture-grouping-result-v2"
    ) {
      return await processRoutingJob(
        client,
        job,
        captures,
        processingDishes(input),
      );
    }
    const provider = createGroupingProvider(
      Deno.env.get("AI_PROVIDER") ?? "fake",
      Deno.env.get("AI_MODEL") ?? "fake-date-grouper-v2",
    );
    const grouped = await provider.group(captures);
    const result = {
      operation: "capture_grouping",
      schemaVersion: stringField(job, "result_schema_version"),
      groups: grouped.output.groups.map((group) => ({
        captureIds: group.captureIds,
        proposal: {
          type: "new_dish",
          title: group.draft.title,
          description: group.draft.description,
          labels: group.draft.labels,
          visibleIngredients: group.draft.visibleIngredients,
        },
        confidence: group.uncertainty.length === 0 ? 1 : 0.5,
        evidence: group.evidence,
        uncertainty: group.uncertainty,
      })),
      rejectedCaptures: grouped.output.rejectedCaptures,
      provenance: grouped.provenance,
    };
    const usage = grouped.provenance.usage;
    const { error } = await client.rpc("internal_complete_processing_job", {
      p_job_id: jobId,
      p_lease_token: leaseToken,
      p_result: result,
      p_provider: grouped.provenance.provider,
      p_model: grouped.provenance.model,
      p_input_tokens: numericUsage(usage, "inputTokens"),
      p_output_tokens: numericUsage(usage, "outputTokens"),
    });
    if (error != null) {
      throw error;
    }
    operationalLog("processing_job_succeeded", {
      jobId,
      operation: "capture_grouping",
      model: grouped.provenance.model,
      state: "succeeded",
    });
    return { processed: 1, failed: 0, jobId };
  } catch (error) {
    const failure = normalizeFailure(error);
    operationalError("processing_job_failed", failure.code, {
      jobId,
      operation: "capture_grouping",
      state: "failed",
    });
    const { error: failError } = await client.rpc(
      "internal_fail_processing_job",
      {
        p_job_id: jobId,
        p_lease_token: leaseToken,
        p_error_code: failure.code,
        p_retryable: failure.retryable,
      },
    );
    if (failError != null) {
      operationalError(
        "processing_job_failure_persist_failed",
        "persist_failed",
        { jobId },
      );
    }
    return { processed: 0, failed: 1, jobId };
  }
}

async function processCoverJob(
  client: any,
  job: JsonRecord,
  input: JsonRecord,
) {
  const jobId = stringField(job, "id");
  const leaseToken = stringField(job, "lease_token");
  const sources = await processingCoverSources(client, jobId, input);
  const notes = arrayField(input, "notes").map((value) => {
    const note = recordValue(value);
    return {
      body: stringField(note, "body"),
      position: numberField(note, "position"),
      createdAt: stringField(note, "createdAt"),
      updatedAt: stringField(note, "updatedAt"),
    };
  });
  const treatment = recordValue(input.treatment);
  const provider = createCoverProvider(
    Deno.env.get("AI_IMAGE_PROVIDER") ?? Deno.env.get("AI_PROVIDER") ?? "fake",
    Deno.env.get("AI_IMAGE_MODEL") ?? "gemini-3.1-flash-image",
  );
  const origin = stringField(input, "origin");
  const generated = await provider.generate({
    dishTitle: stringField(input, "dishTitle"),
    origin: origin === "automatic" ? "automatic" : "manual",
    notes,
    treatment: {
      look: stringField(treatment, "look"),
      view: stringField(treatment, "view"),
      finish: stringField(treatment, "finish"),
    },
    sources,
  });
  if (!generated.validation.valid) {
    throw new AiProviderFailure(
      "cover_validation_failed",
      "Generated cover failed validation",
      false,
    );
  }
  const result = {
    operation: "cover_generation",
    schemaVersion: "cover-generation-result-v1",
    proposalId: crypto.randomUUID(),
    output: {
      contentType: generated.contentType,
      imageBase64: bytesToBase64(generated.bytes),
    },
    validation: generated.validation,
    provenance: generated.provenance,
  };
  const { error } = await client.rpc("internal_complete_processing_job", {
    p_job_id: jobId,
    p_lease_token: leaseToken,
    p_result: result,
    p_provider: generated.provenance.provider,
    p_model: generated.provenance.model,
    p_input_tokens: numericUsage(generated.provenance.usage, "inputTokens"),
    p_output_tokens: numericUsage(generated.provenance.usage, "outputTokens"),
  });
  if (error != null) throw error;
  operationalLog("processing_job_succeeded", {
    jobId,
    operation: "cover_generation",
    model: generated.provenance.model,
    state: "succeeded",
  });
  return { processed: 1, failed: 0, jobId };
}

async function processingCoverSources(
  client: any,
  jobId: string,
  input: JsonRecord,
): Promise<CoverSourceInput[]> {
  const values = arrayField(input, "sources");
  const { data: rows, error } = await client.from("processing_assets")
    .select("asset_id,storage_bucket,storage_path,content_type").eq(
      "job_id",
      jobId,
    );
  if (error != null) throw error;
  const assets = new Map<string, JsonRecord>(
    (rows ?? []).map((row: JsonRecord) => [String(row.asset_id), row]),
  );
  return await Promise.all(values.map(async (value) => {
    const source = recordValue(value);
    const asset = assets.get(stringField(source, "assetId"));
    if (asset == null) {
      throw new AiProviderFailure(
        "cover_source_unavailable",
        "Source is unavailable",
        false,
      );
    }
    const { data, error: signedError } = await client.storage
      .from(stringField(asset, "storage_bucket"))
      .createSignedUrl(stringField(asset, "storage_path"), 300);
    if (signedError != null || data?.signedUrl == null) {
      throw new AiProviderFailure(
        "cover_source_unavailable",
        "Source is unavailable",
        true,
      );
    }
    return {
      id: stringField(source, "id"),
      contentType: stringField(asset, "content_type"),
      signedUrl: data.signedUrl,
    };
  }));
}

function bytesToBase64(bytes: Uint8Array) {
  let binary = "";
  for (let offset = 0; offset < bytes.length; offset += 0x8000) {
    binary += String.fromCharCode(...bytes.subarray(offset, offset + 0x8000));
  }
  return btoa(binary);
}

async function processRoutingJob(
  client: any,
  job: JsonRecord,
  captures: GroupingCaptureInput[],
  dishes: RoutingDishInput[],
) {
  const jobId = stringField(job, "id");
  const leaseToken = stringField(job, "lease_token");
  const provider = createRoutingProvider(
    Deno.env.get("AI_PROVIDER") ?? "fake",
    Deno.env.get("AI_MODEL") ?? "fake-context-router-v2",
  );
  const routed = await provider.route(captures, dishes);
  const result = {
    operation: "capture_grouping",
    schemaVersion: stringField(job, "result_schema_version"),
    decisions: routed.output.decisions,
    provenance: routed.provenance,
  };
  const usage = routed.provenance.usage;
  const { error } = await client.rpc("internal_complete_processing_job", {
    p_job_id: jobId,
    p_lease_token: leaseToken,
    p_result: result,
    p_provider: routed.provenance.provider,
    p_model: routed.provenance.model,
    p_input_tokens: numericUsage(usage, "inputTokens"),
    p_output_tokens: numericUsage(usage, "outputTokens"),
  });
  if (error != null) throw error;
  operationalLog("processing_job_succeeded", {
    jobId,
    operation: "capture_grouping",
    model: routed.provenance.model,
    state: "succeeded",
  });
  return { processed: 1, failed: 0, jobId };
}

async function processingCaptures(
  client: any,
  jobId: string,
  input: JsonRecord,
): Promise<GroupingCaptureInput[]> {
  const values = arrayField(input, "captures");
  arrayField(input, "dishes");
  const { data: assetRows, error } = await client
    .from("processing_assets")
    .select("asset_id,storage_bucket,storage_path,content_type")
    .eq("job_id", jobId);
  if (error != null) {
    throw error;
  }
  const assets = new Map<string, JsonRecord>(
    (assetRows ?? []).map((row: JsonRecord) => [String(row.asset_id), row]),
  );
  return await Promise.all(values.map(async (value) => {
    const row = recordValue(value);
    const kind = stringField(row, "kind");
    if (kind !== "photo" && kind !== "idea") {
      throw new AiProviderFailure(
        "capture_kind_invalid",
        "Capture kind is invalid",
        false,
      );
    }
    const capture: GroupingCaptureInput = {
      id: stringField(row, "id"),
      ordinal: numberField(row, "ordinal"),
      kind,
      ideaText: nullableString(row.ideaText),
      capturedLocalDate: nullableString(row.capturedLocalDate),
    };
    if (kind === "photo") {
      const assetId = stringField(row, "assetId");
      const asset = assets.get(assetId);
      if (asset == null) {
        throw new AiProviderFailure(
          "capture_media_unavailable",
          "Capture media is unavailable",
          false,
        );
      }
      const bucket = stringField(asset, "storage_bucket");
      const path = stringField(asset, "storage_path");
      capture.media = {
        contentType: stringField(asset, "content_type"),
        filename: `${assetId}.image`,
        loadBytes: processingAssetByteLoader(
          client,
          bucket,
          path,
          capture.id,
        ),
      };
    }
    return capture;
  }));
}

function processingDishes(input: JsonRecord): RoutingDishInput[] {
  return arrayField(input, "dishes").map((value) => {
    const row = recordValue(value);
    return {
      localId: stringField(row, "localId"),
      title: stringField(row, "title"),
      description: typeof row.description === "string" ? row.description : "",
      ingredients: stringArrayField(row, "ingredients"),
      recipeSteps: stringArrayField(row, "recipeSteps"),
      notes: stringArrayField(row, "notes"),
    };
  });
}

function arrayField(row: JsonRecord, key: string) {
  const value = row[key];
  if (!Array.isArray(value)) {
    throw new AiProviderFailure(
      "capture_grouping_input_invalid",
      "Capture grouping input is invalid",
      false,
    );
  }
  return value;
}

function numericUsage(usage: Record<string, unknown>, key: string) {
  const value = usage[key];
  return typeof value === "number" && Number.isInteger(value) ? value : null;
}

function stringArrayField(row: JsonRecord, key: string) {
  return arrayField(row, key).map((value) => {
    if (typeof value !== "string") {
      throw new AiProviderFailure(
        "capture_grouping_input_invalid",
        `Invalid ${key}`,
        false,
      );
    }
    return value;
  });
}

function processingAssetByteLoader(
  client: any,
  bucket: string,
  path: string,
  captureId: string,
): () => Promise<Uint8Array> {
  return async () => {
    const { data, error } = await client.storage.from(bucket).download(path);
    if (error != null || data == null) {
      throw new AiProviderFailure(
        "capture_media_unavailable",
        `Could not read capture media ${captureId}`,
        true,
        { cause: error ?? undefined },
      );
    }
    return new Uint8Array(await data.arrayBuffer());
  };
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
