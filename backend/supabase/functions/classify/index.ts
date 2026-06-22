import {
  handleOptions,
  json,
  optionalString,
  readJson,
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
    const captureId = requiredString(body, "captureId");

    // Triggered when the app asks the backend to classify a capture. This route
    // records that processing has started and asks Postgres to enqueue the
    // process_capture_async worker through pg_net after the transaction commits.
    const result = await rpcOne(
      adminClient,
      "api_schedule_capture_processing",
      {
        p_user_id: userId,
        p_capture_id: captureId,
        p_function_url: `${
          requireEnv("SUPABASE_URL")
        }/functions/v1/process_capture_async`,
        p_worker_key: requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
        p_remote_media_ref: optionalString(body, "remoteMediaRef"),
        p_idea_text: optionalString(body, "ideaText"),
      },
    );

    return json({
      captureId,
      status: result.status,
      started: true,
      requestId: result.request_id,
      cursor: result.sync_cursor,
    });
  } catch (error) {
    console.error("classify failed", error);
    return json(
      { error: error instanceof Error ? error.message : "Server error" },
      500,
    );
  }
});
