# Flutter App Design for MyMenu

## Purpose

This document is the current Flutter architecture reference for MyMenu. It
implements the product direction in [product-vision.md](product-vision.md) and
the server boundary in [supabase-backend-design.md](supabase-backend-design.md).

MyMenu is a device-local personal cooking memory system:

- Drift/SQLite and the app file store own the personal menu
- every menu read and write is local
- server AI is optional enrichment, not remote application state
- a processing outbox coordinates temporary server work
- account portability never implies menu portability

## Core Architecture Rule

The device is the only menu authority.

```txt
Flutter UI
  -> Riverpod state
  -> local repositories
  -> Drift + app-owned files

Optional enrichment:

local processing outbox
  -> typed processing API
  -> enrichment proposal
  -> client validation and local adoption
```

The UI never waits for a cloud read before showing dishes, notes, plans,
captures, reviews, or photos. A server response cannot directly mutate those
objects.

## App Layers

### UI and Feature Layer

Contains screens, widgets, routes, dialogs, and feature controllers.

Responsibilities:

- render local state
- collect user intent
- display processing progress, failures, and review items
- distinguish local safety from temporary server availability

It must not call Supabase, issue Storage requests, or apply network DTOs
directly to widgets.

### Riverpod Layer

Riverpod provides dependency injection, screen state, async command state, and
derived views. Providers watch local repositories and local database streams.

Network connectivity is only a hint that processing work may resume. It is not
a source of truth for whether a request succeeded.

### Local Repository Layer

Repositories own cooking-domain persistence and invariants.

Examples:

- `DishRepository`
- `PlanRepository`
- `CaptureRepository`
- `ReviewRepository`
- `MediaRepository`

These repositories depend on Drift and the local file store. They do not
hydrate from or persist to Supabase.

Local actions such as editing a note, planning a meal, correcting a capture,
or deleting a dish complete entirely on the device.

### Processing Layer

Server assistance is isolated behind processing-specific components:

- `ProcessingOutboxRepository`
- `ProcessingApiClient`
- operation-specific contract mappers and validators
- a retry/foreground polling coordinator

This layer may read a snapshot of local data to build a request. It cannot write
cooking-domain tables except through an explicit, validated adoption
transaction owned by the relevant local repository.

### Identity and Entitlement Layer

Supabase Auth is separate from the cooking domain.

- the app silently creates a guest identity for AI quota
- optional sign-in restores paid access and allowance
- signing in or out never replaces, merges, uploads, or deletes the local menu
- deleting an account returns the installation to guest service
- erasing the menu is a separate local-only action

## Recommended Package Structure

```txt
lib/
  app/
    app.dart
    bootstrap.dart
    router.dart
  core/
    database/
    files/
    network/
    logging/
    privacy/
    utils/
  domain/
    dishes/
    planning/
    capture/
    review/
    processing/
    account/
  features/
    plan/
    menu/
    dish_detail/
    capture/
    improve_cover/
    review/
    settings/
  shared/
    widgets/
    theme/
```

The existing `domain/sync/` folder is a migration source, not the target name.
Move reusable local repository behavior to the relevant domain folder and move
temporary remote work to `domain/processing/`. Do not rename the entire folder
mechanically; separate cooking logic from replication logic first.

Layering rules:

- `features/` may depend on `domain/`, `core/`, and `shared/`
- cooking-domain repositories may depend on Drift and file abstractions
- `domain/processing/` may depend on the processing API contract
- `core/` must not depend on feature code
- no cooking-domain type should depend on a Supabase row type

## Local Persistence

Use Drift over SQLite for structured state and app-owned directories for media.

### Local Domain Tables

The target local model includes:

- `dishes`
- `dish_notes`
- `ingredients` or an intentionally embedded ingredient representation
- `recipe_steps` or an intentionally embedded step representation
- `source_photos`
- `planned_meals`
- `capture_batches`
- `capture_items`
- `capture_corrections` when needed for undo/history
- `review_items`
- `processing_outbox`

Cooking-domain IDs remain client-generated UUIDs. They are useful as opaque
references inside one processing request but are never remote canonical IDs.

### Columns to Remove or Reinterpret

