import { titleFrom } from "../_shared/capture.ts";
import {
  handleOptions,
  json,
  optionalString,
  readJson,
  requiredString,
} from "../_shared/http.ts";
import { requireEnv, rpcOne, supabaseFor } from "../_shared/supabase.ts";

Deno.serve(async (request: Request) => {
  const options = handleOptions(request);
  if (options != null) {
    return options;
  }

  try {
    const workerKey = request.headers.get("x-mymenu-worker-key");
    const serviceRoleKey = requireEnv("SUPABASE_SERVICE_ROLE_KEY");
    if (workerKey !== serviceRoleKey) {
      return json({ error: "Forbidden" }, 403);
    }

    const body = await readJson(request);
    const userId = requiredString(body, "userId");
    const captureId = requiredString(body, "captureId");
    const ideaText = optionalString(body, "ideaText")?.trim();
    const adminClient = supabaseFor(`Bearer ${serviceRoleKey}`, true);

    // TODO: Replace this fake classifier with Gemini/OpenAI. The real worker
    // should inspect the capture media/idea, decide whether it can auto-apply,
    // and write either a dish draft or a review result for later sync.
    const title = titleFrom(ideaText ?? "Captured Dish");
    const dishId = crypto.randomUUID();
    const result = await rpcOne(adminClient, "api_create_dish_from_capture", {
      p_user_id: userId,
      p_capture_id: captureId,
      p_dish_id: dishId,
      p_title: title,
      p_description: "Fake AI draft from a synced capture.",
      p_labels: ["capture", "fake-ai"],
      p_confidence_label: "Fake AI",
    });

    return json({
      captureId,
      dishId,
      title,
      sourceImageId: result.source_image_id,
      cursor: result.sync_cursor,
    });
  } catch (error) {
    console.error("process_capture_async failed", error);
    return json(
      { error: error instanceof Error ? error.message : "Server error" },
      500,
    );
  }
});
