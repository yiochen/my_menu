import { createClient } from "jsr:@supabase/supabase-js@2";
import { json, type JsonRecord } from "./http.ts";
import { operationalLog } from "./operational_log.ts";

// Keep this loose until the Supabase database types are generated for the repo.
export type SupabaseClientAny = any;

export function requireEnv(name: string) {
  const value = Deno.env.get(name);
  if (value == null || value.length === 0) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

export function supabaseFor(authHeader: string, serviceRole: boolean) {
  const url = requireEnv("SUPABASE_URL");
  const key = serviceRole
    ? requireEnv("SUPABASE_SERVICE_ROLE_KEY")
    : requireEnv("SUPABASE_ANON_KEY");

  return createClient(url, key, {
    global: {
      headers: !serviceRole && authHeader.length > 0
        ? { Authorization: authHeader }
        : {},
    },
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });
}

export async function requireUser(request: Request) {
  const authHeader = request.headers.get("Authorization") ?? "";
  const userClient = supabaseFor(authHeader, false);
  const { data: userData, error: userError } = await userClient.auth.getUser();

  if (userError || userData.user == null) {
    return {
      error: json({ error: "Unauthorized" }, 401),
      userId: "",
      adminClient: null as SupabaseClientAny,
    };
  }

  return {
    error: null,
    userId: userData.user.id as string,
    adminClient: supabaseFor(authHeader, true),
  };
}

export async function rpcOne(
  adminClient: SupabaseClientAny,
  fn: string,
  args: JsonRecord,
) {
  const delays = [0, 250, 500, 1000, 2000, 4000];
  let lastError: unknown;

  for (const delay of delays) {
    if (delay > 0) {
      await sleep(delay);
    }

    const { data, error } = await adminClient.rpc(fn, args);
    if (error == null) {
      if (!Array.isArray(data) || data.length === 0) {
        throw new Error(`${fn} returned no rows`);
      }
      return data[0] as JsonRecord;
    }

    lastError = error;
    if (!isSchemaCacheRetry(error)) {
      throw error;
    }

    operationalLog("supabase_schema_cache_retry", {
      action: fn,
      code: "schema_cache_retry",
    });
  }

  throw lastError;
}

function isSchemaCacheRetry(error: unknown) {
  if (typeof error !== "object" || error == null) {
    return false;
  }
  const code = "code" in error ? (error as { code?: unknown }).code : null;
  return code === "PGRST002";
}

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