Remove fields that exist only for cloud replication:

- sync cursors and server sequence numbers
- `remote_id`
- `sync_status`
- server-hydration flags
- replication tombstones
- permanent remote media references

`CaptureItems.remoteMediaRef` should not represent a permanent source. If a
temporary upload reference is useful during processing, keep it inside the
processing outbox/asset state and clear it on acknowledgement or expiry.

`deleted_at` is not required for synchronization. Retain a local deletion or
undo model only when the UX needs it, with a defined local expiry.

### Local Files

Store original sources, thumbnails, accepted generated covers, and other menu
media in app-owned local paths. Database rows reference local file IDs or paths,
not signed URLs.

File lifecycle must be transactional in effect:

- stage a captured/downloaded file
- verify it is readable and complete
- commit the database reference
- clean abandoned staging files
- delete unreferenced media after local domain deletion/undo rules permit it

Exclude the database and menu media from automatic iCloud and Android cloud
backup. Use platform sandboxing, device encryption, and strong file protection;
custom application-level encryption is not part of MVP.

## Local Data Flows

### Read Path

1. A widget watches a Riverpod provider.
2. The provider watches a local repository.
3. The repository streams Drift rows and local file references.
4. The UI updates without network access.

### Ordinary Write Path

1. UI returns a validated user intent.
2. The local repository applies one Drift/file transaction.
3. Local providers react.
4. No network operation is created.

Examples include note edits, recipe changes, planning, favorites, capture
corrections, and dish deletion.

### Capture Path

1. Copy/import the original photo into the app file store.
2. Persist the capture batch/items and original local capture date.
3. If AI consent is enabled, create a local processing-outbox entry in the same
   database transaction.
4. Close the capture UI as soon as the local save succeeds.
5. If offline, show that the capture is safe locally and organization is
   waiting.
6. When connectivity returns, the processing coordinator resumes the outbox.

The local outbox may wait indefinitely before a server job is created. The
server's 24-hour retention begins only after server job creation.

### Processing Submission

For capture grouping, the client builds:

- the new capture inputs and original local dates
- every existing dish's text context: title, description, ingredients, recipe
  steps, and notes
- no existing cover or source photos

For Improve Cover, it includes only the photos explicitly selected for that
operation.

The coordinator:

1. ensures a valid guest/account session
2. creates the typed server job with a random idempotency key
3. uploads assets to signed targets
4. submits the temporary text/asset manifest
5. records the server job ID and expiry locally
6. polls on foreground/network recovery until terminal state

Retries reuse the same idempotency key. Losing the process between any two
steps must not create duplicate charges or proposals.

### Result Download and Acknowledgement

1. Validate the response envelope and operation schema.
2. Download output assets into a staging directory.
3. Verify file type/hash when supplied.
4. Persist the enrichment proposal and staged local assets in the outbox.
5. Acknowledge the server job so remote payloads and assets can be deleted.
6. Apply or review the proposal entirely from local state.

Acknowledgement does not mean adoption. It means the client has durably
received everything needed and no longer needs a server copy.

### Proposal Adoption

Adoption is an idempotent local transaction keyed by the processing job/proposal
ID.

- high-confidence valid matches may automatically attach sources to an existing
  dish
- high-confidence new-dish proposals may create the local dish automatically
- ambiguous results create local review items
- not-a-dish results remain local capture outcomes
- generated images become local covers only after the operation's acceptance
  policy is satisfied
- every automatic grouping adoption remains locally undoable

If adoption is replayed after a crash, it must detect that the proposal was
already applied rather than create duplicate dishes or cooking occasions.

## Processing Outbox

The outbox replaces the generic sync queue. Suggested fields:

- `id`
- `operation_type`
- `subject_id`
- `status`
- `idempotency_key`
- `input_schema_version`
- `result_schema_version`
- `local_input_manifest`
- `server_job_id`
- `server_expires_at`
- `upload_state`
- `result_payload`
- `local_output_manifest`
- `attempt_count`
- `next_retry_at`
- `failure_code`
- `adoption_state`
- `created_at`
- `updated_at`

Suggested states:

