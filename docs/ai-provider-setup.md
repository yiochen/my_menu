# AI provider setup

> **Transition status:** This file describes the current pre-transition worker
> and deployment names. The target processing and retention architecture is in
> [Supabase Service Backend Design](supabase-backend-design.md). Do not treat a
> provider/model as production-approved until its no-training and retention
> configuration has been verified against that design.

MyMenu calls model vendors directly. It does not use OpenRouter or the Vercel
AI Gateway.

The current implementation is configured for Google Gemini:

- provider: `google`
- model:
  [`gemini-3.6-flash`](https://ai.google.dev/gemini-api/docs/models/gemini-3.6-flash)
- prompt contract:
  `backend/supabase/functions/_shared/ai/prompts/batch-grouping/v2/contract.json`

The prompt and JSON output schema are versioned data, separate from the worker
code. Every queued job records its provider, model, prompt version, and schema
version.

## 1. Create a Gemini API key

Create an API key in
[Google AI Studio](https://aistudio.google.com/app/apikey). Do not add the key
to `.env`, Flutter Dart defines, or the repository. The mobile app never
receives it.

## 2. Configure the linked Supabase project

Generate a separate worker key and set the Edge Function secrets:

```sh
cd backend

export AI_WORKER_KEY="$(openssl rand -hex 32)"

supabase secrets set \
  AI_PROVIDER=google \
  AI_MODEL=gemini-3.6-flash \
  GOOGLE_GENERATIVE_AI_API_KEY='<your-google-api-key>' \
  AI_WORKER_KEY="$AI_WORKER_KEY"
```

`AI_WORKER_KEY` protects the internal worker route. It is intentionally
different from the Supabase service-role key. The first batch dispatch stores
the project URL and this worker key in Supabase Vault so the one-minute cron
recovery dispatch can wake the worker after a transient failure.

## 3. Deploy the database and functions

```sh
cd backend

supabase db push
supabase functions deploy finalize-capture-batch
supabase functions deploy process-ai-jobs --no-verify-jwt
```

JWT verification is disabled only at the Supabase gateway for
`process-ai-jobs`; the function itself requires the dedicated
`x-mymenu-worker-key`. User-facing functions still require a valid Supabase
session.

## 4. Run the phone app against Supabase

From `apps/mobile_flutter/`:

```sh
flutter run \
  --dart-define=SUPABASE_URL='https://<project-ref>.supabase.co' \
  --dart-define=SUPABASE_ANON_KEY='<project-anon-key>'
```

Take or import one to nine food photos. The current app uploads the originals,
queues a grouping job, and can be closed while Gemini works. Recent Captures
shows queued/running/retrying/failed state. This server-applied result flow is
legacy behavior that the local-first transition replaces with a proposal the
client downloads and adopts locally.

If processing fails, use **Retry organization**. The original captures stay
unchanged until the grouping result is validated and atomically applied.

## Local evals

Run the deterministic contract and fake-provider cases:

```sh
deno test --allow-env --allow-net --allow-read --allow-sys \
  backend/supabase/evals/batch_grouping_eval_test.ts
```

Run the opt-in real Gemini cases:

```sh
RUN_GEMINI_EVALS=1 \
GOOGLE_GENERATIVE_AI_API_KEY='<your-google-api-key>' \
AI_MODEL=gemini-3.6-flash \
deno test --allow-env --allow-net --allow-read --allow-sys \
  backend/supabase/evals/batch_grouping_eval_test.ts
```

The real cases cover two identical views plus a different dish, a single food
image, an idea-only capture, and real-world landscape and living-bird negatives
that must not create dishes.

## Switching providers later

Provider selection is server-wide through `AI_PROVIDER` and `AI_MODEL`.
`createGroupingProvider` is the only factory the worker calls. A new direct
provider is added by implementing the small `GroupingProvider` interface and
registering one factory branch:

- OpenAI: direct `@ai-sdk/openai` adapter
- Anthropic Claude: direct `@ai-sdk/anthropic` adapter
- Kimi or another self-hosted model: an OpenAI-compatible adapter pointed at
  that deployment's base URL

The prompt contract, semantic partition validator, database transaction,
Flutter client, and local fake do not change. Provider credentials remain
server-side secrets.
