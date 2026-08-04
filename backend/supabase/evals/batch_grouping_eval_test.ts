import {
  FakeGroupingProvider,
  GoogleGroupingProvider,
} from "../functions/_shared/ai/grouping_provider.ts";
import {
  type BatchGroupingOutput,
  type GroupingCaptureInput,
  validateAndCanonicalizeGrouping,
} from "../functions/_shared/ai/grouping_contract.ts";
import {
  createRoutingProvider,
  FakeRoutingProvider,
} from "../functions/_shared/ai/routing_provider.ts";
import {
  type RoutingDishInput,
  validateAndCanonicalizeRouting,
} from "../functions/_shared/ai/routing_contract.ts";

interface EverydayDishDataset {
  datasetVersion: string;
  description: string;
  cases: EverydayDishCase[];
}

interface EverydayDishCase {
  id: string;
  name: string;
  captures: Array<{
    id: string;
    fixture: string;
    capturedLocalDate: string | null;
  }>;
  expectedGroups: Array<{
    captureIds: string[];
    titleContainsAny: string[];
  }>;
}

interface NotADishDataset {
  datasetVersion: string;
  description: string;
  cases: NotADishCase[];
}

interface NotADishCase {
  id: string;
  name: string;
  captures: Array<{
    id: string;
    fixture: string;
    capturedLocalDate: string | null;
  }>;
  expectedRejectedCaptureIds: string[];
}

const ids = {
  first: "10000000-0000-4000-8000-000000000001",
  second: "10000000-0000-4000-8000-000000000002",
  third: "10000000-0000-4000-8000-000000000003",
};

const everydayDataset = await loadEverydayDataset();
const notADishDataset = await loadNotADishDataset();

Deno.test("local eval: every capture is returned exactly once", async () => {
  const captures = [
    capture(ids.first, 0, "2026-07-20"),
    capture(ids.second, 1, "2026-07-20"),
    capture(ids.third, 2, null),
  ];
  const result = await new FakeGroupingProvider().group(captures);

  assertEquals(result.output.groups.length, 2);
  assertEquals(result.output.rejectedCaptures, []);
  assertEquals(result.output.groups[0].captureIds, [ids.first, ids.second]);
  assertEquals(result.output.groups[1].captureIds, [ids.third]);
});

Deno.test("local eval: idea captures become conservative singleton drafts", async () => {
  const result = await new FakeGroupingProvider().group([
    {
      ...capture(ids.first, 0, null),
      kind: "idea",
      ideaText: "lemon pasta with peas",
    },
  ]);

  assertEquals(result.output.groups.length, 1);
  assertEquals(result.output.rejectedCaptures, []);
  assertEquals(result.output.groups[0].draft.title, "Lemon Pasta With Peas");
  assertEquals(result.output.groups[0].captureIds, [ids.first]);
});

Deno.test("local eval: invalid partitions are rejected", () => {
  assertThrows(() =>
    validateAndCanonicalizeGrouping(
      {
        groups: [
          draftGroup([ids.first, ids.first]),
        ],
        rejectedCaptures: [],
      },
      [capture(ids.first, 0, null), capture(ids.second, 1, null)],
    )
  );
});

Deno.test("local eval: non-dish photos can form the entire partition", () => {
  const result = validateAndCanonicalizeGrouping(
    {
      groups: [],
      rejectedCaptures: [
        {
          captureId: ids.first,
          classification: "not_a_dish",
          reason: "The image shows a landscape.",
        },
        {
          captureId: ids.second,
          classification: "not_a_dish",
          reason: "The image shows a living bird.",
        },
      ],
    },
    [capture(ids.first, 0, null), capture(ids.second, 1, null)],
  );

  assertEquals(result.groups, []);
  assertEquals(
    result.rejectedCaptures.map((decision) => decision.captureId),
    [ids.first, ids.second],
  );
});

