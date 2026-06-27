import { stringValue } from "./row.ts";
import type { SupabaseClientAny } from "./supabase.ts";

const SIGNED_URL_TTL_SECONDS = 60 * 60;

export async function signedMediaRef(
  adminClient: SupabaseClientAny,
  bucket: string,
  path: string,
) {
  const { data, error } = await adminClient.storage
    .from(bucket)
    .createSignedUrl(path, SIGNED_URL_TTL_SECONDS);

  if (error != null) {
    throw error;
  }

  return data.signedUrl as string;
}

export async function imageDto(
  adminClient: SupabaseClientAny,
  row: Record<string, unknown>,
) {
  const bucket = stringValue(row, "storage_bucket");
  const path = stringValue(row, "storage_path");

  return {
    id: stringValue(row, "id"),
    kind: stringValue(row, "kind"),
    mediaRef: await signedMediaRef(adminClient, bucket, path),
  };
}
