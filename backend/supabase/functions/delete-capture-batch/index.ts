import {
  handleOptions,
  json,
  type JsonRecord,
  readJson,
} from "../_shared/http.ts";
import { requireUser, type SupabaseClientAny } from "../_shared/supabase.ts";

type StorageObject = {
  bucket: string;
  path: string;
};

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
    const batchId = body.batchId;
    if (typeof batchId !== "string" || !UUID_PATTERN.test(batchId)) {
      return json({ error: "batchId must be a UUID" }, 400);
    }

    const plan = await rpcJson(
      adminClient,
      "internal_prepare_capture_batch_deletion",
      { p_user_id: userId, p_batch_id: batchId },
    );
    const storageObjects = storageObjectsFrom(plan);
    await removeStorageObjects(adminClient, storageObjects);

    const result = await rpcJson(
      adminClient,
      "internal_delete_capture_batch",
      { p_user_id: userId, p_batch_id: batchId },
    );

    return json({
      deletedBatchId: nullableString(result, "deletedBatchId"),
      deletedCaptureIds: stringArray(result, "deletedCaptureIds"),
      deletedAiJobIds: stringArray(result, "deletedAiJobIds"),
      deletedStorageObjects: storageObjects.length,
    });
  } catch (error) {
    console.error("delete-capture-batch failed", error);
    return json(
      { error: error instanceof Error ? error.message : "Server error" },
      500,
    );
  }
});

async function rpcJson(
  client: SupabaseClientAny,
  name: string,
  params: JsonRecord,
) {
  const { data, error } = await client.rpc(name, params);
  if (error != null) {
    throw error;
  }
  if (typeof data !== "object" || data == null || Array.isArray(data)) {
    throw new Error(`${name} returned invalid JSON`);
  }
  return data as JsonRecord;
}

async function removeStorageObjects(
  client: SupabaseClientAny,
  objects: StorageObject[],
) {
  const pathsByBucket = new Map<string, string[]>();
  for (const object of objects) {
    const paths = pathsByBucket.get(object.bucket) ?? [];
    paths.push(object.path);
    pathsByBucket.set(object.bucket, paths);
  }
  for (const [bucket, paths] of pathsByBucket) {
    for (let offset = 0; offset < paths.length; offset += 100) {
      const { error } = await client.storage.from(bucket).remove(
        paths.slice(offset, offset + 100),
      );
      if (error != null) {
        throw error;
      }
    }
  }
}

function storageObjectsFrom(data: JsonRecord) {
  const value = data.storageObjects;
  if (!Array.isArray(value)) {
    throw new Error("Deletion plan has no storage object list");
  }
  return value.map((item): StorageObject => {
    if (typeof item !== "object" || item == null || Array.isArray(item)) {
      throw new Error("Deletion plan contains an invalid storage object");
    }
    const object = item as JsonRecord;
    if (typeof object.bucket !== "string" || typeof object.path !== "string") {
      throw new Error("Deletion plan contains an invalid storage path");
    }
    return { bucket: object.bucket, path: object.path };
  });
}

function stringArray(data: JsonRecord, key: string) {
  const value = data[key];
  if (
    !Array.isArray(value) || !value.every((item) => typeof item === "string")
  ) {
    throw new Error(`Deletion result has an invalid ${key}`);
  }
  return value as string[];
}

function nullableString(data: JsonRecord, key: string) {
  const value = data[key];
  if (value !== null && typeof value !== "string") {
    throw new Error(`Deletion result has an invalid ${key}`);
  }
  return value as string | null;
}

const UUID_PATTERN =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
