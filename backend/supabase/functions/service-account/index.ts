import { handleOptions, json, readJson } from "../_shared/http.ts";
import {
  operationalError,
  operationalLog,
} from "../_shared/operational_log.ts";
import { requireUser, type SupabaseClientAny } from "../_shared/supabase.ts";
import {
  removeStorageAssets,
  type StorageAsset,
} from "../_shared/storage_cleanup.ts";

Deno.serve(async (request: Request) => {
  const options = handleOptions(request);
  if (options != null) {
    return options;
  }
  if (request.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  const { error, userId, adminClient } = await requireUser(request);
  if (error != null) {
    return error;
  }

  try {
    const body = await readJson(request);
    if (body.action !== "delete") {
      return json({ error: "Unsupported action" }, 400);
    }

    const { data: account, error: accountError } = await adminClient.auth.admin
      .getUserById(userId);
    if (accountError != null || account.user == null) {
      return json({ error: "Unauthorized" }, 401);
    }
    if (account.user.is_anonymous !== false) {
      return json({ error: "Signed account required" }, 403);
    }

    await rpc(adminClient, "internal_begin_service_identity_deletion", {
      p_user_id: userId,
    });

    const { data: processingAssets, error: processingAssetsError } =
      await adminClient
        .from("processing_assets")
        .select("storage_path")
        .eq("user_id", userId);
    if (processingAssetsError != null) {
      throw processingAssetsError;
    }
    const assets: StorageAsset[] = (processingAssets ?? []).map(
      (asset: { storage_path: string }) => ({
        storage_bucket: "processing-media",
        storage_path: asset.storage_path,
      }),
    );
    await removeStorageAssets(adminClient, assets);

    await rpc(adminClient, "internal_complete_service_identity_deletion", {
      p_user_id: userId,
    });
    // A signed upload may have completed between the first removal and Auth
    // deletion. Remove the known paths again; scheduled orphan cleanup catches
    // uploads that land after this point.
    await removeStorageAssets(adminClient, assets);
    operationalLog("service_identity_deleted", {
      action: "delete",
      status: "ok",
    });
    return json({ deleted: true });
  } catch (_) {
    operationalError("service_identity_deletion_failed", "deletion_failed", {
      action: "delete",
    });
    return json({ error: "deletion_failed" }, 500);
  }
});

async function rpc(
  client: SupabaseClientAny,
  name: string,
  params: Record<string, unknown>,
) {
  const { error } = await client.rpc(name, params);
  if (error != null) {
    throw error;
  }
}
