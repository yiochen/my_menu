import { generateText, Output, uploadFile } from "npm:ai@7.0.37";
import { createGoogleGenerativeAI } from "npm:@ai-sdk/google@4.0.24";
import { jsonSchema } from "npm:@ai-sdk/provider-utils@5.0.12";
import { loadCaptureMediaBytes } from "./capture_media.ts";
import {
  batchGroupingContract,
  type BatchGroupingOutput,
  type GroupingCaptureInput,
  validateAndCanonicalizeGrouping,
} from "./grouping_contract.ts";
import { AiProviderFailure } from "./provider_failure.ts";

export { AiProviderFailure } from "./provider_failure.ts";

export interface GroupingProviderResult {
  output: BatchGroupingOutput;
  provenance: {
    provider: string;
    model: string;
    providerRequestId: string | null;
    usage: Record<string, unknown>;
  };
}

export interface GroupingProvider {
  readonly provider: string;
  readonly model: string;
  group(captures: GroupingCaptureInput[]): Promise<GroupingProviderResult>;
}

export function createGroupingProvider(
  provider: string,
  model: string,
): GroupingProvider {
  switch (provider) {
    case "fake":
      return new FakeGroupingProvider(model);
    case "google":
      return new GoogleGroupingProvider(
        model,
        requireProviderEnv(
          "GOOGLE_GENERATIVE_AI_API_KEY",
        ),
      );
    default:
      throw new AiProviderFailure(
        "ai_provider_not_supported",
        `Unsupported AI provider: ${provider}`,
        false,
      );
  }
}

export class FakeGroupingProvider implements GroupingProvider {
  readonly provider = "fake";

  constructor(readonly model = "fake-date-grouper-v2") {}

  group(
    captures: GroupingCaptureInput[],
  ): Promise<GroupingProviderResult> {
    const grouped = new Map<string, GroupingCaptureInput[]>();
    for (const capture of captures) {
      const key = capture.kind === "idea"
        ? `idea:${capture.id}`
        : capture.capturedLocalDate == null
        ? `unknown:${capture.id}`
        : `date:${capture.capturedLocalDate}`;
      const values = grouped.get(key) ?? [];
      values.push(capture);
      grouped.set(key, values);
    }

    const rawOutput = {
      groups: [...grouped.values()].map((members) => {
        const first = members[0];
        const idea = first.ideaText?.trim();
        const title = idea == null || idea.length === 0
          ? first.capturedLocalDate == null
            ? "Captured Dish"
            : `Captured Dish · ${first.capturedLocalDate}`
          : titleCase(idea);
        return {
          captureIds: members.map((capture) => capture.id),
          draft: {
            title,
            description: "Deterministic local AI grouping draft.",
            labels: ["capture", "local-eval"],
            visibleIngredients: [],
          },
          evidence: [
            members.length === 1
              ? "Kept as one capture in the deterministic local provider."
              : "Grouped by matching capture date in the deterministic local provider.",
          ],
          uncertainty: [],
        };
      }),
      rejectedCaptures: [],
    };

    return Promise.resolve({
      output: validateAndCanonicalizeGrouping(rawOutput, captures),
      provenance: {
        provider: this.provider,
        model: this.model,
        providerRequestId: null,
        usage: {},
      },
    });
  }
}

export class GoogleGroupingProvider implements GroupingProvider {
  readonly provider = "google";

  constructor(
    readonly model: string,
    private readonly apiKey: string,
  ) {}

  async group(
    captures: GroupingCaptureInput[],
  ): Promise<GroupingProviderResult> {
    try {
      const google = createGoogleGenerativeAI({ apiKey: this.apiKey });
      const content: Array<Record<string, unknown>> = [
        {
          type: "text",
          text:
            `Partition these ${captures.length} captures. The capture ID written immediately before each image identifies that image.`,
        },
      ];

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
          if (capture.media == null) {
            throw new AiProviderFailure(
              "capture_media_missing",
              `Photo capture ${capture.id} has no media`,
              false,
            );
          }

          const bytes = await loadCaptureMediaBytes(capture);

          if (
            capture.media.contentType === "image/heic" ||
            capture.media.contentType === "image/heif"
          ) {
            const uploaded = await uploadFile({
              api: google,
              data: bytes,
              mediaType: capture.media.contentType,
              filename: capture.media.filename,
            });
            content.push({
              type: "file",
              data: uploaded.providerReference,
              mediaType: capture.media.contentType,
              filename: capture.media.filename,
            });
          } else {
            content.push({
              type: "file",
              data: bytes,
              mediaType: capture.media.contentType,
              filename: capture.media.filename,
            });
          }
        }
      }

      const result = await generateText({
        model: google(this.model),
        system: batchGroupingContract.systemPrompt,
        messages: [
          {
            role: "user",
            content: content as any,
          },
        ],
        output: Output.object({
          schema: jsonSchema<BatchGroupingOutput>(
            batchGroupingContract.outputSchema as any,
          ),
          name: "batch_grouping",
          description: "A complete partition of the submitted capture IDs.",
        }),
        abortSignal: AbortSignal.timeout(120_000),
        maxRetries: 0,
      });

      const response = result.response as {
        id?: string;
        headers?: Record<string, string>;
      };
      const requestId = response.id ??
        response.headers?.["x-request-id"] ??
        response.headers?.["x-goog-request-id"] ??
        null;
      return {
        output: validateAndCanonicalizeGrouping(result.output, captures),
        provenance: {
          provider: this.provider,
          model: this.model,
          providerRequestId: requestId,
          usage: jsonRecord(result.usage),
        },
      };
    } catch (error) {
      if (error instanceof AiProviderFailure) {
        throw error;
      }
      const details = error as {
        isRetryable?: boolean;
        statusCode?: number;
        name?: string;
        message?: string;
      };
      const retryable = details.isRetryable === true ||
        details.statusCode === 408 ||
        details.statusCode === 429 ||
        (details.statusCode != null && details.statusCode >= 500) ||
        details.name === "TimeoutError";
      throw new AiProviderFailure(
        retryable ? "ai_provider_transient" : "ai_provider_invalid_response",
        details.message ?? String(error),
        retryable,
        { cause: error },
      );
    }
  }
}

function requireProviderEnv(name: string) {
  const value = Deno.env.get(name);
  if (value == null || value.trim().length === 0) {
    throw new AiProviderFailure(
      "ai_provider_not_configured",
      `Missing required environment variable: ${name}`,
      false,
    );
  }
  return value;
}

function jsonRecord(value: unknown): Record<string, unknown> {
  const normalized = JSON.parse(JSON.stringify(value)) as unknown;
  return typeof normalized === "object" &&
      normalized != null &&
      !Array.isArray(normalized)
    ? normalized as Record<string, unknown>
    : {};
}

function titleCase(value: string) {
  return value
    .trim()
    .split(/\s+/)
    .map((part) =>
      part.length === 0 ? part : `${part[0].toUpperCase()}${part.slice(1)}`
    )
    .join(" ");
}
