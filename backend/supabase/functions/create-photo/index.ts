import {
  handleOptions,
  json,
  optionalNumber,
  optionalString,
  readJson,
  requiredNumber,
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
    const batchId = requiredString(body, "batchId");
    const ordinal = requiredNumber(body, "ordinal");

    // Triggered after Flutter uploads the photo bytes to the signed Storage URL
    // from prepare-photo-upload. The route records the capture and image metadata
    // through the ordered batch overload of api_create_photo_capture. The
    // batch advances separately only after every item has uploaded.
    const result = await rpcOne(adminClient, "api_create_photo_capture", {
      p_user_id: userId,
      p_batch_id: batchId,
      p_capture_id: captureId,
      p_ordinal: ordinal,
      p_storage_path: requiredString(body, "storagePath"),
      p_content_type: requiredString(body, "contentType"),
      p_byte_size: optionalNumber(body, "byteSize"),
      p_width: optionalNumber(body, "width"),
      p_height: optionalNumber(body, "height"),
      p_sha256: optionalString(body, "sha256"),
      p_captured_at: optionalString(body, "capturedAt") ??
        new Date().toISOString(),
    });

    const storagePath = requiredString(body, "storagePath");
    return json({
      capture: {
        id: result.capture_id,
        kind: "photo",
        status: "uploaded",
        batchId,
        ordinal,
        imageId: result.image_id,
      },
      image: {
        id: result.image_id,
        kind: "capture_photo",
        mediaRef: `menu-media:${storagePath}`,
      },
      cursor: result.sync_cursor,
    });
  } catch (error) {
    console.error("create-photo failed", error);
    return json(
      { error: error instanceof Error ? error.message : "Server error" },
      500,
    );
  }
});
