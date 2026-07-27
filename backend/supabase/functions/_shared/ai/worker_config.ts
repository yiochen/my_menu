import { requireEnv } from "../supabase.ts";

export function requireAiWorkerKey() {
  const configured = Deno.env.get("AI_WORKER_KEY")?.trim();
  if (configured != null && configured.length > 0) {
    return configured;
  }

  const supabaseUrl = new URL(requireEnv("SUPABASE_URL"));
  if (supabaseUrl.protocol === "http:") {
    // The local Edge runtime does not forward arbitrary shell environment
    // variables. Reusing the local development key keeps the emulator usable;
    // hosted projects use HTTPS and must configure a dedicated key.
    return requireEnv("SUPABASE_SERVICE_ROLE_KEY");
  }

  throw new Error("Missing required environment variable: AI_WORKER_KEY");
}
