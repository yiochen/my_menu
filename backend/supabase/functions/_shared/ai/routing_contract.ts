import contractJson from "./prompts/capture-routing/v2/contract.json" with {
  type: "json",
};
import type { GroupingCaptureInput, JsonObject } from "./grouping_contract.ts";

export interface RoutingDishInput {
  localId: string;
  title: string;
  description: string;
  ingredients: string[];
  recipeSteps: string[];
  notes: string[];
}

export interface RoutingDishDraft {
  title: string;
  description: string;
  labels: string[];
  visibleIngredients: string[];
  coverSourceCaptureIds: string[];
}

export type RoutingOutcome =
  | { type: "existing_dish"; localDishId: string }
  | { type: "new_dish"; draft: RoutingDishDraft }
  | { type: "unresolved" }
  | { type: "not_a_dish" };

export interface RoutingDecision {
  captureIds: string[];
  outcome: RoutingOutcome;
  evidence: string[];
  uncertainty: string[];
}

export interface CaptureRoutingOutput {
  decisions: RoutingDecision[];
}

export const captureRoutingContract = contractJson as {
  task: "capture_routing";
  promptVersion: string;
  schemaVersion: string;
  systemPrompt: string;
  outputSchema: JsonObject;
};

export function validateAndCanonicalizeRouting(
  value: unknown,
  captures: GroupingCaptureInput[],
  dishes: RoutingDishInput[],
): CaptureRoutingOutput {
  const root = objectValue(value, "routing result");
  const rawDecisions = arrayValue(root.decisions, "decisions");
  if (rawDecisions.length === 0 || rawDecisions.length > captures.length) {
    throw new Error("Routing result has an invalid decision count");
  }

  const captureById = new Map(captures.map((capture) => [capture.id, capture]));
  const dishIds = new Set(dishes.map((dish) => dish.localId));
  const seen = new Set<string>();
  const decisions = rawDecisions.map((rawDecision, index) => {
    const decision = objectValue(rawDecision, `decisions[${index}]`);
    const captureIds = stringArray(
      decision.captureIds,
      `decisions[${index}].captureIds`,
    );
    if (captureIds.length === 0) {
      throw new Error(`decisions[${index}] is empty`);
    }
    for (const captureId of captureIds) {
      if (!captureById.has(captureId)) {
        throw new Error(
          `Routing result references foreign capture ${captureId}`,
        );
      }
      if (!isUuid(captureId) || seen.has(captureId)) {
        throw new Error(
          `Routing result has duplicate or invalid capture ${captureId}`,
        );
      }
      seen.add(captureId);
    }

    const outcomeValue = objectValue(
      decision.outcome,
      `decisions[${index}].outcome`,
    );
    const type = boundedString(
      outcomeValue.type,
      `decisions[${index}].outcome.type`,
      1,
      40,
    );
    const uncertainty = boundedStringArray(
      decision.uncertainty,
      `decisions[${index}].uncertainty`,
      8,
      180,
    );
    const evidence = boundedStringArray(
      decision.evidence,
      `decisions[${index}].evidence`,
      8,
      180,
      1,
    );
    let outcome: RoutingOutcome;
    switch (type) {
      case "existing_dish": {
        requireResolved(uncertainty, index);
        const localDishId = boundedString(
          outcomeValue.localDishId,
          `decisions[${index}].outcome.localDishId`,
          1,
          200,
        );
        if (!dishIds.has(localDishId)) {
          throw new Error(
            `Routing result references foreign dish ${localDishId}`,
          );
        }
        if (outcomeValue.draft != null) {
          throw new Error("Existing-dish outcome cannot contain a draft");
        }
        outcome = { type, localDishId };
        break;
      }
      case "new_dish": {
        requireResolved(uncertainty, index);
        if (outcomeValue.localDishId != null) {
          throw new Error("New-dish outcome cannot contain a dish reference");
        }
        const draft = objectValue(
          outcomeValue.draft,
          `decisions[${index}].outcome.draft`,
        );
        outcome = {
          type,
          draft: {
            title: boundedString(draft.title, "draft.title", 1, 80),
            description: boundedString(
              draft.description,
              "draft.description",
              0,
              240,
            ),
            labels: boundedStringArray(draft.labels, "draft.labels", 6, 40),
            visibleIngredients: boundedStringArray(
              draft.visibleIngredients,
              "draft.visibleIngredients",
              12,
              80,
            ),
            coverSourceCaptureIds: coverSourceIds(
              draft.coverSourceCaptureIds,
              captureIds,
              captureById,
            ),
          },
        };
        break;
      }
      case "unresolved":
        if (captureIds.length !== 1 || uncertainty.length === 0) {
          throw new Error(
            "Unresolved decisions require one capture and uncertainty",
          );
        }
        requireNoRoutingPayload(outcomeValue, type);
        outcome = { type };
        break;
      case "not_a_dish":
        requireResolved(uncertainty, index);
        if (
          captureIds.length !== 1 ||
          captureById.get(captureIds[0])!.kind !== "photo"
        ) {
          throw new Error("Not-a-dish decisions require one photo");
        }
        requireNoRoutingPayload(outcomeValue, type);
        outcome = { type };
        break;
      default:
        throw new Error(`Unsupported routing outcome ${type}`);
    }
    return { captureIds, outcome, evidence, uncertainty };
  });

  const missing = captures.map((capture) => capture.id).filter((id) =>
    !seen.has(id)
  );
  if (missing.length > 0) {
    throw new Error(`Routing result omits captures: ${missing.join(", ")}`);
  }
  for (const decision of decisions) {
    decision.captureIds.sort(
      (left, right) =>
        captureById.get(left)!.ordinal - captureById.get(right)!.ordinal,
    );
  }
  decisions.sort(
    (left, right) =>
      captureById.get(left.captureIds[0])!.ordinal -
      captureById.get(right.captureIds[0])!.ordinal,
  );
  return { decisions };
}

