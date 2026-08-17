export type OperationalMetadata = Record<string, unknown>;

const allowedKeys = new Set([
  "action",
  "code",
  "durationMs",
  "expiredGuests",
  "expiredJobs",
  "inputTokens",
  "jobId",
  "model",
  "operation",
  "outputTokens",
  "state",
  "status",
]);

export function sanitizeOperationalMetadata(metadata: OperationalMetadata) {
  return Object.fromEntries(
    Object.entries(metadata).filter(([key, value]) =>
      allowedKeys.has(key) &&
      (typeof value === "string" ||
        typeof value === "number" ||
        typeof value === "boolean" ||
        value == null)
    ),
  );
}

export function operationalLog(
  event: string,
  metadata: OperationalMetadata = {},
) {
  console.log(event, sanitizeOperationalMetadata(metadata));
}

export function operationalError(
  event: string,
  code: string,
  metadata: OperationalMetadata = {},
) {
  console.error(
    event,
    sanitizeOperationalMetadata({ ...metadata, code }),
  );
}
