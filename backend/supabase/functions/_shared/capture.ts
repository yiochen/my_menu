export function extensionFor(contentType: string) {
  switch (contentType) {
    case "image/png":
      return "png";
    case "image/heic":
      return "heic";
    case "image/heif":
      return "heif";
    case "image/jpeg":
      return "jpg";
    default:
      throw new Error(`Unsupported content type: ${contentType}`);
  }
}

export function titleFrom(input: string) {
  const normalized = input.trim().replace(/\s+/g, " ");
  if (normalized.length === 0) {
    return "Captured Dish";
  }
  return normalized
    .split(" ")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}
