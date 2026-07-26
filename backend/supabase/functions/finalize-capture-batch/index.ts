import {
  handleOptions,
  json,
  type JsonRecord,
  optionalString,
  readJson,
  requiredNumber,
  requiredObject,
  requiredString,
} from "../_shared/http.ts";
import { batchGroupingContract } from "../_shared/ai/grouping_contract.ts";
import { requireAiWorkerKey } from "../_shared/ai/worker_config.ts";
import { requireEnv, requireUser, rpcOne } from "../_shared/supabase.ts";

Deno.serve(async (request: Request) => {
  const options = handleOptions(request);
  if (options != null) {
    return options;
  }

  try {
    const { adminClient, error, userId } = await requireUser(request);
    if (error != null) {
      return error;
    }

    const body = await readJson(request);
    const job = requiredObject(body, "job");
    const kind = requiredString(body, "kind");
    if (kind !== "photo" && kind !== "idea") {
      return json({ error: "kind must be photo or idea" }, 400);
    }

    const row = await rpcOne(
      adminClient,
      "internal_finalize_capture_batch_v2",
      {
        p_user_id: userId,
        p_batch_id: requiredString(body, "batchId"),
        p_kind: kind,
        p_idea_text: optionalString(body, "ideaText"),
        p_captured_at: optionalString(body, "capturedAt"),
        p_captured_local_date: optionalString(body, "capturedLocalDate"),
        p_capture_date_source: optionalString(body, "captureDateSource"),
        p_job_id: requiredString(job, "id"),
        p_idempotency_key: requiredString(job, "idempotencyKey"),
        p_input_hash: requiredString(job, "inputHash"),
        p_input_version: requiredString(job, "inputVersion"),
        p_provider: aiProvider(),
        p_prompt_version: batchGroupingContract.promptVersion,
        p_model_version: aiModel(),
        p_schema_version: batchGroupingContract.schemaVersion,
        p_max_attempts: requiredNumber(job, "maxAttempts"),
      },
    );

    await rpcOneValue(adminClient, "internal_enqueue_ai_worker", {
      p_function_url: `${
        requireEnv("SUPABASE_URL")
      }/functions/v1/process-ai-jobs`,
      p_worker_key: requireAiWorkerKey(),
    });

    return json({ job: row });
  } catch (error) {
    console.error("finalize-capture-batch failed", error);
    return json(
      { error: error instanceof Error ? error.message : "Server error" },
      500,
    );
  }
});

function aiProvider() {
  return (Deno.env.get("AI_PROVIDER") ?? "fake").trim().toLowerCase();
}

function aiModel() {
  const configured = Deno.env.get("AI_MODEL")?.trim();
  if (configured != null && configured.length > 0) {
    return configured;
  }
  return aiProvider() === "google"
    ? "gemini-3.6-flash"
    : "fake-date-grouper-v2";
}

async function rpcOneValue(
  client: any,
  name: string,
  args: JsonRecord,
) {
  const { data, error } = await client.rpc(name, args);
  if (error != null) {
    throw error;
  }
  return data;
}
