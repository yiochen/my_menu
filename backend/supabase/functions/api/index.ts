import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type JsonRecord = Record<string, unknown>;
// Keep this loose until the Supabase database types are generated for the repo.
type SupabaseClientAny = any;

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  let route = "";
  try {
    const body = await request.json() as JsonRecord;
    route = String(body.route ?? "");
    console.info(`mymenu route=${route}`);
    const authHeader = request.headers.get("Authorization") ?? "";
    const userClient = supabaseFor(authHeader, false);
    const adminClient = supabaseFor(authHeader, true);
    const { data: userData, error: userError } = await userClient.auth
      .getUser();

    if (userError || userData.user == null) {
      return json({ error: "Unauthorized" }, 401, route);
    }

    const userId = userData.user.id;

    switch (route) {
      case "capture.preparePhotoUpload":
        return withRoute(
          await preparePhotoUpload(adminClient, userId, body),
          route,
        );
      case "capture.createPhoto":
        return withRoute(await createPhoto(adminClient, userId, body), route);
      case "capture.classify":
        return withRoute(
          await classifyCapture(adminClient, userId, body),
          route,
        );
      case "capture.discard":
        return withRoute(
          await discardCapture(adminClient, userId, body),
          route,
        );
      default:
        return json({ error: `Unknown route: ${route}` }, 404, route);
    }
  } catch (error) {
    console.error(`mymenu route=${route} failed`, error);
    return json(
      {
        error: error instanceof Error ? error.message : "Server error",
      },
      500,
      route,
    );
  }
});

function supabaseFor(authHeader: string, serviceRole: boolean) {
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

async function preparePhotoUpload(
  adminClient: SupabaseClientAny,
  userId: string,
  body: JsonRecord,
) {
  const captureId = requiredString(body, "captureId");
  const contentType = requiredString(body, "contentType");
  const extension = extensionFor(contentType);
  const storagePath =
    `users/${userId}/captures/${captureId}/original.${extension}`;

  const { data, error } = await adminClient.storage
    .from("menu-media")
    .createSignedUploadUrl(storagePath);

  if (error != null) {
    throw error;
  }

  return json({
    captureId,
    storageBucket: "menu-media",
    storagePath,
    upload: {
      signedUrl: data.signedUrl,
      token: data.token,
      path: data.path,
    },
  });
}

async function createPhoto(
  adminClient: SupabaseClientAny,
  userId: string,
  body: JsonRecord,
) {
  const captureId = requiredString(body, "captureId");
  const result = await rpcOne(adminClient, "api_create_photo_capture", {
    p_user_id: userId,
    p_capture_id: captureId,
    p_storage_path: requiredString(body, "storagePath"),
    p_content_type: requiredString(body, "contentType"),
    p_byte_size: optionalNumber(body, "byteSize"),
    p_width: optionalNumber(body, "width"),
    p_height: optionalNumber(body, "height"),
    p_sha256: optionalString(body, "sha256"),
    p_captured_at: optionalString(body, "capturedAt") ??
      new Date().toISOString(),
  });

  return json({
    capture: {
      id: result.capture_id,
      kind: "photo",
      status: "classifying",
      imageId: result.image_id,
    },
    image: {
      id: result.image_id,
      kind: "capture_photo",
      mediaRef: `menu-media:${requiredString(body, "storagePath")}`,
    },
    cursor: result.sync_cursor,
  });
}

async function classifyCapture(
  adminClient: SupabaseClientAny,
  userId: string,
  body: JsonRecord,
) {
  const captureId = requiredString(body, "captureId");
  const ideaText = optionalString(body, "ideaText")?.trim();

  if (ideaText != null && ideaText.length > 0) {
    await rpcOne(adminClient, "api_create_idea_capture", {
      p_user_id: userId,
      p_capture_id: captureId,
      p_idea_text: ideaText,
      p_captured_at: new Date().toISOString(),
    });
  }

  const title = titleFrom(ideaText ?? "Captured Dish");
  const dishId = crypto.randomUUID();
  const result = await rpcOne(adminClient, "api_create_dish_from_capture", {
    p_user_id: userId,
    p_capture_id: captureId,
    p_dish_id: dishId,
    p_title: title,
    p_description: "AI-assisted draft from a synced capture.",
    p_labels: ["capture"],
    p_confidence_label: "Draft",
  });

  return json({
    captureId,
    dishId,
    title,
    description: "AI-assisted draft from a synced capture.",
    mediaRef: body.remoteMediaRef ?? "",
    category: "Mains",
    sourceImageId: result.source_image_id,
    cursor: result.sync_cursor,
  });
}

async function discardCapture(
  adminClient: SupabaseClientAny,
  userId: string,
  body: JsonRecord,
) {
  const captureId = requiredString(body, "captureId");
  const result = await rpcOne(adminClient, "api_discard_capture", {
    p_user_id: userId,
    p_capture_id: captureId,
  });

  return json({
    captureId,
    status: "discarded",
    cursor: result.sync_cursor,
  });
}

async function rpcOne(
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

    console.warn(`${fn} hit PostgREST schema cache retry`, error);
  }

  throw lastError;
}

function withRoute(response: Response, route: string) {
  if (route.length === 0) {
    return response;
  }
  const headers = new Headers(response.headers);
  headers.set("x-mymenu-route", route);
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}

function json(body: JsonRecord, status = 200, route?: string) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
      ...(route != null && route.length > 0 ? { "x-mymenu-route": route } : {}),
    },
  });
}

function isSchemaCacheRetry(error: unknown) {
  if (error == null || typeof error !== "object") {
    return false;
  }
  const code = "code" in error ? error.code : null;
  return code === "PGRST002";
}

function sleep(milliseconds: number) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

function requiredString(body: JsonRecord, key: string) {
  const value = body[key];
  if (typeof value !== "string" || value.length === 0) {
    throw new Error(`Missing required string: ${key}`);
  }
  return value;
}

function optionalString(body: JsonRecord, key: string) {
  const value = body[key];
  return typeof value === "string" && value.length > 0 ? value : null;
}

function optionalNumber(body: JsonRecord, key: string) {
  const value = body[key];
  return typeof value === "number" ? value : null;
}

function extensionFor(contentType: string) {
  switch (contentType.toLowerCase()) {
    case "image/png":
      return "png";
    case "image/heic":
      return "heic";
    case "image/heif":
      return "heif";
    default:
      return "jpg";
  }
}

function titleFrom(input: string) {
  return input
    .trim()
    .split(/\s+/)
    .filter((part) => part.length > 0)
    .map((part) => `${part[0].toUpperCase()}${part.slice(1)}`)
    .join(" ");
}

function requireEnv(name: string) {
  const value = Deno.env.get(name);
  if (value == null || value.length === 0) {
    throw new Error(`Missing environment variable: ${name}`);
  }
  return value;
}
