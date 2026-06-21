# Supabase Backend Design

## Purpose

MyMenu should use Supabase for auth, storage, Postgres, and server-side work,
but the Flutter app should not talk directly to database tables or depend on the
database schema.

The client-facing contract is:

- Flutter calls Edge Functions.
- Edge Functions validate auth, enforce ownership, and call Postgres RPCs.
- Postgres stores the durable cloud backup for every user-owned local object.
- Supabase Storage stores image bytes.

This keeps the app local-first while still making the user's menu recoverable if
they switch phones.

## Project Setup and Operations

The Supabase project for this backend is:

```txt
ydzoibvdnumaejurhuyo
```

The dashboard URL is:

```txt
https://supabase.com/dashboard/project/ydzoibvdnumaejurhuyo
```

Keep the Supabase CLI project under `backend/supabase/`. Run Supabase CLI
commands from `backend/`, so the CLI sees the nested `supabase/` directory as
its project directory.

Initial local setup:

```bash
brew install supabase/tap/supabase
cd backend
supabase login
supabase init
supabase link --project-ref ydzoibvdnumaejurhuyo
```

If `supabase init` has already created `backend/supabase/config.toml`, do not
run it again unless intentionally reinitializing the local Supabase project.

Run the Flutter app against Supabase by passing the project URL and publishable
anon key as Dart defines:

```bash
cd apps/mobile_flutter
flutter run \
  --dart-define=SUPABASE_URL=https://ydzoibvdnumaejurhuyo.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<publishable-anon-key>
```

If either Dart define is missing, the app uses the local fake API client for
product iteration and tests.

Supabase GitHub Integration should be configured in the dashboard with:

- repository: this GitHub repository
- working directory: `backend`
- production branch: `main`

With that working directory, Supabase will read `backend/supabase/` as the
project's Supabase directory. Production deploys should use the Supabase GitHub
Integration instead of a custom GitHub Actions deployment workflow unless there
is a concrete need for custom deployment behavior.

Keep as much backend configuration in GitHub as Supabase supports:

- database migrations in `backend/supabase/migrations/`
- RLS policies and Postgres RPCs in migrations
- Edge Functions in `backend/supabase/functions/`
- storage bucket declarations in `backend/supabase/config.toml`
- seed data and database/function tests when introduced

Do not commit secrets or machine-local state. Keep these outside the repo:

- Supabase access tokens
- database passwords
- production API keys
- OAuth provider secrets
- Edge Function secrets
- generated local environment files

Some Supabase project settings may still need to live in the dashboard or in
Supabase-managed secrets. When a setting cannot be represented in
`config.toml`, document the dashboard setting here or in the relevant migration
or function README.

## Design Principles

- Local SQLite remains the mobile source of truth for UI.
- The server is the durable backup and AI orchestration system.
- Capturing a photo does not automatically create a dish.
- Client-generated UUIDs are canonical IDs for client-created records.
- Server-generated IDs are used only for records created entirely on the server,
  such as AI-generated dish drafts or generated images.
- All server data is scoped by `user_id`.
- Flutter receives app-facing JSON DTOs, not raw table rows.
- Database RPCs are internal to Edge Functions unless explicitly noted.

### ID Strategy

Use client-generated UUIDs directly for records created on the phone:

- captures
- planned meals
- user-created dishes
- user-created notes, ingredients, and steps

The collision risk is negligible, especially because data is also scoped by
`user_id`. Reusing the same ID on retry is helpful because it makes writes
idempotent. If an upload or mutation is retried, the server can safely treat the
same `(user_id, id)` as the same object.

For records created by the backend, such as AI draft dishes and AI generated
images, the server creates the ID and returns it through `sync.pull` or the
specific Edge Function response.

## Core Server Objects

### User Profile

One row per Supabase auth user.

