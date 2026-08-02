# Local-First Transition Plan

## Purpose

This plan moves the current cloud-replica implementation to the device-local
architecture defined by:

- [Flutter App Design](flutter-app-design.md)
- [Supabase Service Backend Design](supabase-backend-design.md)
- [MyMenu Context](../CONTEXT.md)
- [Architecture Decision Records](adr/)

The server reset is allowed to be destructive because the current cloud schema
is pre-launch. Code changes still need a coherent cutover: local cooking logic
must be separated from sync logic before shared files are deleted.

## Outcome

At completion:

- the mobile app remains complete and usable without a server
- all cooking-domain state and media live only on the device
- Supabase contains service identity, entitlement, content-free usage, and
  expiring processing jobs/assets
- the app has a processing outbox, not a sync engine
- the server has no menu CRUD, hydration, correction, or sync API
- all temporary content is acknowledged/deleted or expires within 24 hours

## Server Data Disposition

| Current object | Target disposition | Replacement |
| --- | --- | --- |
| `profiles` | Remove | Supabase Auth plus minimal service entitlement |
| `dishes` | Remove | Local Drift `dishes` |
| `dish_notes` | Remove | Local Drift `dish_notes` |
| `dish_ingredients` | Remove | Local ingredient representation |
| `dish_steps` | Remove | Local recipe-step representation |
| `captures` | Remove | Local capture tables/files |
| `capture_batches` | Remove | Local capture batches |
| `dish_images` | Remove | Local source/cover files and rows |
| `cooking_occasions` | Remove | Local cooking history |
| `review_items` | Remove | Local review items |
| `planned_meals` | Remove | Local planned meals |
| `capture_grouping_actions` | Remove | Local correction/undo state |
| `sync_events` | Remove | No replacement |
| `ai_jobs` | Replace | Ephemeral `processing_jobs` |
| durable `menu-media` bucket | Replace | Expiring processing bucket/assets |

New server objects:

- `service_entitlements`
- `ai_usage_records`
- `processing_jobs`
- `processing_assets`
- optional billing-period usage aggregates when paid plans are implemented

## Edge Function Disposition

| Current function | Target disposition |
| --- | --- |
| `get-dishes` | Delete |
| `get-captures` | Delete |
| `get-review-items` | Delete |
| `sync-pull` | Delete |
| `createDishNote` | Delete |
| `updateDishNote` | Delete |
| `deleteDishNote` | Delete |
| `updateDish` | Delete |
| `delete-dishes` | Delete |
| `discard` | Delete; discard locally |
| `delete-capture-batch` | Delete; delete locally |
| `prepare-photo-upload` | Fold into processing-job creation |
| `create-photo` | Delete; asset verification belongs to job submission |
| `finalize-capture-batch` | Replace with typed job submission |
| `process-ai-jobs` | Rewrite as the operation-neutral internal worker |

Target app-facing server surface:

- `processing-jobs` router/function for create, submit, read,
  acknowledge, and cancel
- minimal service-status/entitlement endpoint when needed
- Supabase Auth for anonymous and linked sessions

Target internal surface:

- worker invocation
- atomic job/quota creation
- lease claim/renewal
- completion/failure and usage recording
- scheduled content, usage, and guest-identity cleanup

## Postgres RPC Disposition

Delete all RPCs that create, update, hydrate, correct, plan, delete, or emit
events for menu entities. This includes the existing `api_*` capture, dish,
note, grouping, deletion, and pull-event functions and their historical
redefinitions.

Keep SQL functions only where database atomicity or protected worker leasing is
the reason for their existence. They must use service language such as job,
allowance, usage, and lease—not dish/menu mutation language.

## Flutter Data Disposition

| Current local object | Target disposition |
| --- | --- |
| `Dishes` | Keep local; remove remote assumptions |
| `DishNotes` | Keep local; remove sync tombstone if no local UX needs it |
| `SourcePhotos` | Keep; ensure references are local files |
| `CaptureItems` | Keep; remove permanent `remoteMediaRef` |
| `CaptureBatches` | Keep |
| `CaptureCorrections` | Keep only for local correction/undo |
| `PlannedMeals` | Keep |
| `ReviewItems` | Keep local |
| `SyncOperations` | Drop |
| `SyncMetadata` | Drop |
| `AiJobs` | Replace/migrate to `ProcessingOutbox` |

The Drift migration must preserve cooking-domain rows. Do not wipe a device's
local menu merely because the server is pre-launch. Before clearing temporary
remote references, ensure any media meant to survive has been copied into the
app file store and verified.

## Flutter Code Disposition

The current `lib/domain/sync/` directory mixes three concerns:

1. valid local cooking-domain repositories
2. processing/upload behavior that remains useful
3. replication, hydration, and remote deletion that must disappear

Refactor by responsibility:

- move dish/note/plan/capture persistence into their domain folders
- move capture file staging into local media/capture repositories
- move upload, polling, result download, and retry into `domain/processing/`
- delete sync cursor/event application and remote hydration
- delete remote menu deletion/correction calls
- replace `refreshFromServer()` with targeted processing-outbox resumption
- rename UI copy from “syncing/synced” to “processing,” “waiting for
  connection,” or “saved on this device”

Do not delete `domain/sync/` as a single first step; several current files own
local behavior that must be preserved and relocated.

## Contract Design

Define the typed processing contracts before rewriting either side.

Common envelope fields:

- job ID
- operation type
- idempotency key
- input/result schema versions
- privacy notice version
- status and expiry
- typed error code

`capture_grouping` input:

- capture IDs, kinds, order, original local dates, and idea text
- uploaded new-capture assets
- text for every existing local dish, including notes and recipes
- no existing dish photos

