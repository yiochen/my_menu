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
      "internal_finalize_capture_batch",
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
        p_max_attempts: requiredNumber(job, "maxAttempts"),
      },
    );

    await rpcOneValue(adminClient, "internal_enqueue_ai_worker", {
      p_function_url: `${
        requireEnv("SUPABASE_URL")
      }/functions/v1/process-ai-jobs`,
      p_worker_key: requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
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