Deno.test("local eval: dish ideas cannot be rejected as non-dish photos", () => {
  assertThrows(() =>
    validateAndCanonicalizeGrouping(
      {
        groups: [],
        rejectedCaptures: [
          {
            captureId: ids.first,
            classification: "not_a_dish",
            reason: "Rejected incorrectly.",
          },
        ],
      },
      [
        {
          ...capture(ids.first, 0, null),
          kind: "idea",
          ideaText: "lemon pasta",
        },
      ],
    )
  );
});

Deno.test("local routing eval: an exact menu title routes to the existing dish", async () => {
  const result = await new FakeRoutingProvider().route([
    {
      ...capture(ids.first, 0, null),
      kind: "idea",
      ideaText: "lemon pasta",
    },
  ], [dish("dish-lemon", "Lemon Pasta")]);

  assertEquals(result.output.decisions, [
    {
      captureIds: [ids.first],
      outcome: { type: "existing_dish", localDishId: "dish-lemon" },
      evidence: ["The idea title exactly matches an existing dish title."],
      uncertainty: [],
    },
  ]);
  assert(!("confidence" in result.output.decisions[0]));
});

Deno.test("local routing eval: an unrelated capture becomes a new dish", async () => {
  const result = await new FakeRoutingProvider().route([
    {
      ...capture(ids.first, 0, null),
      kind: "idea",
      ideaText: "oatmeal with berries",
    },
  ], [dish("dish-lemon", "Lemon Pasta")]);

  assertEquals(result.output.decisions[0].outcome.type, "new_dish");
  assertEquals(result.output.decisions[0].uncertainty, []);
});

Deno.test("local routing eval: ambiguous destinations become unresolved", async () => {
  const result = await new FakeRoutingProvider().route([
    {
      ...capture(ids.first, 0, null),
      kind: "idea",
      ideaText: "fried rice",
    },
  ], [
    dish("dish-rice-one", "Fried Rice"),
    dish("dish-rice-two", "Fried Rice"),
  ]);

  assertEquals(result.output.decisions[0].outcome.type, "unresolved");
  assert(result.output.decisions[0].uncertainty.length > 0);
});

Deno.test("local routing eval: Google free tier needs no data-policy attestation", () => {
  const previousKey = Deno.env.get("GOOGLE_GENERATIVE_AI_API_KEY");
  const previousPolicy = Deno.env.get("AI_DATA_POLICY");
  try {
    Deno.env.set("GOOGLE_GENERATIVE_AI_API_KEY", "test-key");
    Deno.env.delete("AI_DATA_POLICY");
    assertEquals(
      createRoutingProvider("google", "test-model").provider,
      "google",
    );
  } finally {
    restoreEnv("GOOGLE_GENERATIVE_AI_API_KEY", previousKey);
    restoreEnv("AI_DATA_POLICY", previousPolicy);
  }
});

Deno.test("local routing eval: mixed outcomes must exactly partition captures", () => {
  const output = validateAndCanonicalizeRouting({
    decisions: [
      {
        captureIds: [ids.first],
        outcome: { type: "existing_dish", localDishId: "dish-rice" },
        evidence: ["The visible dish matches the saved fried rice."],
        uncertainty: [],
      },
      {
        captureIds: [ids.second],
        outcome: { type: "unresolved" },
        evidence: ["A prepared dish is visible."],
        uncertainty: ["Two menu entries are equally plausible."],
      },
      {
        captureIds: [ids.third],
        outcome: { type: "not_a_dish" },
        evidence: ["The photo shows a landscape."],
        uncertainty: [],
      },
    ],
  }, [
    capture(ids.first, 0, null),
    capture(ids.second, 1, null),
    capture(ids.third, 2, null),
  ], [dish("dish-rice", "Fried Rice")]);

  assertEquals(output.decisions.length, 3);
  assertThrows(() =>
    validateAndCanonicalizeRouting(
      {
        decisions: [
          {
            captureIds: [ids.first, ids.first],
            outcome: { type: "new_dish", draft: routingDraft("Dish") },
            evidence: ["Duplicate test."],
            uncertainty: [],
          },
        ],
      },
      [capture(ids.first, 0, null)],
      [],
    )
  );
});

