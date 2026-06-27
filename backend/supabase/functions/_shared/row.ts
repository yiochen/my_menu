export function stringValue(row: Record<string, unknown>, key: string) {
  const value = row[key];
  if (typeof value !== "string" || value.length === 0) {
    throw new Error(`Expected string at ${key}`);
  }
  return value;
}

export function optionalStringValue(row: Record<string, unknown>, key: string) {
  const value = row[key];
  return typeof value === "string" ? value : null;
}

export function optionalNumberValue(row: Record<string, unknown>, key: string) {
  const value = row[key];
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

export function numberValue(
  row: Record<string, unknown>,
  key: string,
  fallback: number,
) {
  return optionalNumberValue(row, key) ?? fallback;
}

export function booleanValue(
  row: Record<string, unknown>,
  key: string,
  fallback = false,
) {
  const value = row[key];
  return typeof value === "boolean" ? value : fallback;
}

export function stringArrayValue(row: Record<string, unknown>, key: string) {
  const value = row[key];
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === "string")
    : [];
}

export function objectValue(row: Record<string, unknown>, key: string) {
  const value = row[key];
  return typeof value === "object" && value != null
    ? value as Record<string, unknown>
    : null;
}
