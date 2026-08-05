# AI evals

## Batch grouping

Run the deterministic contract and fake-provider evals:

```sh
deno test --allow-env --allow-net --allow-read --allow-sys \
  backend/supabase/evals/batch_grouping_eval_test.ts
```

Run the same suite plus the opt-in Gemini image examples:

```sh
set -a
source ~/dev/my_menu/.env
set +a

RUN_GEMINI_EVALS=1 \
deno test --allow-env --allow-net --allow-read --allow-sys \
  backend/supabase/evals/batch_grouping_eval_test.ts
```

The versioned `fixtures/everyday-dishes/v1/dataset.json` manifest defines the
real-image scenarios and their expected partitions. Its generated,
smartphone-style fixtures cover:

- grouping two different views of the same homemade chicken fried rice
- keeping a spaghetti marinara capture separate from that rice
- creating one usable draft from a standalone oatmeal capture
- preserving an idea-only capture as a singleton dish

The `fixtures/not-a-dish/v1/dataset.json` manifest contains user-provided,
metadata-stripped negative examples. It currently requires two landscape photos
and two views of a living bird to produce zero dish groups and four explicit
`not_a_dish` decisions.

The test checks exact capture partitioning plus tolerant, dish-relevant title
terms for positive cases. Negative cases require every expected capture ID to be
rejected with a non-empty visual reason. The run prints decisions and token
usage for review without printing credentials.

## Cover generation

Run the deterministic fake-provider integrity check:

```sh
deno test --allow-env --allow-net --allow-read --allow-sys \
  backend/supabase/evals/cover_generation_eval_test.ts
```

Run the two opt-in Gemini cover cases and save inspectable images locally:

```sh
set -a
source ~/dev/my_menu/.env
set +a

RUN_GEMINI_COVER_EVALS=1 \
COVER_EVAL_OUTPUT_DIR=backend/supabase/evals/output \
deno test --allow-env --allow-net --allow-read --allow-write --allow-sys \
  backend/supabase/evals/cover_generation_eval_test.ts
```

The versioned `fixtures/cover-generation/v1/dataset.json` manifest covers one
source-grounded Dish and one idea-only Dish. Each live case must pass image
decoding and dimensions, production semantic validation at 0.9 confidence, and
an independent visual-quality rubric. The rubric requires scores of at least 4/5
for recognizability, realism, composition, grounding, and expected visual
appearance, with no text, logos, watermarks, people, or body parts.

Generated images and JSON verdicts are written under the ignored `evals/output/`
directory. Fixtures are synthetic and the set is intentionally small; a pass is
a regression signal, not a broad quality claim.