```sql
create table public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

### Dishes

Durable objects representing things the user can cook. Dishes hold the stable
knowledge about the food: title, notes, recipe details, labels, and the selected
cover image.

Cooking history is derived from image rows, not stored directly on `dishes`.
`made_count`, `last_made_at`, and `latest_source_image_id` should come from the
`dish_images` table.

`creation_source` records provenance: whether the dish was manually created,
created as an AI draft from a capture, or imported. This is useful for audit,
review UX, and deciding how much trust to place in generated fields.

`labels` are flexible user-facing text tags such as `weeknight`, `seafood`,
`kid-friendly`, `comfort`, or `needs work`. There is no fixed category taxonomy.

```sql
create type public.dish_creation_source as enum (
  'manual',
  'ai_capture',
  'imported'
);

create table public.dishes (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text not null default '',
  cover_image_id uuid,
  labels text[] not null default '{}',
  prep_minutes integer,
  difficulty text,
  is_favorite boolean not null default false,
  creation_source public.dish_creation_source not null default 'manual',
  created_from_capture_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index dishes_user_updated_idx on public.dishes(user_id, updated_at);
create index dishes_labels_idx on public.dishes using gin(labels);
```

The `cover_image_id` foreign key can be added after `dish_images` exists:

```sql
alter table public.dishes
  add constraint dishes_cover_image_id_fkey
  foreign key (cover_image_id)
  references public.dish_images(id)
  on delete set null;
```

### Dish Details

Structured details are separated so the app can sync them independently later.
For early MVP, Edge Functions may return these embedded in the dish DTO.

```sql
create table public.dish_notes (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  dish_id uuid not null references public.dishes(id) on delete cascade,
  body text not null,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.dish_ingredients (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  dish_id uuid not null references public.dishes(id) on delete cascade,
  body text not null,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.dish_steps (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  dish_id uuid not null references public.dishes(id) on delete cascade,
  body text not null,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);
```

### Captures

A capture is a raw photo or idea. It is not a dish. It can eventually become a
source image, a review item, a new dish draft, or be discarded.

There is no server-side `pending_upload` status. If a photo has not uploaded
yet, it exists only in the local Flutter database and local file store. The
server creates the capture row only after the bytes are in Supabase Storage.

```sql
create type public.capture_kind as enum ('photo', 'idea');
create type public.capture_status as enum (
  'classifying',
  'needs_review',
  'applied',
  'discarded',
  'failed'
);

create table public.captures (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  kind public.capture_kind not null,
  status public.capture_status not null default 'classifying',
  idea_text text,
  applied_dish_id uuid references public.dishes(id),
  failure_reason text,
  captured_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index captures_user_updated_idx on public.captures(user_id, updated_at);
```

### Dish Images

Dish images are first-class records for every image attached to the capture and
dish lifecycle:

- uploaded capture photos before classification
- real source photos attached to dishes
- AI-generated cover candidates
- the currently selected cover image

The image bytes live in Supabase Storage. Postgres stores metadata, ownership,
relationships, labels, and the Storage object location.

```sql
create type public.dish_image_kind as enum (
  'capture_photo',
  'source_photo',
  'ai_generated'
);

create table public.dish_images (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  dish_id uuid references public.dishes(id) on delete set null,
  capture_id uuid references public.captures(id) on delete set null,
  kind public.dish_image_kind not null,
  storage_bucket text not null default 'menu-media',
  storage_path text not null,
  content_type text not null,
  byte_size bigint,
  width integer,
  height integer,
  sha256 text,
  note text,
  labels text[] not null default '{}',
  confidence_label text,
  captured_at timestamptz,
  generated_at timestamptz,
  generation_prompt text,
  generation_model text,
  source_image_ids uuid[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique(user_id, storage_bucket, storage_path)
);

create index dish_images_dish_time_idx
  on public.dish_images(dish_id, captured_at desc)
  where deleted_at is null;

create index dish_images_capture_idx
  on public.dish_images(capture_id)
  where deleted_at is null;

create index dish_images_labels_idx
  on public.dish_images using gin(labels);
```

When a captured photo is confidently attached to a dish, the same `dish_images`
row changes from `capture_photo` to `source_photo`, gets a `dish_id`, and keeps
its original `captured_at`.

When AI generates a cover candidate, it creates a new `dish_images` row with
`kind = 'ai_generated'`, `dish_id`, `generated_at`, prompt/model metadata, and
the source image IDs used as inputs. If the user accepts it as the cover,
`dishes.cover_image_id` points to that image row.

### Dish Cooking Stats

The server can expose cooking history through Edge Function DTOs or a view. The
important point is that these values are derived from real source images.

For MVP, one `source_photo` image counts as one cooking event. If we later let
users attach multiple photos to the same time they made a dish, add a
`cooking_sessions` table or a shared `made_event_id` on `dish_images`.

```sql
create view public.dish_cooking_stats as
select
  d.id as dish_id,
  count(i.id) filter (
    where i.kind = 'source_photo' and i.deleted_at is null
  ) as made_count,
  max(i.captured_at) filter (
    where i.kind = 'source_photo' and i.deleted_at is null
  ) as last_made_at,
  (
    select latest.id
    from public.dish_images latest
    where latest.dish_id = d.id
      and latest.kind = 'source_photo'
      and latest.deleted_at is null
    order by latest.captured_at desc nulls last, latest.created_at desc
    limit 1
  ) as latest_source_image_id
from public.dishes d
left join public.dish_images i on i.dish_id = d.id
group by d.id;
```

### Review Items

Review items appear only when AI is unsure whether a capture belongs to an
existing dish or should become a new dish.

```sql
create type public.review_status as enum ('open', 'resolved', 'dismissed');

create table public.review_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  capture_id uuid not null references public.captures(id) on delete cascade,
  status public.review_status not null default 'open',
  summary text not null,
  suggested_dish_ids uuid[] not null default '{}',
  suggested_new_dish jsonb,
  confidence_label text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  resolved_at timestamptz
);
```

### Planned Meals

The weekly plan is user-owned data and must be backed up. Labels are a list so a
planned meal can carry multiple bits of context, such as `dinner`, `guests`,
`prep`, or `leftovers`.

```sql
create table public.planned_meals (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  dish_id uuid not null references public.dishes(id) on delete cascade,
  day_key date not null,
  labels text[] not null default '{}',
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index planned_meals_user_day_idx
  on public.planned_meals(user_id, day_key, position);

create index planned_meals_labels_idx
  on public.planned_meals using gin(labels);
```

### Sync Ledger

The sync ledger gives the client a simple way to pull everything changed since a
known cursor. Edge Functions write one event per meaningful mutation.

```sql
create table public.sync_events (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  entity_type text not null,
  entity_id uuid not null,
  operation text not null,
  payload jsonb,
  created_at timestamptz not null default now()
);

create index sync_events_user_id_idx on public.sync_events(user_id, id);
```

## Storage

Supabase Storage is the byte store. It uses a bucket/object model similar to S3,
and Supabase also documents S3-compatible access for Storage. For MyMenu, the
database should never store image bytes directly.

Use one private bucket:

```txt
menu-media
```

Recommended paths:

```txt
users/{user_id}/captures/{capture_id}/original.jpg
users/{user_id}/captures/{capture_id}/thumb.jpg
users/{user_id}/dishes/{dish_id}/sources/{image_id}.jpg
users/{user_id}/dishes/{dish_id}/generated/{image_id}.jpg
```

The app should treat media references as opaque strings returned by Edge
Functions. Internally, a media reference maps to a `dish_images` row, and that
row points to `(storage_bucket, storage_path)`.

### Photo Upload Flow

1. Flutter creates a local capture with a client-generated `capture_id` and a
   local file path.
2. Flutter calls `capture.preparePhotoUpload`.
3. The Edge Function returns a signed upload URL for a Storage object path. It
   does not create a Postgres capture row yet.
4. Flutter uploads bytes to the signed URL.
5. Flutter calls `capture.createPhoto`.
6. The Edge Function creates:
   - one `captures` row with status `classifying`
   - one `dish_images` row with kind `capture_photo`
   - one `sync_events` row
7. Classification later updates the capture and image rows.

If step 4 fails, the server has no capture row. The local Flutter sync queue
keeps retrying.

## Row Level Security

Enable RLS on all user-owned tables.

Policy shape:

```sql
alter table public.dishes enable row level security;

create policy "users own dishes"
on public.dishes
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
```

Repeat the same ownership policy for:

- `captures`
- `dish_images`
- `review_items`
- `planned_meals`
- `dish_notes`
- `dish_ingredients`
- `dish_steps`
- `sync_events`

Even though Flutter should not call tables directly, RLS is still required as a
defense-in-depth boundary. Storage access should also be private; Edge Functions
should issue signed upload URLs and signed read URLs rather than exposing public
bucket URLs.

## Edge Function API

These are the app-facing APIs. Names are written as logical routes; they can be
implemented as one `api` Edge Function with path routing, or as separate
functions.

All requests require Supabase auth. All responses are JSON.

Implementation can start as one `api` Edge Function with internal routing for
these app-facing operations. Split operations into separate Edge Functions later
only if deployment, permissions, runtime limits, or monitoring needs make that
worth the extra surface area. Do not add empty placeholder functions; add Edge
Function code when the first real app-facing API is implemented.

### `sync.bootstrap`

Used after login or on a new phone.

Request:

```json
{}
```

Response:

```json
{
  "cursor": 123,
  "dishes": [],
  "captures": [],
  "dishImages": [],
  "reviewItems": [],
  "plannedMeals": []
}
```

### `sync.pull`

Used by the sync worker to fetch server changes.

Request:

```json
{
  "afterCursor": 123,
  "limit": 200
}
```

Response:

```json
{
  "cursor": 130,
  "events": [
    {
      "id": 124,
      "entityType": "dish",
      "entityId": "dish-uuid",
      "operation": "upsert",
      "payload": {}
    }
  ]
}
```

### `sync.push`

Used for local edits that are not capture uploads, such as favorite toggles,
notes, recipe edits, image notes, and dish labels.

Request:

```json
{
  "clientMutationId": "mutation-uuid",
  "operations": [
    {
      "entityType": "dish",
      "entityId": "dish-uuid",
      "operation": "patch",
      "payload": {
        "title": "Miso Salmon Bowl",
        "labels": ["seafood", "weeknight"]
      }
    }
  ]
}
```

Response:

```json
{
  "accepted": true,
  "cursor": 131
}
```

There is no ID mapping for client-created rows because the client ID is the
server ID.

### `capture.preparePhotoUpload`

Returns a signed upload URL. This does not create a Postgres capture row.

Request:

```json
{
  "captureId": "client-capture-uuid",
  "contentType": "image/jpeg",
  "byteSize": 2441180
}
```

Response:

```json
{
  "captureId": "client-capture-uuid",
  "upload": {
    "url": "signed-upload-url",
    "method": "PUT",
    "headers": {
      "content-type": "image/jpeg"
    }
  }
}
```

### `capture.createPhoto`

Creates the server capture after the image bytes exist in Storage.

Request:

```json
{
  "captureId": "client-capture-uuid",
  "capturedAt": "2026-06-20T12:30:00Z",
  "contentType": "image/jpeg",
  "byteSize": 2441180,
  "width": 3024,
  "height": 4032,
  "sha256": "optional-hash"
}
```

Response:

```json
{
  "capture": {
    "id": "client-capture-uuid",
    "kind": "photo",
    "status": "classifying",
    "imageId": "image-uuid"
  },
  "image": {
    "id": "image-uuid",
    "kind": "capture_photo",
    "mediaRef": "opaque-media-ref"
  },
  "cursor": 132
}
```

### `capture.createIdea`

Creates an idea capture and starts classification.

Request:

```json
{
  "captureId": "client-capture-uuid",
  "ideaText": "kimchi fried rice",
  "capturedAt": "2026-06-20T12:30:00Z"
}
```

Response:

```json
{
  "capture": {
    "id": "client-capture-uuid",
    "kind": "idea",
    "status": "classifying"
  },
  "cursor": 133
}
```

### `capture.discard`

Discards a feed item without deleting its sync history.

Request:

```json
{
  "captureId": "capture-uuid"
}
```

Response:

```json
{
  "captureId": "capture-uuid",
  "status": "discarded",
  "cursor": 134
}
```

### `capture.get`

Allows the client to poll one capture after upload/classification.

Request:

```json
{
  "captureId": "capture-uuid"
}
```

Response:

```json
{
  "capture": {
    "id": "capture-uuid",
    "kind": "photo",
    "status": "needs_review",
    "imageId": "image-uuid",
    "appliedDishId": null
  },
  "image": {
    "id": "image-uuid",
    "kind": "capture_photo",
    "mediaRef": "opaque-media-ref"
  },
  "reviewItem": {
    "id": "review-uuid",
    "summary": "Possible pho capture.",
    "suggestedDishIds": ["dish-uuid"],
    "suggestedNewDish": {
      "title": "Beef Pho",
      "description": "AI draft from capture.",
      "labels": ["noodles", "soup"]
    }
  }
}
```

### `review.resolve`

Resolves an uncertain capture.

Request to attach to an existing dish:

```json
{
  "reviewItemId": "review-uuid",
  "resolution": "attach_to_existing",
  "dishId": "dish-uuid"
}
```

Request to create a new dish:

```json
{
  "reviewItemId": "review-uuid",
  "resolution": "create_new_dish",
  "dishDraft": {
    "id": "optional-client-dish-uuid",
    "title": "Beef Pho",
    "description": "AI draft from capture.",
    "labels": ["noodles", "soup"]
  }
}
```

Response:

```json
{
  "captureId": "capture-uuid",
  "dishId": "dish-uuid",
  "sourceImageId": "image-uuid",
  "status": "applied",
  "cursor": 135
}
```

### `dish.update`

Updates durable dish fields and details.

Request:

```json
{
  "clientMutationId": "mutation-uuid",
  "dishId": "dish-uuid",
  "patch": {
    "title": "Miso Salmon Bowl",
    "description": "Weeknight salmon with rice and avocado.",
    "isFavorite": true,
    "coverImageId": "image-uuid",
    "labels": ["seafood", "weeknight"],
    "ingredients": ["salmon", "miso", "rice"],
    "steps": ["Bake salmon.", "Serve over rice."],
    "notes": ["Use less miso next time."]
  }
}
```

Response:

```json
{
  "dish": {},
  "cursor": 136
}
```

### `cover.generate`

Creates an AI-generated image as a first-class `dish_images` row.

Request:

```json
{
  "dishId": "dish-uuid",
  "sourceImageIds": ["source-image-uuid"],
  "prompt": "Make this look like a warm menu cover image."
}
```

Response:

```json
{
  "image": {
    "id": "generated-image-uuid",
    "kind": "ai_generated",
    "dishId": "dish-uuid",
    "mediaRef": "opaque-media-ref"
  },
  "cursor": 137
}
```

### `plan.replaceWeek`

Replaces a whole week of planned meals. This is intentionally simpler than
patch-based plan sync. The client sends the final local state for the week, and
the server makes that week match.

Request:

```json
{
  "clientMutationId": "mutation-uuid",
  "weekStart": "2026-06-15",
  "plannedMeals": [
    {
      "id": "planned-meal-uuid",
      "dishId": "dish-uuid",
      "dayKey": "2026-06-20",
      "labels": ["dinner"],
      "position": 0
    }
  ]
}
```

Response:

```json
{
  "weekStart": "2026-06-15",
  "plannedMeals": [],
  "cursor": 138
}
```

## Internal Postgres RPCs

Edge Functions should call SQL RPCs for multi-table changes so the write is
atomic and sync events are emitted consistently.

### `api_create_photo_capture`

Creates a capture and a `dish_images` row after Storage upload succeeds.

Inputs:

- `p_user_id uuid`
- `p_capture_id uuid`
- `p_storage_path text`
- `p_content_type text`
- `p_byte_size bigint`
- `p_width integer`
- `p_height integer`
- `p_sha256 text`
- `p_captured_at timestamptz`

Returns:

- `capture_id uuid`
- `image_id uuid`
- `sync_cursor bigint`

### `api_create_idea_capture`

Creates an idea capture and queues classification.

Inputs:

- `p_user_id uuid`
- `p_capture_id uuid`
- `p_idea_text text`
- `p_captured_at timestamptz`

Returns:

- `capture_id uuid`
- `sync_cursor bigint`

### `api_apply_capture_to_dish`

Attaches a capture to an existing dish and promotes its image to a source photo.

Inputs:

- `p_user_id uuid`
- `p_capture_id uuid`
- `p_dish_id uuid`
- `p_confidence_label text`
- `p_note text`
- `p_labels text[]`

Returns:

- `capture_id uuid`
- `dish_id uuid`
- `source_image_id uuid`
- `sync_cursor bigint`

### `api_create_dish_from_capture`

Creates a server dish from a capture or idea. If the capture has an image, the
image becomes a source photo for the new dish.

Inputs:

- `p_user_id uuid`
- `p_capture_id uuid`
- `p_dish_id uuid`
- `p_title text`
- `p_description text`
- `p_labels text[]`
- `p_confidence_label text`

Returns:

- `capture_id uuid`
- `dish_id uuid`
- `source_image_id uuid`
- `sync_cursor bigint`

### `api_create_generated_image`

Creates an AI-generated image row and records the Storage object metadata.

Inputs:

- `p_user_id uuid`
- `p_dish_id uuid`
- `p_storage_path text`
- `p_content_type text`
- `p_byte_size bigint`
- `p_width integer`
- `p_height integer`
- `p_source_image_ids uuid[]`
- `p_generation_prompt text`
- `p_generation_model text`

Returns:

- `image_id uuid`
- `sync_cursor bigint`

### `api_create_review_item`

Creates a review item and moves the capture to `needs_review`.

Inputs:

- `p_user_id uuid`
- `p_capture_id uuid`
- `p_summary text`
- `p_suggested_dish_ids uuid[]`
- `p_suggested_new_dish jsonb`
- `p_confidence_label text`

Returns:

- `review_item_id uuid`
- `capture_id uuid`
- `sync_cursor bigint`

### `api_resolve_review_item`

Resolves review by attaching to an existing dish or creating a new dish.

Inputs:

- `p_user_id uuid`
- `p_review_item_id uuid`
- `p_resolution text`
- `p_dish_id uuid`
- `p_dish_draft jsonb`

Returns:

- `review_item_id uuid`
- `capture_id uuid`
- `dish_id uuid`
- `source_image_id uuid`
- `sync_cursor bigint`

### `api_upsert_dish_patch`

Applies user edits to a dish and detail rows.

Inputs:

- `p_user_id uuid`
- `p_client_mutation_id text`
- `p_dish_id uuid`
- `p_patch jsonb`

Returns:

- `dish_id uuid`
- `sync_cursor bigint`

### `api_replace_week_plan`

Replaces all planned meals in a single week.

Inputs:

- `p_user_id uuid`
- `p_client_mutation_id text`
- `p_week_start date`
- `p_planned_meals jsonb`

Returns:

- `planned_meal_ids uuid[]`
- `sync_cursor bigint`

### `api_pull_snapshot`

Returns the full current server state for account restore.

Inputs:

- `p_user_id uuid`

Returns:

- `cursor bigint`
- `snapshot jsonb`

### `api_pull_events`

Returns ordered sync events after a cursor.

Inputs:

- `p_user_id uuid`
- `p_after_cursor bigint`
- `p_limit integer`

Returns:

- `cursor bigint`
- `events jsonb`

## Capture Classification Outcomes

The classifier should produce one of four outcomes:

1. Attach to an existing dish.
2. Suggest existing dishes and create a review item.
3. Suggest a new dish draft and create a review item.
4. Confidently create an AI draft dish.

The server should persist the outcome before responding. The client can learn
about it through `capture.get` polling or `sync.pull`. We do not need WebSockets
for MVP.

## MVP Implementation Order

1. Create Supabase project, private Storage bucket, tables, enums, RLS, and RPC
   migrations.
2. Implement `capture.preparePhotoUpload`, `capture.createPhoto`,
   `capture.createIdea`, `capture.get`, and `capture.discard`.
3. Implement fake classification inside an Edge Function matching the current
   Flutter fake API behavior.
4. Implement `sync.bootstrap` so phone replacement works.
5. Implement `sync.pull` and `sync.push` for ongoing backup.
6. Implement review resolution.
7. Implement `cover.generate` with generated images as first-class rows.
