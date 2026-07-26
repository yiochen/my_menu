import {
  handleOptions,
  json,
  readJson,
  requiredStringArray,
} from "../_shared/http.ts";
import { imageDto } from "../_shared/media.ts";
import { requireUser } from "../_shared/supabase.ts";

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
    const ids = requiredStringArray(body, "ids");
    if (ids.length === 0) {
      return json({ items: [], missingIds: [] });
    }

    const { data: captureData, error: captureError } = await adminClient
      .from("captures")
      .select(
        "id, batch_id, ordinal, kind, status, idea_text, applied_dish_id, failure_reason, captured_at",
      )
      .eq("user_id", userId)
      .in("id", ids)
      .is("deleted_at", null);

    if (captureError != null) {
      throw captureError;
    }

    const captures = (captureData ?? []) as Array<Record<string, unknown>>;
    const captureIds = captures.map((row) => stringValue(row, "id"));
    const imagesByCaptureId = new Map<string, Record<string, unknown>>();

    if (captureIds.length > 0) {
      const { data: imageData, error: imageError } = await adminClient
        .from("dish_images")
        .select(
          "id, capture_id, kind, storage_bucket, storage_path, captured_at, created_at",
        )
        .eq("user_id", userId)
        .in("capture_id", captureIds)
        .is("deleted_at", null)
        .order("captured_at", { ascending: false, nullsFirst: false })
        .order("created_at", { ascending: false });

      if (imageError != null) {
        throw imageError;
      }

      for (const row of (imageData ?? []) as Array<Record<string, unknown>>) {
        const captureId = stringValue(row, "capture_id");
        if (!imagesByCaptureId.has(captureId)) {
          imagesByCaptureId.set(captureId, row);
        }
      }
    }

    const items = [];
    for (const row of captures) {
      const id = stringValue(row, "id");
      const image = imagesByCaptureId.get(id);
      items.push({
        id,
        batchId: optionalStringValue(row, "batch_id"),
        ordinal: optionalNumberValue(row, "ordinal"),
        kind: stringValue(row, "kind"),
        status: stringValue(row, "status"),
        ideaText: optionalStringValue(row, "idea_text"),
        appliedDishId: optionalStringValue(row, "applied_dish_id"),
        failureReason: optionalStringValue(row, "failure_reason"),
        capturedAt: stringValue(row, "captured_at"),
        image: image == null ? null : await imageDto(adminClient, image),
      });
    }

    const foundIds = new Set(captureIds);
    return json({
      items,
      missingIds: ids.filter((id) => !foundIds.has(id)),
    });
  } catch (error) {
    console.error("get-captures failed", error);
    return json(
      { error: error instanceof Error ? error.message : "Server error" },
      500,
    );
  }
});

function stringValue(row: Record<string, unknown>, key: string) {
  const value = row[key];
  if (typeof value !== "string" || value.length === 0) {
    throw new Error(`Expected string at ${key}`);
  }
  return value;
}

function optionalStringValue(row: Record<string, unknown>, key: string) {
  const value = row[key];
  return typeof value === "string" ? value : null;
}

function optionalNumberValue(row: Record<string, unknown>, key: string) {
  const value = row[key];
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}
