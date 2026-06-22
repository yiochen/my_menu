import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import {
  handleOptions,
  json,
  optionalString,
  readJson,
  requiredString,
} from "../_shared/http.ts";
import { requireEnv, requireUser } from "../_shared/supabase.ts";

declare const EdgeRuntime: {
  waitUntil(promise: Promise<unknown>): void;
};

Deno.serve(async (request: Request) => {
  const options = handleOptions(request);
  if (options != null) {
    return options;
  }

  try {
    const { error, userId } = await requireUser(request);
    if (error != null) {
      return error;
    }

    const body = await readJson(request);
    const captureId = requiredString(body, "captureId");

    // Triggered when the app asks the backend to classify a capture. This route
    // returns immediately after starting the async worker; run_ai later writes
    // the fake classification result and emits sync events through RPCs.
    EdgeRuntime.waitUntil(
      invokeRunAi({
        userId,
        captureId,
        remoteMediaRef: optionalString(body, "remoteMediaRef"),
        ideaText: optionalString(body, "ideaText"),
      }),
    );

    return json({
      captureId,
      status: "classifying",
      started: true,
    });
  } catch (error) {
    console.error("classify failed", error);
    return json(
      { error: error instanceof Error ? error.message : "Server error" },
      500,
    );
  }
});

async function invokeRunAi(body: Record<string, unknown>) {
  const url = `${requireEnv("SUPABASE_URL")}/functions/v1/run_ai`;
  const serviceRoleKey = requireEnv("SUPABASE_SERVICE_ROLE_KEY");
  try {
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-mymenu-worker-key": serviceRoleKey,
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      console.error("run_ai failed", response.status, await response.text());
    }
  } catch (error) {
    console.error("run_ai invocation failed", error);
  }
}
