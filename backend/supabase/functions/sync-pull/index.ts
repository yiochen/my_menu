import {
  handleOptions,
  json,
  optionalNumber,
  readJson,
} from "../_shared/http.ts";
import { requireUser, rpcOne } from "../_shared/supabase.ts";

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
    const afterCursor = Math.max(optionalNumber(body, "afterCursor") ?? 0, 0);
    const limit = optionalNumber(body, "limit") ?? 200;

    const result = await rpcOne(adminClient, "api_pull_events", {
      p_user_id: userId,
      p_after_cursor: afterCursor,
      p_limit: limit,
    });

    return json({
      cursor: numberValue(result, "cursor", afterCursor),
      hasMore: booleanValue(result, "has_more", false),
      requiresBootstrap: booleanValue(result, "requires_bootstrap", false),
      events: Array.isArray(result.events) ? result.events : [],
    });
  } catch (error) {
    console.error("sync-pull failed", error);
    return json(
      { error: error instanceof Error ? error.message : "Server error" },
      500,
    );
  }
});

function numberValue(
  data: Record<string, unknown>,
  key: string,
  fallback: number,
) {
  const value = data[key];
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === "string") {
    const parsed = Number.parseInt(value, 10);
    return Number.isFinite(parsed) ? parsed : fallback;
  }
  return fallback;
}

function booleanValue(
  data: Record<string, unknown>,
  key: string,
  fallback: boolean,
) {
  const value = data[key];
  return typeof value === "boolean" ? value : fallback;
}
