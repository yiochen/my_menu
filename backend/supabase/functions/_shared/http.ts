export type JsonRecord = Record<string, unknown>;

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-mymenu-worker-key",
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
