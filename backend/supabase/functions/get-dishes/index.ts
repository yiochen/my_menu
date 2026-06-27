import {
  handleOptions,
  json,
  readJson,
  requiredStringArray,
} from "../_shared/http.ts";
import { imageDto, signedMediaRef } from "../_shared/media.ts";
import {
  booleanValue,
  numberValue,
  optionalNumberValue,
  optionalStringValue,
  stringArrayValue,
  stringValue,
} from "../_shared/row.ts";
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

    const { data: dishData, error: dishError } = await adminClient
      .from("dishes")
      .select(
        "id, title, description, cover_image_id, labels, prep_minutes, difficulty, is_favorite",
      )
      .eq("user_id", userId)
      .in("id", ids)
      .is("deleted_at", null);

    if (dishError != null) {
      throw dishError;
    }

    const dishes = (dishData ?? []) as Array<Record<string, unknown>>;
    const dishIds = dishes.map((row) => stringValue(row, "id"));
    const statsByDishId = await loadStats(adminClient, dishIds);
    const imagesByDishId = await loadImages(adminClient, userId, dishIds);
    const notesByDishId = await loadBodyRows(
      adminClient,
      userId,
      "dish_notes",
      dishIds,
    );
    const ingredientsByDishId = await loadBodyRows(
      adminClient,
      userId,
      "dish_ingredients",
      dishIds,
    );
    const stepsByDishId = await loadBodyRows(
      adminClient,
      userId,
      "dish_steps",
      dishIds,
    );

    const items = [];
    for (const dish of dishes) {
      const id = stringValue(dish, "id");
      const stats = statsByDishId.get(id);
      const images = imagesByDishId.get(id) ?? [];
      const sourceImages = images.filter((row) =>
        stringValue(row, "kind") === "source_photo"
      );
      const coverImageId = optionalStringValue(dish, "cover_image_id") ??
        optionalStringValue(stats ?? {}, "latest_source_image_id");
      const coverImage = coverImageId == null
        ? null
        : images.find((row) => stringValue(row, "id") === coverImageId) ??
          null;

      items.push({
        id,
        title: stringValue(dish, "title"),
        description: stringValue(dish, "description"),
        labels: stringArrayValue(dish, "labels"),
        prepMinutes: optionalNumberValue(dish, "prep_minutes"),
        difficulty: optionalStringValue(dish, "difficulty"),
        isFavorite: booleanValue(dish, "is_favorite"),
        madeCount: numberValue(stats ?? {}, "made_count", 0),
        lastMadeAt: optionalStringValue(stats ?? {}, "last_made_at"),
        coverImage: coverImage == null
          ? null
          : await imageDto(adminClient, coverImage),
        sourcePhotos: await sourcePhotoDtos(adminClient, sourceImages),
        ingredients: ingredientsByDishId.get(id) ?? [],
        steps: stepsByDishId.get(id) ?? [],
        notes: notesByDishId.get(id) ?? [],
      });
    }

    const foundIds = new Set(dishIds);
    return json({
      items,
      missingIds: ids.filter((id) => !foundIds.has(id)),
    });
  } catch (error) {
    console.error("get-dishes failed", error);
    return json(
      { error: error instanceof Error ? error.message : "Server error" },
      500,
    );
  }
});

async function loadStats(adminClient: any, dishIds: string[]) {
  const byDishId = new Map<string, Record<string, unknown>>();
  if (dishIds.length === 0) {
    return byDishId;
  }

  const { data, error } = await adminClient
    .from("dish_cooking_stats")
    .select("dish_id, made_count, last_made_at, latest_source_image_id")
    .in("dish_id", dishIds);

  if (error != null) {
    throw error;
  }

  for (const row of (data ?? []) as Array<Record<string, unknown>>) {
    byDishId.set(stringValue(row, "dish_id"), row);
  }
  return byDishId;
}

async function loadImages(
  adminClient: any,
  userId: string,
  dishIds: string[],
) {
  const byDishId = new Map<string, Array<Record<string, unknown>>>();
  if (dishIds.length === 0) {
    return byDishId;
  }

  const { data, error } = await adminClient
    .from("dish_images")
    .select(
      "id, dish_id, kind, storage_bucket, storage_path, note, confidence_label, captured_at, created_at",
    )
    .eq("user_id", userId)
    .in("dish_id", dishIds)
    .is("deleted_at", null)
    .order("captured_at", { ascending: false, nullsFirst: false })
    .order("created_at", { ascending: false });

  if (error != null) {
    throw error;
  }

  for (const row of (data ?? []) as Array<Record<string, unknown>>) {
    const dishId = stringValue(row, "dish_id");
    const rows = byDishId.get(dishId) ?? [];
    rows.push(row);
    byDishId.set(dishId, rows);
  }
  return byDishId;
}

async function loadBodyRows(
  adminClient: any,
  userId: string,
  table: string,
  dishIds: string[],
) {
  const byDishId = new Map<string, string[]>();
  if (dishIds.length === 0) {
    return byDishId;
  }

  const { data, error } = await adminClient
    .from(table)
    .select("dish_id, body, position")
    .eq("user_id", userId)
    .in("dish_id", dishIds)
    .is("deleted_at", null)
    .order("position", { ascending: true });

  if (error != null) {
    throw error;
  }

  for (const row of (data ?? []) as Array<Record<string, unknown>>) {
    const dishId = stringValue(row, "dish_id");
    const rows = byDishId.get(dishId) ?? [];
    rows.push(stringValue(row, "body"));
    byDishId.set(dishId, rows);
  }
  return byDishId;
}

async function sourcePhotoDtos(
  adminClient: any,
  rows: Array<Record<string, unknown>>,
) {
  const items = [];
  for (const row of rows) {
    items.push({
      id: stringValue(row, "id"),
      mediaRef: await signedMediaRef(
        adminClient,
        stringValue(row, "storage_bucket"),
        stringValue(row, "storage_path"),
      ),
      capturedAt: optionalStringValue(row, "captured_at"),
      note: optionalStringValue(row, "note"),
      confidenceLabel: optionalStringValue(row, "confidence_label"),
    });
  }
  return items;
}