```txt
local_pending
uploading
submitted
processing
downloading
ready_to_adopt
needs_review
adopted
dismissed
failed
expired
canceled
```

State transitions are local facts about delivery and adoption, not remote menu
sync status.

## Consent and Privacy UX

Before the first server-assisted AI operation, show one consent screen that:

- explains which new inputs are uploaded
- explains that capture matching sends existing dish text, including notes and
  recipes
- names the AI provider
- states actual MyMenu and provider retention
- explains persistent account, entitlement, and content-free quota records
- makes clear that declining keeps manual/local features available

Store the consent choice and notice version locally. Include the notice version
in job requests so the server can reject obsolete contracts without learning
menu state.

Settings must allow the person to disable future AI submission. Disabling it
does not erase the menu. Pending local jobs should be cancelable before upload;
active server jobs should be canceled and cleaned up when possible.

## Offline and Failure Behavior

- Local reads and ordinary writes always work without network access.
- Captures are considered saved only after local file/database persistence.
- A connectivity signal triggers a retry opportunity but never marks work
  successful.
- Server failures leave the local input untouched.
- Expired server results become retryable local jobs; no menu state is lost.
- Auth expiration silently renews or creates a guest session without touching
  the menu.
- Account sign-out changes entitlement/service access only.
- Quota exhaustion leaves the proposal request pending or failed with a clear
  local action; it never rolls back the capture.

## Networking and Contracts

Use JSON over HTTPS with versioned, operation-specific schemas. OpenAPI remains
a suitable source of truth if code generation materially reduces drift.

Keep separate types for:

- local domain entities
- local processing-outbox rows
- app-facing processing DTOs
- internal provider contracts

Do not map server DTOs onto Drift cooking rows automatically. Adoption code is
the explicit translation boundary.

The client must not:

- select from Supabase application tables
- call Postgres RPCs directly
- hold AI-provider keys
- treat signed Storage URLs as permanent media references
- log request bodies, result bodies, filenames, or signed URLs

## Recommended Flutter Stack

Keep:

- `flutter_riverpod`
- `go_router`
- `drift` and `drift_flutter`
- `freezed`/`json_serializable` where generated immutable DTOs help
- `image_picker` and app-owned file management
- `supabase_flutter` for Auth and Edge Function access
- `connectivity_plus` only as a retry hint

Use a background-work plugin only after validating real iOS and Android needs.
Foreground resume plus durable outbox state is the correctness mechanism;
background execution is an optimization.

## Observability

Routine logs may contain operation type, local/server job ID, state transition,
timing, status/error code, schema version, model ID, and token counts. They must
not contain menu text, prompts, local media paths, filenames, signed URLs,
provider bodies, or proposal content.

An opt-in diagnostic bundle must be generated separately, shown to the person,
and submitted only after explicit confirmation.

No product analytics SDK is included in MVP.

## Testing Strategy

Local repository tests:

- domain writes never enqueue network mutations
- capture file and database persistence behave atomically
- deletion cleans local media without server calls
- proposal adoption is transactional and idempotent
- ambiguous proposals create local review items
- automatic adoption supports undo

Processing tests:

- offline work survives restart
- retries reuse one idempotency key
- upload/submission/download resume from every intermediate state
- acknowledgement occurs only after durable local receipt
- expired remote jobs preserve local inputs and can retry
- existing photos are excluded from matching payloads
- menu text is included only after consent

Identity/privacy tests:

- sign-in/sign-out/account deletion never alters local menu rows
- disabling consent prevents new uploads
- routine logs redact fixture content and URLs
- platform backup exclusions cover database and app media

Structural checks continue to include `dart analyze` and
`dart run tool/structural_lint.dart` from `apps/mobile_flutter/`.

## Delivery Direction

The concrete transition from the current sync-heavy implementation is defined
in [local-first-transition-plan.md](local-first-transition-plan.md). The key
rule is to establish local authority and the processing outbox before deleting
legacy server behavior, even though the server data reset itself is allowed to
be destructive.

## Final Recommendation

Build MyMenu as a complete local application whose only remote dependency is a
small, optional processing and service-access API. Drift and the local file
store contain the product; Supabase supplies temporary computation, identity,
entitlement, and quota—not a second menu.
