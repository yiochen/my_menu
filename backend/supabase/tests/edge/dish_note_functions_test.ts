import { createClient } from "jsr:@supabase/supabase-js@2";

const baseUrl = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ??
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwic" +
    "m9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwic" +
    "m9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU";

Deno.test("createDishNote requires a user session", async () => {
  const response = await fetch(`${baseUrl}/functions/v1/createDishNote`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      noteId: "30000000-0000-4000-8000-000000000201",
      dishId: "20000000-0000-4000-8000-000000000201",
      body: "Use more lemon.",
    }),
  });

  assertEquals(response.status, 401);
  await response.body?.cancel();
});

Deno.test("updateDish rejects notes in dish patch", async () => {
  const dishId = crypto.randomUUID();
  const auth = await createAuthenticatedDish(dishId);
  const response = await fetch(`${baseUrl}/functions/v1/updateDish`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${auth.accessToken}`,
      apikey: anonKey,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      clientMutationId: "mutation-1",
      dishId,
      patch: { notes: ["Use less salt."] },
    }),
  });

  assertEquals(response.status, 400);
  await response.body?.cancel();
});

Deno.test("createDishNote creates a note for the authenticated user", async () => {
  const dishId = crypto.randomUUID();
  const noteId = crypto.randomUUID();
  const auth = await createAuthenticatedDish(dishId);
  const response = await fetch(`${baseUrl}/functions/v1/createDishNote`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${auth.accessToken}`,
      apikey: anonKey,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      noteId,
      dishId,
      body: "Use more lemon.",
      position: 0,
    }),
  });

  assertEquals(response.status, 200);
  const data = await response.json();
  assertEquals(data.noteId, noteId);
});

async function createAuthenticatedDish(dishId: string) {
  const client = createClient(baseUrl, anonKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });
  const { data: authData, error: authError } = await client.auth
    .signInAnonymously();
  if (authError != null || authData.session == null || authData.user == null) {
    throw authError ?? new Error("Anonymous sign-in failed");
  }

  const adminClient = createClient(baseUrl, serviceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });

  const captureId = crypto.randomUUID();
  const { error: captureError } = await adminClient.rpc(
    "api_create_idea_capture",
    {
      p_user_id: authData.user.id,
      p_capture_id: captureId,
      p_idea_text: "edge note dish",
      p_captured_at: new Date().toISOString(),
    },
  );
  if (captureError != null) {
    throw captureError;
  }

  const { error: dishError } = await adminClient.rpc(
    "api_create_dish_from_capture",
    {
      p_user_id: authData.user.id,
      p_capture_id: captureId,
      p_dish_id: dishId,
      p_title: "Edge Note Dish",
      p_description: "Created by edge tests.",
      p_labels: [],
      p_confidence_label: "Test",
    },
  );
  if (dishError != null) {
    throw dishError;
  }

  return {
    accessToken: authData.session.access_token,
  };
}

function assertEquals(actual: unknown, expected: unknown) {
  if (actual !== expected) {
    throw new Error(`Expected ${expected}, got ${actual}`);
  }
}
