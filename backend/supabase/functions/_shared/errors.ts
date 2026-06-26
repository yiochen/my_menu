export function errorMessage(error: unknown) {
  return error instanceof Error ? error.message : "Server error";
}

export function isNotFoundError(error: unknown) {
  if (typeof error !== "object" || error == null) {
    return false;
  }
  const code = "code" in error ? (error as { code?: unknown }).code : null;
  return code === "P0002";
}
