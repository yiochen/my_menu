import { extensionFor } from "../_shared/capture.ts";
import {
  handleOptions,
  json,
  readJson,
  requiredString,
} from "../_shared/http.ts";
import { requireUser } from "../_shared/supabase.ts";

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
    const contentType = requiredString(body, "contentType");
    const extension = extensionFor(contentType);
    const storagePath =
      `users/${userId}/captures/${captureId}/original.${extension}`;

    // Triggered when the user takes or selects a photo in Flutter. The client
    // calls this before uploading bytes so the server can choose the
    // user-scoped Storage path and return a signed upload URL. This route
    // intentionally does not create database rows; create-photo records metadata
    // after upload succeeds.
    const { data, error: uploadError } = await adminClient.storage
      .from("menu-media")
      .createSignedUploadUrl(storagePath);

    if (uploadError != null) {
      throw uploadError;
    }

    return json({
      captureId,
      storageBucket: "menu-media",
      storagePath,
      upload: {
        signedUrl: data.signedUrl,
        token: data.token,
        path: data.path,
      },
    });
  } catch (error) {
    console.error("prepare-photo-upload failed", error);
    return json(
      { error: error instanceof Error ? error.message : "Server error" },
      500,
    );
  }
});
