import { requireAiWorkerKey } from "../_shared/ai/worker_config.ts";
import {
  handleOptions,
  json,
  type JsonRecord,
  readJson,
  requiredObject,
  requiredString,
} from "../_shared/http.ts";
import {
  operationalError,
  operationalLog,
} from "../_shared/operational_log.ts";
import type {
  ProcessingPolicy,
  ProcessingPolicyProvider,
} from "../_shared/processing_policy.ts";
import { requireEnv, requireUser, rpcOne } from "../_shared/supabase.ts";

export function createProcessingJobsHandler(
  policyProvider: ProcessingPolicyProvider,
) {
  return async (request: Request) => {
    const options = handleOptions(request);
    if (options != null) return options;

    const started = Date.now();
    let action = "unknown";
    try {
      const { adminClient, error, userId } = await requireUser(request);
      if (error != null) return error;
      const body = await readJson(request);
      action = requiredString(body, "action");
      const response = await dispatch(
        adminClient,
        userId,
        action,
        body,
        policyProvider,
      );
      operationalLog("processing_job_request", {
        action,
        durationMs: Date.now() - started,
        status: response.status,
      });
      return response;
    } catch (error) {
      const code = errorCode(error);
      operationalError("processing_job_request_failed", code, {
        action,
        durationMs: Date.now() - started,
      });
      return json({ error: code }, errorStatus(code));
    } finally {
      try {
        await policyProvider.flush();
      } catch {
        // Policy exposure logging cannot alter an already-computed response.
      }
    }
  };
}

async function dispatch(
  client: any,
  userId: string,
  action: string,
  body: JsonRecord,
  policyProvider: ProcessingPolicyProvider,
) {
  switch (action) {
    case "create": {
      const policy = await processingPolicy(client, userId, policyProvider);
      return await createJob(client, userId, body, policy);
    }
    case "submit":
      return await submitJob(client, userId, body);
    case "status":
      return await statusJob(client, userId, body);
    case "result":
      return await resultJob(client, userId, body);
    case "acknowledge":
      return await finishJob(client, userId, body, "acknowledged");
    case "cancel":
      return await finishJob(client, userId, body, "canceled");
    case "allowances": {
      const policy = await processingPolicy(client, userId, policyProvider);
      return await allowances(client, userId, policy);
    }
    default:
      return json({ error: "invalid_action" }, 400);
  }
}

async function processingPolicy(
  client: any,
  userId: string,
  policyProvider: ProcessingPolicyProvider,
) {
  const { data, error } = await client.from("service_entitlements")
    .select("plan_key,status")
    .eq("user_id", userId)
    .maybeSingle();
  if (error != null) throw error;
  const planKey = data?.status === "active" &&
      typeof data.plan_key === "string" && data.plan_key.length > 0
    ? data.plan_key
    : "free";
  return await policyProvider.evaluate({ userId, planKey });
}

async function allowances(
  client: any,
  userId: string,
  policy: ProcessingPolicy,
) {
  const { data, error } = await client.rpc(
    "internal_get_processing_allowances",
    {
      p_user_id: userId,
      p_capture_grouping_limit_units: policy.captureOrganizationLimit,
      p_capture_grouping_bypass: policy.captureOrganizationBypass,
      p_cover_generation_limit_units: policy.dishCoverLimit,
      p_cover_generation_bypass: policy.dishCoverBypass,
    },
  );
  if (error != null) throw error;
  const rows = (data ?? []) as JsonRecord[];
  const organization = rows.find((row) => row.operation === "capture_grouping");
  const cover = rows.find((row) => row.operation === "cover_generation");
  if (organization == null || cover == null) {
    throw new Error("processing_allowance_status_unavailable");
  }
  return json({
    organization: allowanceEnvelope(organization),
    cover: allowanceEnvelope(cover),
  });
}

function allowanceEnvelope(row: JsonRecord) {
  return {
    status: row.status,
    enforced: row.enforcement_enabled,
    used: row.used_units,
    limit: row.limit_units,
    remaining: row.remaining_units,
  };
}

async function createJob(
  client: any,
  userId: string,
  body: JsonRecord,
  policy: ProcessingPolicy,
) {
  const assets = body.assets;
  if (!Array.isArray(assets)) {
    return json({ error: "invalid_assets" }, 400);
  }
  const operation = requiredString(body, "operation");
  const allowance = operationAllowance(operation, policy);
  const row = await rpcOne(client, "internal_create_processing_job", {
    p_user_id: userId,
    p_operation: operation,
    p_idempotency_key: requiredString(body, "idempotencyKey"),
    p_input_schema_version: requiredString(body, "inputSchemaVersion"),
    p_result_schema_version: requiredString(body, "resultSchemaVersion"),
    p_privacy_notice_version: requiredString(body, "privacyNoticeVersion"),
    p_assets: assets,
    p_limit_units: allowance.limit,
    p_allowance_bypass: allowance.bypass,
  });
  const { data: assetRows, error: assetError } = await client
    .from("processing_assets")
    .select("asset_id,storage_path,content_type")
    .eq("job_id", row.id)
    .order("asset_id");
  if (assetError != null) throw assetError;
  const uploadTargets = await Promise.all(
    (assetRows ?? []).map(async (asset: JsonRecord) => {
      const { data, error } = await client.storage
        .from("processing-media")
        .createSignedUploadUrl(String(asset.storage_path), { upsert: true });
      if (error != null) throw error;
      return {
        assetId: asset.asset_id,
        storagePath: asset.storage_path,
        token: data.token,
        contentType: asset.content_type,
      };
    }),
  );
  return json({ job: jobEnvelope(row), uploadTargets });
}

