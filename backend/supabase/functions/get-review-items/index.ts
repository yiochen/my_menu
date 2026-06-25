import {
  handleOptions,
  json,
  readJson,
  requiredStringArray,
} from "../_shared/http.ts";
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

    const { data, error: reviewError } = await adminClient
      .from("review_items")
      .select(
        "id, capture_id, status, summary, suggested_dish_ids, suggested_new_dish, confidence_label",
      )
      .eq("user_id", userId)
      .in("id", ids);

    if (reviewError != null) {
      throw reviewError;
    }

    const reviews = (data ?? []) as Array<Record<string, unknown>>;
    const items = reviews.map((row) => ({
      id: stringValue(row, "id"),
      captureId: stringValue(row, "capture_id"),
      status: stringValue(row, "status"),
      summary: stringValue(row, "summary"),
      suggestedDishIds: stringArrayValue(row, "suggested_dish_ids"),
      suggestedNewDish: objectValue(row, "suggested_new_dish"),
      confidenceLabel: optionalStringValue(row, "confidence_label"),
    }));

    const foundIds = new Set(items.map((item) => item.id));
    return json({
      items,
      missingIds: ids.filter((id) => !foundIds.has(id)),
    });
  } catch (error) {
    console.error("get-review-items failed", error);
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

function stringArrayValue(row: Record<string, unknown>, key: string) {
  const value = row[key];
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === "string")
    : [];
}

function objectValue(row: Record<string, unknown>, key: string) {
  const value = row[key];
  return typeof value === "object" && value != null
    ? value as Record<string, unknown>
    : null;
}
