import { errorMessage, isNotFoundError } from "../_shared/errors.ts";
import {
  handleOptions,
  json,
  optionalNumber,
  readJson,
  requiredString,
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
    const noteId = requiredString(body, "noteId");
    const dishId = requiredString(body, "dishId");
    const noteBody = requiredString(body, "body").trim();
    if (noteBody.length === 0) {
      return json({ error: "Missing required string: body" }, 400);
    }

    const result = await rpcOne(adminClient, "api_create_dish_note", {
      p_user_id: userId,
      p_note_id: noteId,
      p_dish_id: dishId,
      p_body: noteBody,
      p_position: optionalNumber(body, "position") ?? 0,
    });

    return json({
      noteId: result.note_id,
      dishId: result.dish_id,
      cursor: result.sync_cursor,
    });
  } catch (error) {
    if (isNotFoundError(error)) {
      return json({ error: "Dish not found" }, 404);
    }
    if (error instanceof Error && error.message.startsWith("Missing ")) {
      return json({ error: error.message }, 400);
    }
    console.error("createDishNote failed", error);
    return json({ error: errorMessage(error) }, 500);
  }
});
