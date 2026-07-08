import { errorMessage, isNotFoundError } from "../_shared/errors.ts";
import {
  handleOptions,
  json,
  readJson,
  requiredObject,
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
    const clientMutationId = requiredString(body, "clientMutationId");
    const dishId = requiredString(body, "dishId");
    const patch = requiredObject(body, "patch");
    if ("notes" in patch || "coverImageId" in patch) {
      return json({ error: "Unsupported dish patch field" }, 400);
    }
    for (const key of ["labels", "ingredients", "steps"]) {
      const value = patch[key];
      if (
        value != null &&
        (!Array.isArray(value) ||
          !value.every((item) => typeof item === "string"))
      ) {
        return json({ error: `Expected string array: ${key}` }, 400);
      }
    }

    const result = await rpcOne(adminClient, "api_update_dish", {
      p_user_id: userId,
      p_client_mutation_id: clientMutationId,
      p_dish_id: dishId,
      p_patch: patch,
    });

    return json({
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
    console.error("updateDish failed", error);
    return json({ error: errorMessage(error) }, 500);
  }
});