const runGemini = Deno.env.get("RUN_GEMINI_EVALS") === "1";

for (const scenario of everydayDataset.cases) {
  Deno.test({
    name: `Gemini eval [${everydayDataset.datasetVersion}]: ${scenario.name}`,
    ignore: !runGemini,
    fn: async () => {
      const captures = await Promise.all(
        scenario.captures.map(async (item, ordinal) => {
          const fixture = await fixtureDataUrl(
            `fixtures/everyday-dishes/v1/${item.fixture}`,
          );
          return photoCapture(
            item.id,
            ordinal,
            fixture.dataUrl,
            fixture.contentType,
            item.fixture,
            item.capturedLocalDate,
          );
        }),
      );
      const result = await gemini().group(captures);

      assertEverydayScenario(scenario, result.output);
      console.log(JSON.stringify(
        {
          datasetVersion: everydayDataset.datasetVersion,
          scenario: scenario.id,
          provider: result.provenance.provider,
          model: result.provenance.model,
          groups: result.output.groups.map((group) => ({
            captureIds: group.captureIds,
            title: group.draft.title,
            visibleIngredients: group.draft.visibleIngredients,
          })),
          rejectedCaptures: result.output.rejectedCaptures,
          usage: result.provenance.usage,
        },
        null,
        2,
      ));
    },
  });
}

for (const scenario of notADishDataset.cases) {
  Deno.test({
    name: `Gemini eval [${notADishDataset.datasetVersion}]: ${scenario.name}`,
    ignore: !runGemini,
    fn: async () => {
      const captures = await Promise.all(
        scenario.captures.map(async (item, ordinal) => {
          const fixture = await fixtureDataUrl(
            `fixtures/not-a-dish/v1/${item.fixture}`,
          );
          return photoCapture(
            item.id,
            ordinal,
            fixture.dataUrl,
            fixture.contentType,
            item.fixture,
            item.capturedLocalDate,
          );
        }),
      );
      const result = await gemini().group(captures);

      assertEquals(result.output.groups, []);
      assertEquals(
        result.output.rejectedCaptures.map((decision) => decision.captureId),
        scenario.expectedRejectedCaptureIds,
      );
      assert(
        result.output.rejectedCaptures.every((decision) =>
          decision.classification === "not_a_dish" &&
          decision.reason.length > 0
        ),
        "Expected every negative fixture to have a not_a_dish decision",
      );
      console.log(JSON.stringify(
        {
          datasetVersion: notADishDataset.datasetVersion,
          scenario: scenario.id,
          provider: result.provenance.provider,
          model: result.provenance.model,
          groups: result.output.groups,
          rejectedCaptures: result.output.rejectedCaptures,
          usage: result.provenance.usage,
        },
        null,
        2,
      ));
    },
  });
}

Deno.test({
  name: "Gemini eval: an idea is preserved as a singleton dish",
  ignore: !runGemini,
  fn: async () => {
    const result = await gemini().group([
      {
        ...capture(ids.first, 0, null),
        kind: "idea",
        ideaText: "crispy tofu rice bowl with cucumber",
      },
    ]);

    assertEquals(result.output.groups.length, 1);
    assertEquals(result.output.groups[0].captureIds, [ids.first]);
    assert(result.output.groups[0].draft.title.length > 0);
    assertEquals(result.output.rejectedCaptures, []);
  },
});

function gemini() {
  const apiKey = Deno.env.get("GOOGLE_GENERATIVE_AI_API_KEY");
  if (apiKey == null || apiKey.length === 0) {
    throw new Error(
      "GOOGLE_GENERATIVE_AI_API_KEY is required when RUN_GEMINI_EVALS=1",
    );
  }
  return new GoogleGroupingProvider(
    Deno.env.get("AI_MODEL") ?? "gemini-3.6-flash",
    apiKey,
  );
}