function coverSourceIds(
  value: unknown,
  decisionCaptureIds: string[],
  captureById: Map<string, GroupingCaptureInput>,
) {
  const ids = stringArray(value, "draft.coverSourceCaptureIds");
  if (ids.length > 3 || ids.length !== new Set(ids).size) {
    throw new Error(
      "draft.coverSourceCaptureIds must contain up to 3 unique IDs",
    );
  }
  for (const id of ids) {
    if (
      !decisionCaptureIds.includes(id) || captureById.get(id)?.kind !== "photo"
    ) {
      throw new Error(
        "Cover Sources must be photos from the new Dish decision",
      );
    }
  }
  return ids;
}

function requireResolved(uncertainty: string[], index: number) {
  if (uncertainty.length > 0) {
    throw new Error(`Resolved decision ${index} cannot contain uncertainty`);
  }
}

function requireNoRoutingPayload(value: JsonObject, type: string) {
  if (value.localDishId != null || value.draft != null) {
    throw new Error(`${type} outcome cannot contain routing fields`);
  }
}

function objectValue(value: unknown, label: string): JsonObject {
  if (typeof value !== "object" || value == null || Array.isArray(value)) {
    throw new Error(`${label} must be an object`);
  }
  return value as JsonObject;
}

function arrayValue(value: unknown, label: string): unknown[] {
  if (!Array.isArray(value)) throw new Error(`${label} must be an array`);
  return value;
}

function stringArray(value: unknown, label: string): string[] {
  return arrayValue(value, label).map((item, index) =>
    boundedString(item, `${label}[${index}]`, 1, Number.MAX_SAFE_INTEGER)
  );
}

function boundedStringArray(
  value: unknown,
  label: string,
  maxItems: number,
  maxLength: number,
  minItems = 0,
): string[] {
  const values = arrayValue(value, label);
  if (values.length < minItems || values.length > maxItems) {
    throw new Error(`${label} has an invalid item count`);
  }
  return values.map((item, index) =>
    boundedString(item, `${label}[${index}]`, 1, maxLength)
  );
}

function boundedString(
  value: unknown,
  label: string,
  minLength: number,
  maxLength: number,
): string {
  if (typeof value !== "string") throw new Error(`${label} must be a string`);
  const normalized = value.trim();
  if (normalized.length < minLength || normalized.length > maxLength) {
    throw new Error(`${label} has an invalid length`);
  }
  return normalized;
}

function isUuid(value: string) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    .test(value);
}
