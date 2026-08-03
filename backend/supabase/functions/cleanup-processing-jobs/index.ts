import { handleOptions, json } from "../_shared/http.ts";
import {
  operationalError,
  operationalLog,
} from "../_shared/operational_log.ts";
import { requireAiWorkerKey } from "../_shared/ai/worker_config.ts";
import { requireEnv, supabaseFor } from "../_shared/supabase.ts";

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
    await client.from("ai_usage_records").delete().lt(
      "expires_at",
      new Date().toISOString(),
    );
    operationalLog("processing_cleanup_complete", { status: "ok" });
    return json({ expired });
  } catch (_) {
    operationalError("processing_cleanup_failed", "cleanup_failed");
    return json({ error: "cleanup_failed" }, 500);
  }
});