function operationAllowance(operation: string, policy: ProcessingPolicy) {
  if (operation === "capture_grouping") {
    return {
      limit: policy.captureOrganizationLimit,
      bypass: policy.captureOrganizationBypass,
    };
  }
  if (operation === "cover_generation") {
    return { limit: policy.dishCoverLimit, bypass: policy.dishCoverBypass };
  }
  throw new Error("Invalid processing operation");
}

async function submitJob(client: any, userId: string, body: JsonRecord) {
  const row = await rpcOne(client, "internal_submit_processing_job", {
    p_user_id: userId,
    p_job_id: requiredString(body, "jobId"),
    p_input: requiredObject(body, "input"),
  });
  await enqueueWorker(client);
  return json({ job: jobEnvelope(row) });
}

async function statusJob(client: any, userId: string, body: JsonRecord) {
  const row = await ownedJob(client, userId, requiredString(body, "jobId"));
  return json({ job: jobEnvelope(row) });
}

async function resultJob(client: any, userId: string, body: JsonRecord) {
  const row = await ownedJob(client, userId, requiredString(body, "jobId"));
  if (row.status !== "succeeded" || row.result_payload == null) {
    return json({ error: "result_unavailable" }, 409);
  }
  return json({ result: row.result_payload as JsonRecord });
}

async function finishJob(
  client: any,
  userId: string,
  body: JsonRecord,
  status: "acknowledged" | "canceled",
) {
  const jobId = requiredString(body, "jobId");
  const { data: assets, error: assetError } = await client
    .from("processing_assets")
    .select("storage_path")
    .eq("job_id", jobId)
    .eq("user_id", userId);
  if (assetError != null) throw assetError;
  const paths = (assets ?? []).map((asset: JsonRecord) =>
    String(asset.storage_path)
  );
  if (paths.length > 0) {
    const { error } = await client.storage.from("processing-media").remove(
      paths,
    );
    if (error != null) throw error;
  }
  const row = await rpcOne(client, "internal_finish_processing_job", {
    p_user_id: userId,
    p_job_id: jobId,
    p_status: status,
  });
  return json({ job: jobEnvelope(row) });
}

async function ownedJob(client: any, userId: string, jobId: string) {
  const { data, error } = await client.from("processing_jobs").select("*")
    .eq("id", jobId).eq("user_id", userId).single();
  if (error != null) {
    if (error.code === "PGRST116") {
      throw new Error("processing_job_not_found");
    }
    throw error;
  }
  return data as JsonRecord;
}

async function enqueueWorker(client: any) {
  const { error } = await client.rpc("internal_enqueue_ai_worker", {
    p_function_url: `${
      requireEnv("SUPABASE_URL")
    }/functions/v1/process-ai-jobs`,
    p_worker_key: requireAiWorkerKey(),
  });
  if (error != null) throw error;
}

function jobEnvelope(row: JsonRecord) {
  return {
    id: row.id,
    operation: row.operation,
    idempotencyKey: row.idempotency_key,
    status: row.status,
    inputSchemaVersion: row.input_schema_version,
    resultSchemaVersion: row.result_schema_version,
    expiresAt: row.expires_at,
    errorCode: row.error_code,
  };
}

function errorCode(error: unknown) {
  const message = error instanceof Error
    ? error.message
    : typeof error === "object" && error != null && "message" in error
    ? String((error as { message: unknown }).message)
    : String(error);
  if (message.includes("processing_policy_unavailable")) {
    return "processing_policy_unavailable";
  }
  if (message.includes("free_allowance_exhausted")) {
    return "free_allowance_exhausted";
  }
  if (
    message.includes("processing_job_not_found") ||
    message.includes("Processing job not found")
  ) {
    return "processing_job_not_found";
  }
  if (message.includes("Invalid") || message.includes("Missing required")) {
    return "invalid_request";
  }
  return "processing_request_failed";
}

function errorStatus(code: string) {
  if (code === "processing_policy_unavailable") return 503;
  if (code === "free_allowance_exhausted") return 429;
  if (code === "processing_job_not_found") return 404;
  if (code.startsWith("invalid_")) return 400;
  return 500;
}
