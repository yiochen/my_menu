import { handleOptions, json } from "../_shared/http.ts";
import {
  operationalError,
  operationalLog,
} from "../_shared/operational_log.ts";
import { requireAiWorkerKey } from "../_shared/ai/worker_config.ts";
import { requireEnv, supabaseFor } from "../_shared/supabase.ts";
import {
  removeStorageAssets,
  type StorageAsset,
} from "../_shared/storage_cleanup.ts";

Deno.serve(async (request: Request) => {
  const options = handleOptions(request);
  if (options != null) {
    return options;
  }
  if (request.headers.get("x-mymenu-worker-key") !== requireAiWorkerKey()) {
    return json({ error: "Forbidden" }, 403);
  }
  const client = supabaseFor(
    `Bearer ${requireEnv("SUPABASE_SERVICE_ROLE_KEY")}`,
    true,
  );
  try {
    const { data: dueAccountAssets, error: accountAssetError } = await client
      .from("service_identity_asset_deletions")
      .select("storage_bucket, storage_path")
      .lte("delete_after", new Date().toISOString())
      .order("delete_after")
      .limit(500);
    if (accountAssetError != null) {
      throw accountAssetError;
    }
    const accountAssets = (dueAccountAssets ?? []) as StorageAsset[];
    await removeStorageAssets(client, accountAssets);
    for (const asset of accountAssets) {
      const { error: deletionError } = await client
        .from("service_identity_asset_deletions")
        .delete()
        .eq("storage_bucket", asset.storage_bucket)
        .eq("storage_path", asset.storage_path);
      if (deletionError != null) {
        throw deletionError;
      }
    }

    const { data: jobs, error } = await client.from("processing_jobs")
      .select("id").lt("expires_at", new Date().toISOString())
      .not("status", "in", '("acknowledged","canceled","expired")');
    if (error != null) {
      throw error;
    }
    let expired = 0;
    for (const job of jobs ?? []) {
      const { data: assets, error: assetError } = await client
        .from("processing_assets").select("storage_path").eq("job_id", job.id);
      if (assetError != null) {
        throw assetError;
      }
      const paths = (assets ?? []).map((asset: { storage_path: string }) =>
        asset.storage_path
      );
      if (paths.length > 0) {
        const { error: removeError } = await client.storage
          .from("processing-media").remove(paths);
        if (removeError != null) {
          throw removeError;
        }
      }
      const { error: expireError } = await client.rpc(
        "internal_expire_processing_job",
        { p_job_id: job.id },
      );
      if (expireError != null) {
        throw expireError;
      }
      expired += 1;
    }
    const inactiveBefore = new Date();
    inactiveBefore.setUTCDate(inactiveBefore.getUTCDate() - 90);
    const { data: expiredGuestRows, error: guestCleanupError } = await client
      .rpc("internal_expire_inactive_guest_identities", {
        p_inactive_before: inactiveBefore.toISOString(),
        p_limit: 100,
      });
    if (guestCleanupError != null) {
      throw guestCleanupError;
    }
    const expiredGuests = expiredGuestRows?.length ?? 0;
    await client.from("ai_usage_records").delete().lt(
      "expires_at",
      new Date().toISOString(),
    );
    operationalLog("processing_cleanup_complete", {
      status: "ok",
      expiredJobs: expired,
      expiredGuests,
      deletedAccountAssets: accountAssets.length,
    });
    return json({
      expired,
      expiredGuests,
      deletedAccountAssets: accountAssets.length,
    });
  } catch (_) {
    operationalError("processing_cleanup_failed", "cleanup_failed");
    return json({ error: "cleanup_failed" }, 500);
  }
});
