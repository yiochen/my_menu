import { loadCaptureMediaBytes } from "./capture_media.ts";
import type { GroupingCaptureInput } from "./grouping_contract.ts";
import { AiProviderFailure } from "./provider_failure.ts";
import type { RoutingDishInput } from "./routing_contract.ts";

export async function buildRoutingContent(
  captures: GroupingCaptureInput[],
  dishes: RoutingDishInput[],
): Promise<Array<Record<string, unknown>>> {
  const content: Array<Record<string, unknown>> = [{
    type: "text",
    text: JSON.stringify({ existingDishes: dishes }),
  }];
  for (const capture of captures) {
    content.push({
      type: "text",
      text: JSON.stringify({
        captureId: capture.id,
        ordinal: capture.ordinal,
        kind: capture.kind,
        capturedLocalDate: capture.capturedLocalDate,
        ...(capture.kind === "idea"
          ? { ideaText: capture.ideaText ?? "" }
          : {}),
      }),
    });
    if (capture.kind === "photo") {
      if (
        capture.media == null ||
        !["image/jpeg", "image/png"].includes(capture.media.contentType)
      ) {
        throw new AiProviderFailure(
          "capture_media_invalid",
          `Photo ${capture.id} must use a reduced JPEG or PNG processing asset`,
          false,
        );
      }
      content.push({
        type: "file",
        data: await loadCaptureMediaBytes(capture),
        mediaType: capture.media.contentType,
        filename: capture.media.filename,
      });
    }
  }
  return content;
}