`capture_grouping` result:

- complete partition of submitted captures
- not-a-dish decisions
- proposed new dish drafts or existing local dish matches
- evidence, uncertainty, and confidence sufficient for client policy
- no server-applied IDs or mutations

`improve_cover` input:

- only explicitly selected source images
- optional text guidance and relevant dish text

`improve_cover` result:

- expiring generated asset manifest
- provider/model provenance needed for local display/support
- no permanent server image reference

## Phased Implementation

### Phase 0: Safety and Baseline

- Confirm again that no real user relies on cloud menu recovery.
- Take a recoverable administrative snapshot before destructive reset.
- Record the current mobile database version and fixture expectations.
- Freeze additions to legacy menu RPCs and sync events.
- Add tests that characterize local rows/media that must survive the refactor.

### Phase 1: Contracts and Local Authority

- Define typed processing request/result schemas.
- Add a local `processing_outbox` table and state machine.
- Introduce operation-specific proposal validators.
- Add idempotent local adoption transactions.
- Route high-confidence results to auto-adoption and ambiguous results to local
  review.
- Keep a fake/local processing gateway so UI work remains testable without
  Supabase.

At the end of this phase, ordinary domain writes must no longer enqueue generic
sync operations.

### Phase 2: Extract and Delete Client Sync

- Move valid local repositories out of `domain/sync/`.
- Remove `SyncOperations` and `SyncMetadata` after migrating pending local work
  into the processing outbox where applicable.
- Remove sync cursors, event application, remote hydration, and server menu
  deletion.
- Convert permanent remote media references to verified local files.
- Update all UI copy and states that imply cloud persistence.

### Phase 3: Build the Reduced Backend

- Create the reduced baseline service schema.
- Implement processing-job creation/submission/status/acknowledgement/cancel.
- Implement atomic allowance and content-free usage recording.
- Rewrite the worker around typed operation handlers and enrichment proposals.
- Create the private expiring processing bucket.
- Implement acknowledgement and scheduled cleanup.
- Implement 90-day usage and inactive-guest cleanup.
- Add sanitized structured logging with 30-day retention.

### Phase 4: Privacy and Identity UX

- Add one-time versioned AI consent.
- Enable guest processing without user-visible sign-in.
- Keep optional account/sign-in isolated from menu state.
- Add separate account deletion and local-menu erasure actions.
- Configure iOS and Android backup exclusions.
- Verify provider no-training and retention settings before live AI use.

### Phase 5: End-to-End Cutover

- Point the app processing gateway at the reduced API.
- Exercise offline upload, app termination, expiry, retry, download, local
  adoption, review, undo, and acknowledgement.
- Confirm no menu read/write issues a server call.
- Confirm signed-in service restoration on another device exposes no menu.
- Run privacy fixture tests against logs, usage rows, and expired Storage.

### Phase 6: Destructive Server Reset and Legacy Removal

- Stop legacy Edge Functions and scheduled workers.
- Reset the pre-launch Supabase database/storage to the reduced baseline.
- Delete legacy migrations, functions, policies, tests, and configuration.
- Remove the durable `menu-media` layout.
- Deploy only the processing/service API and internal worker.
- Verify the empty target schema against an allowlist of expected objects.

## Test Replacement Matrix

Remove tests whose asserted product behavior no longer exists:

- cloud dish/note CRUD
- sync event emission and pull
- server grouping correction/undo
- server dish/capture deletion plans
- dish/capture/review hydration
- permanent menu-media ownership

Replace them with tests for:

- local-only domain mutation
- processing-outbox restart/retry behavior
- typed job validation
- idempotent job creation and local adoption
- allowance/usage atomicity
- temporary Storage ownership and deletion
- acknowledgement and 24-hour expiry
- provider-output validation
- content-free usage/log enforcement
- guest expiry and account/menu separation
- platform backup exclusion

## Verification Gates

Backend:

- local Supabase reset succeeds from the reduced baseline
- pgTAP and Edge Function tests pass
- Deno format/check passes
- an expired/acknowledged fixture leaves no payload or Storage object
- an allowlist query proves no menu-domain table or RPC exists

Flutter:

- existing local-domain migration tests pass
- repository and processing tests pass
- `dart analyze` passes
- `dart run tool/structural_lint.dart` passes
- manual offline capture and processing recovery work on iOS and Android
- account sign-in/out/delete tests leave local menu bytes unchanged

Documentation/product:

- no active copy promises backup, sync, cloud safety, or cross-device menu access
- consent and privacy copy state actual provider retention
- settings distinguish account deletion from local-menu erasure
- mockups replace “syncing” language with local/processing language

## Risks and Controls

| Risk | Control |
| --- | --- |
| Local data accidentally wiped during refactor | Drift migration tests and media localization before column/table removal |
| Server result expires before download | Durable local input/outbox and retryable expired state |
| Duplicate dish/cost after retry | Opaque idempotency key plus idempotent local adoption transaction |
| Job content leaks through logs | Structured allowlisted fields and privacy fixture tests |
| Storage object survives DB deletion | Scheduled object cleanup and expiry reconciliation |
| Account code starts owning menu state | Separate repositories/types and account/menu invariance tests |
| “Temporary” provider data lasts longer | Provider contract/config verification and accurate disclosure |
| Generic job API becomes untyped | Operation discriminator with versioned schemas and strict validation |

## Deferred Work

- advanced free-quota abuse prevention
- paid-plan pricing, charging, refund, and store-integration rules
- encrypted export/import
- optional app-level locked-vault encryption
- public sharing or publishing
- push notifications for completed jobs
- product analytics

Each deferred feature must preserve the device-local ownership boundary or
record a new explicit decision before changing it.
