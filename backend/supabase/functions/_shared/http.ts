export type JsonRecord = Record<string, unknown>;

const allowedOrigin = Deno.env.get("CORS_ALLOWED_ORIGIN") ?? "*";

export const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": allowedOrigin,
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-mymenu-worker-key",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export function handleOptions(request: Request) {
  if (request.method !== "OPTIONS") {
    return null;
  }
  return new Response("ok", { headers: corsHeaders });
}

export function json(body: JsonRecord, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

export async function readJson(request: Request) {
  return await request.json() as JsonRecord;
}

export function requiredString(data: JsonRecord, key: string) {
  const value = data[key];
  if (typeof value !== "string" || value.length === 0) {
    throw new Error(`Missing required string: ${key}`);
  }
  return value;
}

export function optionalString(data: JsonRecord, key: string) {
  const value = data[key];
  return typeof value === "string" ? value : null;
}

export function optionalNumber(data: JsonRecord, key: string) {
  const value = data[key];
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

export function requiredObject(data: JsonRecord, key: string) {
  const value = data[key];
  if (
    typeof value !== "object" || value == null || Array.isArray(value)
  ) {
    throw new Error(`Missing required object: ${key}`);
  }
  return value as JsonRecord;
}

export function optionalStringArray(data: JsonRecord, key: string) {
  const value = data[key];
  if (value == null) {
    return null;
  }
  if (
    !Array.isArray(value) || !value.every((item) => typeof item === "string")
  ) {
    throw new Error(`Expected string array: ${key}`);
  }
  return value as string[];
}

export function requiredStringArray(data: JsonRecord, key: string) {
  const value = data[key];
  if (!Array.isArray(value)) {
    throw new Error(`Missing required string array: ${key}`);
  }

  const values = value.filter((item): item is string =>
    typeof item === "string" && item.length > 0
  );
  if (values.length !== value.length) {
    throw new Error(`Invalid string array: ${key}`);
  }
  return [...new Set(values)];
}
