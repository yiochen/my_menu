import contractJson from "./prompts/batch-grouping/v2/contract.json" with {
  type: "json",
};

export type JsonObject = Record<string, unknown>;

export interface BatchGroupingContract {
  task: "batch_grouping";
  promptVersion: string;
  schemaVersion: string;
  systemPrompt: string;
  outputSchema: JsonObject;
}

export interface GroupingCaptureInput {
  id: string;
  ordinal: number;
  kind: "photo" | "idea";
  ideaText: string | null;
  capturedLocalDate: string | null;
  media?: {
    contentType: string;
    signedUrl: string;
    filename: string;
    loadBytes?: () => Promise<Uint8Array>;
  };
}

export interface DishDraft {
  title: string;
  description: string;
  labels: string[];
  visibleIngredients: string[];
}

export interface GroupingDecision {
  captureIds: string[];
  draft: DishDraft;
  evidence: string[];
  uncertainty: string[];
}

export interface RejectedCaptureDecision {
  captureId: string;
  classification: "not_a_dish";
  reason: string;
}

export interface BatchGroupingOutput {
  groups: GroupingDecision[];
  rejectedCaptures: RejectedCaptureDecision[];
}

export const batchGroupingContract = contractJson as BatchGroupingContract;

export function validateAndCanonicalizeGrouping(
  value: unknown,
  captures: GroupingCaptureInput[],
): BatchGroupingOutput {
  const root = objectValue(value, "grouping result");
  const rawGroups = arrayValue(root.groups, "groups");
  const rawRejectedCaptures = arrayValue(
    root.rejectedCaptures,
    "rejectedCaptures",
  );
  if (rawGroups.length === 0 && rawRejectedCaptures.length === 0) {
    throw new Error("Grouping result has no decisions");
  }

  const captureById = new Map(captures.map((capture) => [capture.id, capture]));
  const seen = new Set<string>();
  const groups = rawGroups.map((rawGroup, groupIndex) => {
    const group = objectValue(rawGroup, `groups[${groupIndex}]`);
    const ids = stringArray(
      group.captureIds,
      `groups[${groupIndex}].captureIds`,
    );
    if (ids.length === 0) {
      throw new Error(`groups[${groupIndex}] is empty`);
    }
    for (const id of ids) {
      if (!captureById.has(id)) {
        throw new Error(`Grouping result references foreign capture ${id}`);
      }
      if (!isUuid(id)) {
        throw new Error(`Grouping result has invalid capture ID ${id}`);
      }
      if (seen.has(id)) {
        throw new Error(`Grouping result duplicates capture ${id}`);
      }
      seen.add(id);
    }

    const draftValue = objectValue(
      group.draft,
      `groups[${groupIndex}].draft`,
    );
    const decision: GroupingDecision = {
      captureIds: ids,
      draft: {
        title: boundedString(
          draftValue.title,
          `groups[${groupIndex}].draft.title`,
          1,
          80,
        ),
        description: boundedString(
          draftValue.description,
          `groups[${groupIndex}].draft.description`,
          0,
          240,
        ),
        labels: boundedStringArray(
          draftValue.labels,
          `groups[${groupIndex}].draft.labels`,
          6,
          40,
        ),
        visibleIngredients: boundedStringArray(
          draftValue.visibleIngredients,
          `groups[${groupIndex}].draft.visibleIngredients`,
          12,
          80,
        ),
      },
      evidence: boundedStringArray(
        group.evidence,
        `groups[${groupIndex}].evidence`,
        8,
        180,
        1,
      ),
      uncertainty: boundedStringArray(
        group.uncertainty,
        `groups[${groupIndex}].uncertainty`,
        8,
        180,
      ),
    };
    return decision;
  });

  const rejectedCaptures = rawRejectedCaptures.map(
    (rawRejectedCapture, rejectedIndex) => {
      const rejected = objectValue(
        rawRejectedCapture,
        `rejectedCaptures[${rejectedIndex}]`,
      );
      const captureId = boundedString(
        rejected.captureId,
        `rejectedCaptures[${rejectedIndex}].captureId`,
        36,
        36,
      );
      const capture = captureById.get(captureId);
      if (capture == null) {
        throw new Error(
          `Grouping result references foreign capture ${captureId}`,
        );
      }
      if (!isUuid(captureId)) {
        throw new Error(
          `Grouping result has invalid capture ID ${captureId}`,
        );
      }
      if (capture.kind !== "photo") {
        throw new Error(
          `Grouping result rejects non-photo capture ${captureId}`,
        );
      }
      if (seen.has(captureId)) {
        throw new Error(`Grouping result duplicates capture ${captureId}`);
      }
      seen.add(captureId);

      if (rejected.classification !== "not_a_dish") {
        throw new Error(
          `rejectedCaptures[${rejectedIndex}].classification must be not_a_dish`,
        );
      }
      return {
        captureId,
        classification: "not_a_dish" as const,
        reason: boundedString(
          rejected.reason,
          `rejectedCaptures[${rejectedIndex}].reason`,
          1,
          180,
        ),
      };
    },
  );

  const missing = captures
    .map((capture) => capture.id)
    .filter((id) => !seen.has(id));
  if (missing.length > 0) {
    throw new Error(`Grouping result omits captures: ${missing.join(", ")}`);
  }

  for (const group of groups) {
    group.captureIds.sort(
      (left, right) =>
        captureById.get(left)!.ordinal - captureById.get(right)!.ordinal,
    );
  }
  groups.sort(
    (left, right) =>
      captureById.get(left.captureIds[0])!.ordinal -
      captureById.get(right.captureIds[0])!.ordinal,
  );
  rejectedCaptures.sort(
    (left, right) =>
      captureById.get(left.captureId)!.ordinal -
      captureById.get(right.captureId)!.ordinal,
  );

  return { groups, rejectedCaptures };
}

function objectValue(value: unknown, label: string): JsonObject {
  if (typeof value !== "object" || value == null || Array.isArray(value)) {
    throw new Error(`${label} must be an object`);
  }
  return value as JsonObject;
}

function arrayValue(value: unknown, label: string): unknown[] {
  if (!Array.isArray(value)) {
    throw new Error(`${label} must be an array`);
  }
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
  const items = arrayValue(value, label);
  if (items.length < minItems || items.length > maxItems) {
    throw new Error(
      `${label} must contain between ${minItems} and ${maxItems} items`,
    );
  }
  return items.map((item, index) =>
    boundedString(item, `${label}[${index}]`, 1, maxLength)
  );
}

function boundedString(
  value: unknown,
  label: string,
  minLength: number,
  maxLength: number,
) {
  if (typeof value !== "string") {
    throw new Error(`${label} must be a string`);
  }
  const normalized = value.trim().replace(/\s+/g, " ");
  if (normalized.length < minLength || normalized.length > maxLength) {
    throw new Error(
      `${label} must contain between ${minLength} and ${maxLength} characters`,
    );
  }
  return normalized;
}

function isUuid(value: string) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    .test(value);
}
