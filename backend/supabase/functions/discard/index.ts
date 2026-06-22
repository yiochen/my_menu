import {
  handleOptions,
  json,
  readJson,
  requiredString,
} from "../_shared/http.ts";
import { requireUser, rpcOne } from "../_shared/supabase.ts";

Deno.serve(async (request: Request) => {
  const options = handleOptions(request);
  if (options != null) {
    return options;
  }

  try {
    const { error, userId, adminClient } = await requireUser(request);
    if (error != null) {
      return error;
    }

    const body = await readJson(request);
    const captureId = requiredString(body, "captureId");

    // Triggered when the user rejects a capture from review. The route calls
    // api_discard_capture so sync and review flows stop processing it.
    const result = await rpcOne(adminClient, "api_discard_capture", {
      p_user_id: userId,
      p_capture_id: captureId,
    });

    return json({
      captureId,
      status: "discarded",
      cursor: result.sync_cursor,
    });
  } catch (error) {
    console.error("discard failed", error);
    return json(
      { error: error instanceof Error ? error.message : "Server error" },
      500,
    );
  }
});
