import { handleOptions, json, readJson } from "../_shared/http.ts";
import {
  operationalError,
  operationalLog,
} from "../_shared/operational_log.ts";
import { requireUser, type SupabaseClientAny } from "../_shared/supabase.ts";

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

    const { data: assets, error: assetsError } = await adminClient
      .from("processing_assets")
      .select("storage_path")
      .eq("user_id", userId);
    if (assetsError != null) {
      throw assetsError;
    }
    const paths = (assets ?? []).map(
      (asset: { storage_path: string }) => asset.storage_path,
    );
    for (let offset = 0; offset < paths.length; offset += 100) {
      const { error: removeError } = await adminClient.storage
        .from("processing-media")
        .remove(paths.slice(offset, offset + 100));
      if (removeError != null) {
        throw removeError;
      }
    }

    await rpc(adminClient, "internal_complete_service_identity_deletion", {
      p_user_id: userId,
    });
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
