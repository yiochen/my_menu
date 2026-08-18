import type { SupabaseClientAny } from "./supabase.ts";

export type StorageAsset = {
  storage_bucket: string;
  storage_path: string;
};

export async function removeStorageAssets(
  client: SupabaseClientAny,
  assets: StorageAsset[],
) {
  const pathsByBucket = new Map<string, string[]>();
  for (const asset of assets) {
    const paths = pathsByBucket.get(asset.storage_bucket) ?? [];
    paths.push(asset.storage_path);
    pathsByBucket.set(asset.storage_bucket, paths);
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
