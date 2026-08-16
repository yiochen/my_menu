import type { GroupingCaptureInput } from "./grouping_contract.ts";
import { AiProviderFailure } from "./provider_failure.ts";

export async function loadCaptureMediaBytes(
  capture: GroupingCaptureInput,
): Promise<Uint8Array> {
  const media = capture.media;
  if (media == null) {
    throw new AiProviderFailure(
      "capture_media_missing",
      `Photo capture ${capture.id} has no media`,
      false,
    );
  }
  if (media.loadBytes != null) {
    return await media.loadBytes();
  }
  if (media.signedUrl == null || media.signedUrl.length === 0) {
    throw new AiProviderFailure(
      "capture_media_unavailable",
      `Photo capture ${capture.id} media is unavailable`,
      true,
    );
  }
  const response = await fetch(media.signedUrl);
  if (!response.ok) {
    throw new AiProviderFailure(
      "capture_media_unavailable",
      `Photo capture ${capture.id} media download failed`,
      response.status === 408 || response.status === 429 ||
        response.status >= 500,
    );
  }
  return new Uint8Array(await response.arrayBuffer());
}