function capture(
  id: string,
  ordinal: number,
  capturedLocalDate: string | null,
): GroupingCaptureInput {
  return {
    id,
    ordinal,
    kind: "photo",
    ideaText: null,
    capturedLocalDate,
  };
}

function photoCapture(
  id: string,
  ordinal: number,
  dataUrl: string,
  contentType = "image/png",
  filename = `${id}.png`,
  capturedLocalDate: string | null = null,
): GroupingCaptureInput {
  return {
    ...capture(id, ordinal, capturedLocalDate),
    media: {
      contentType,
      signedUrl: dataUrl,
      filename,
    },
  };
}

function draftGroup(captureIds: string[]) {
  return {
    captureIds,
    draft: {
      title: "Dish",
      description: "",
      labels: [],
      visibleIngredients: [],
    },
    evidence: ["Test evidence"],
    uncertainty: [],
  };
}

function dish(localId: string, title: string): RoutingDishInput {
  return {
    localId,
    title,
    description: "",
    ingredients: [],
    recipeSteps: [],
    notes: [],
  };
}

function routingDraft(title: string) {
  return {
    title,
    description: "",
    labels: [],
    visibleIngredients: [],
    coverSourceCaptureIds: [],
  };
}

async function fixtureDataUrl(relativePath: string) {
  const bytes = await Deno.readFile(new URL(relativePath, import.meta.url));
  let binary = "";
  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }
  const contentType = relativePath.endsWith(".jpg") ||
      relativePath.endsWith(".jpeg")
    ? "image/jpeg"
    : "image/png";
  return {
    contentType,
    dataUrl: `data:${contentType};base64,${btoa(binary)}`,
  };
}

async function loadEverydayDataset(): Promise<EverydayDishDataset> {
  const text = await Deno.readTextFile(
    new URL(
      "fixtures/everyday-dishes/v1/dataset.json",
      import.meta.url,
    ),
  );
  return JSON.parse(text) as EverydayDishDataset;
}

async function loadNotADishDataset(): Promise<NotADishDataset> {
  const text = await Deno.readTextFile(
    new URL(
      "fixtures/not-a-dish/v1/dataset.json",
      import.meta.url,
    ),
  );
  return JSON.parse(text) as NotADishDataset;
}

function assertEverydayScenario(
  scenario: EverydayDishCase,
  output: BatchGroupingOutput,
) {
  assertEquals(output.groups.length, scenario.expectedGroups.length);
  assertEquals(output.rejectedCaptures, []);

  for (const expected of scenario.expectedGroups) {
    const actual = output.groups.find((group) =>
      sameMembers(group.captureIds, expected.captureIds)
    );
    assert(
      actual != null,
      `Expected group containing ${expected.captureIds.join(", ")}`,
    );
    const normalizedTitle = actual.draft.title.toLowerCase();
    assert(
      expected.titleContainsAny.some((term) =>
        normalizedTitle.includes(term.toLowerCase())
      ),
      `Expected title "${actual.draft.title}" to contain one of: ${
        expected.titleContainsAny.join(", ")
      }`,
    );
  }
}

function sameMembers(left: string[], right: string[]) {
  return left.length === right.length &&
    [...left].sort().every((value, index) =>
      value === [...right].sort()[index]
    );
}

function assert(
  condition: unknown,
  message = "Assertion failed",
): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEquals(actual: unknown, expected: unknown) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}

function assertThrows(action: () => unknown) {
  try {
    action();
  } catch {
    return;
  }
  throw new Error("Expected action to throw");
}

function restoreEnv(name: string, value: string | undefined) {
  if (value == null) {
    Deno.env.delete(name);
  } else {
    Deno.env.set(name, value);
  }
}
