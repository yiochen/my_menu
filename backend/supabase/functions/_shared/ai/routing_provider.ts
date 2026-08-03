import { generateText, Output } from "npm:ai@7.0.37";
import { createGoogleGenerativeAI } from "npm:@ai-sdk/google@4.0.24";
import { jsonSchema } from "npm:@ai-sdk/provider-utils@5.0.12";
import type { GroupingCaptureInput } from "./grouping_contract.ts";
import { AiProviderFailure } from "./grouping_provider.ts";
import {
  captureRoutingContract,
  type CaptureRoutingOutput,
  type RoutingDishInput,
  validateAndCanonicalizeRouting,
} from "./routing_contract.ts";

export interface RoutingProviderResult {
  output: CaptureRoutingOutput;
  provenance: {
    provider: string;
    model: string;
    providerRequestId: string | null;
    usage: Record<string, unknown>;
  };
}

export interface RoutingProvider {
  readonly provider: string;
  readonly model: string;
  route(
    captures: GroupingCaptureInput[],
    dishes: RoutingDishInput[],
  ): Promise<RoutingProviderResult>;
}

export function createRoutingProvider(
  provider: string,
  model: string,
): RoutingProvider {
  if (provider === "fake") return new FakeRoutingProvider(model);
  if (provider === "google") {
    const key = Deno.env.get("GOOGLE_GENERATIVE_AI_API_KEY")?.trim();
    if (key == null || key.length === 0) {
      throw new AiProviderFailure(
        "ai_provider_not_configured",
        "Missing Google API key",
        false,
      );
    }
    return new GoogleRoutingProvider(model, key);
  }
  throw new AiProviderFailure(
    "ai_provider_not_supported",
    `Unsupported AI provider: ${provider}`,
    false,
  );
}

export class FakeRoutingProvider implements RoutingProvider {
  readonly provider = "fake";
  constructor(readonly model = "fake-context-router-v2") {}

  route(
    captures: GroupingCaptureInput[],
    dishes: RoutingDishInput[],
  ): Promise<RoutingProviderResult> {
    const decisions = captures.map((capture) => {
      const idea = capture.ideaText?.trim() ?? "";
      const matches = idea.length === 0
        ? []
        : dishes.filter((dish) => normalize(dish.title) === normalize(idea));
      if (matches.length === 1) {
        return {
          captureIds: [capture.id],
          outcome: { type: "existing_dish", localDishId: matches[0].localId },
          evidence: ["The idea title exactly matches an existing dish title."],
          uncertainty: [],
        };
      }
      if (matches.length > 1) {
        return {
          captureIds: [capture.id],
          outcome: { type: "unresolved" },
          evidence: ["Multiple existing dishes have the same title."],
          uncertainty: ["The destination dish is ambiguous."],
        };
      }
      const title = idea.length === 0 ? "Captured Dish" : titleCase(idea);
      return {
        captureIds: [capture.id],
        outcome: {
          type: "new_dish",
          draft: {
            title,
            description: "Deterministic local routing draft.",
            labels: [],
            visibleIngredients: [],
          },
        },
        evidence: ["No exact existing-dish title match was available."],
        uncertainty: [],
      };
    });
    return Promise.resolve({
      output: validateAndCanonicalizeRouting({ decisions }, captures, dishes),
      provenance: {
        provider: this.provider,
        model: this.model,
        providerRequestId: null,
        usage: {},
      },
    });
  }
}

export class GoogleRoutingProvider implements RoutingProvider {
  readonly provider = "google";
  constructor(readonly model: string, private readonly apiKey: string) {}

  async route(
    captures: GroupingCaptureInput[],
    dishes: RoutingDishInput[],
  ): Promise<RoutingProviderResult> {
    try {
      const google = createGoogleGenerativeAI({ apiKey: this.apiKey });
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
            data: new URL(capture.media.signedUrl),
            mediaType: capture.media.contentType,
            filename: capture.media.filename,
          });
        }
      }
      const result = await generateText({
        model: google(this.model),
        system: captureRoutingContract.systemPrompt,
        messages: [{ role: "user", content: content as any }],
        output: Output.object({
          schema: jsonSchema<CaptureRoutingOutput>(
            captureRoutingContract.outputSchema as any,
          ),
          name: "capture_routing",
          description: "A direct, complete routing decision for every capture.",
        }),
        abortSignal: AbortSignal.timeout(120_000),
        maxRetries: 0,
      });
      const response = result.response as {
        id?: string;
        headers?: Record<string, string>;
      };
      return {
        output: validateAndCanonicalizeRouting(result.output, captures, dishes),
        provenance: {
          provider: this.provider,
          model: this.model,
          providerRequestId: response.id ??
            response.headers?.["x-request-id"] ?? null,
          usage: jsonRecord(result.usage),
        },
      };
    } catch (error) {
      if (error instanceof AiProviderFailure) throw error;
      const details = error as {
        isRetryable?: boolean;
        statusCode?: number;
        name?: string;
        message?: string;
      };
      const retryable = details.isRetryable === true ||
        details.statusCode === 408 || details.statusCode === 429 ||
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

function normalize(value: string) {
  return value.trim().toLowerCase().replace(/\s+/g, " ");
}

function titleCase(value: string) {
  return value.trim().split(/\s+/).map((part) =>
    part.length === 0 ? part : `${part[0].toUpperCase()}${part.slice(1)}`
  ).join(" ");
}

function jsonRecord(value: unknown): Record<string, unknown> {
  const normalized = JSON.parse(JSON.stringify(value)) as unknown;
  return typeof normalized === "object" && normalized != null &&
      !Array.isArray(normalized)
    ? normalized as Record<string, unknown>
    : {};
}
