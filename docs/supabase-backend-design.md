# Supabase Service Backend Design

## Status and Purpose

This document is the target backend architecture for MyMenu. It supersedes the
earlier design in which Supabase stored a durable copy of dishes, photos,
captures, notes, plans, and sync events.

MyMenu is a device-local product with optional server assistance:

- the device owns the personal menu and is the only menu authority
- Supabase owns service identity, entitlement, and content-free AI usage
- processing inputs and results exist on the server only temporarily
- the server returns enrichment proposals and never mutates menu state

The decisions behind this boundary are recorded in
[the architecture decision records](adr/).

## Boundary Summary

| Data | Authority | Server retention |
| --- | --- | --- |
| Dishes, recipes, notes, plans, captures, reviews | Device | Never stored durably |
| Original photos, covers, generated images | Device | Only explicit job inputs/outputs, then deleted |
| Menu context used for matching | Device | Job lifetime only |
| Guest or signed-in identity | Supabase Auth | Guest expires after inactivity; account persists |
| Entitlement and quota balance | Server | Account/service lifetime |
| Content-free AI usage record | Server | Detailed for 90 days, then billing totals only |
| Processing job and assets | Server | Until acknowledgement or 24 hours maximum |
| Routine operational logs | Server | Content-free, 30 days maximum |

MyMenu does not provide cloud menu backup, multi-device menu sync, or remote
menu recovery. A signed-in account can restore paid access and remaining AI
allowance on another device, but cannot restore the menu.

## Target Architecture

```txt
Flutter local database + file store
        |
        | typed processing request
        v
Supabase Edge processing API
        |
        +--> Auth / entitlement / quota check
        +--> expiring Postgres job metadata
        +--> expiring Storage inputs
        |
        v
Internal AI worker --> approved AI provider
        |
        v
Expiring proposal / generated output
        |
        v
Flutter downloads, validates, adopts locally, acknowledges
        |
        v
Server deletes job content and assets
```

The app never reads or writes application tables directly. It uses Supabase
Auth for identity and a small Edge Function API for processing and service
status. Direct Storage access is limited to short-lived signed upload and
download URLs issued for one processing job.

## Identity and Service Access

### Guest Installation

The app signs in anonymously without requiring user-visible registration. The
anonymous Auth user identifies a guest installation for:

- ownership of active processing jobs
- free AI allowance
- idempotency and request authorization

Guest quota is best-effort. Abuse prevention, device fingerprinting, and
platform attestation are explicitly deferred. An inactive guest identity is
deleted after 90 days without server processing once it owns no active job.
Opening the app later creates a new anonymous identity without affecting its
local menu.

### MyMenu Account

A person may later link the guest identity to a sign-in method. A MyMenu
account owns:

- paid entitlement
- current AI allowance
- content-free usage records and billing totals

It does not own menu content. Signing into another device restores service
access only.

Deleting a MyMenu account removes its service identity, entitlement, active
jobs and assets, and deletable usage records. It does not erase the local menu;
that is a separate device action.

## Target Server Schema

The exact SQL can evolve, but the schema must preserve the data boundary below.

### `service_entitlements`

Durable, content-free service access for a Supabase Auth identity.

Suggested fields:

- `owner_id`
- `plan_key`
- `status`
- `allowance_period_start`
- `allowance_period_end`
- `allowance_units`
- `external_provider`
- `external_entitlement_ref`
- `created_at`
- `updated_at`

This table must not contain menu preferences, dish statistics, or other profile
data. A separate display profile is unnecessary until a product feature needs
one.

### `ai_usage_records`

Durable, content-free evidence used for quota, billing, and disputes.

Suggested fields:

- `id`
- `owner_id`
- `job_id`
- `operation_type`
- `units_charged`
- `outcome_code`
- `idempotency_key`
- `provider_key`
- `model_key`
- `occurred_at`
- `expires_at`

The idempotency key must be random and opaque. Usage rows must not contain
prompts, local entity IDs, filenames, Storage paths exposed to users, menu
text, image-derived labels, or result content.

Detailed rows expire after 90 days. Signed-in accounts may retain only
billing-period totals afterward. Guest usage is deleted when the inactive
guest identity expires.

### `processing_jobs`

Ephemeral control state for asynchronous server assistance.

Suggested fields:

- `id`
- `owner_id`
- `operation_type`
- `status`
- `idempotency_key`
- `input_schema_version`
- `result_schema_version`
- `privacy_notice_version`
- `input_payload`
- `result_payload`
- `attempt_count`
- `lease_token`
- `lease_expires_at`
- `provider_request_id`
- `failure_code`
- `created_at`
- `submitted_at`
- `completed_at`
- `expires_at`

`input_payload` may temporarily contain new-capture metadata, idea text, and the
textual menu context needed for matching. `result_payload` contains an
enrichment proposal, never authoritative menu rows.

All rows expire no later than 24 hours after creation. A successful client
acknowledgement deletes the processing job, its payloads, and associated assets
earlier; only the separate content-free usage record remains. If short-lived
content and control metadata are later separated into two tables, the content
table must keep the same or shorter lifetime.

### `processing_assets`

Ephemeral metadata for job-owned Storage objects.

Suggested fields:

- `id`
- `job_id`
- `direction` (`input` or `output`)
- `storage_bucket`
- `storage_path`
- `content_type`
- `byte_size`
- `sha256`
- `created_at`
- `expires_at`

Rows and objects are deleted together. No asset becomes a permanent cover or
source on the server; the client downloads accepted outputs into its local file
store.

### What Is Removed

The target schema has no server tables for:

- profiles containing product data
- dishes
- dish notes, ingredients, or recipe steps
- captures or capture batches
- dish images or cooking occasions
- review items
- planned meals
- capture grouping corrections
- sync events, cursors, snapshots, or tombstones

## Processing API

Use a single versioned processing-job lifecycle with typed operation payloads.
Do not expose a generic unvalidated JSON task runner.

### Create Job

`POST /processing-jobs`

Responsibilities:

- authenticate the guest installation or MyMenu account
- validate consent/privacy-notice version
- validate the operation-specific envelope
- enforce input count and byte limits
- atomically enforce/reserve quota and create an idempotent job
- return the job ID and any signed input upload targets

Initial operation types:

- `capture_grouping`
- `improve_cover`

Future recipe enrichment can add a typed operation without adding menu CRUD.

### Submit Job

`POST /processing-jobs/{jobId}/submit`

Responsibilities:

- verify every declared input upload
- accept the temporary text payload and asset manifest
- mark the job ready
- enqueue or invoke the worker

The text payload for capture matching may include all local dish titles,
descriptions, ingredients, recipe steps, and notes. Existing dish photos are
excluded. An image operation may include only photos explicitly selected by
the person.

### Read Job

`GET /processing-jobs/{jobId}`

Returns only the caller's job status and, when complete:

- the typed enrichment proposal
- short-lived signed URLs for generated assets
- normalized error information when failed
- expiry time

The client polls this route on foreground/network recovery. Push notification
delivery is not required for the first implementation.

### Acknowledge Job

`POST /processing-jobs/{jobId}/acknowledge`

Called after the client has durably downloaded the result into its local
database/file store. It deletes the job row, payloads, and Storage objects
immediately while retaining only the separately approved usage record.
Local review can continue after acknowledgement because the proposal is already
stored in the device's processing outbox.

### Cancel Job

`POST /processing-jobs/{jobId}/cancel`

Cancels work when possible and deletes unneeded inputs. Provider work already
performed may still count toward usage; detailed charging/refund policy belongs
with the future paid-plan design.

### Account and Service Status

The app can use Supabase Auth directly for sign-in/session management. A small
service endpoint may return entitlement and remaining allowance. No account
endpoint may return or accept menu content.

## Internal SQL and Worker Boundary

Postgres functions are justified only for transactions that must remain atomic
or for protected worker leasing. The expected set is small:

- create an idempotent job while reserving/checking allowance
- claim or renew a job lease
- complete/fail a job and record content-free usage
- expire jobs/assets and inactive guest identities

These are internal service operations, not app-facing menu RPCs. The Edge API
validates typed contracts and calls them with the authenticated owner ID.

The worker must:

- claim work with an expiring lease
- sign or load only that job's assets
- send only operation-approved fields to the AI provider
- validate provider output against a versioned schema
- store an enrichment proposal rather than applying it
- use opaque error codes and sanitized logs
- finish idempotently so retries do not double-charge or duplicate results

## Storage

Use a private bucket dedicated to processing rather than a durable
`menu-media` library.

Suggested paths:

```txt
jobs/{owner_id}/{job_id}/inputs/{asset_id}
jobs/{owner_id}/{job_id}/outputs/{asset_id}
```

Required controls:

- upload/download through short-lived signed URLs
- owner and job checked before signing
- file type, count, and size validation
- object expiry no later than the job's 24-hour deadline
- immediate deletion on acknowledgement or cancellation
- scheduled cleanup as a backstop for failed application cleanup
- no public objects

The provider's own file-upload API, when required for formats such as HEIC,
must follow the approved provider-retention policy.

## Privacy and Observability

Before the first AI operation, the client obtains informed consent describing:

- what new input is uploaded
- that capture matching includes existing menu text
- which AI provider receives it
- actual MyMenu and provider retention
- which account and quota metadata persists

Routine logs may include job ID, operation type, timing, status/error code,
model ID, and token usage. They must not include payloads, prompts, signed URLs,
filenames, provider response bodies, menu-derived identifiers, or stack traces
that embed those values. Routine logs expire after 30 days.

MyMenu has no separate product analytics pipeline in MVP. A user-reviewed,
explicitly submitted diagnostic bundle is the only content-bearing support
exception.

## Provider Requirements

An AI provider is eligible only when the selected product/configuration:

- does not train on customer inputs
- documents its retention behavior
- supports the shortest practical retention for inputs and outputs
- permits MyMenu to state the real downstream retention accurately

Deleting MyMenu's copy does not justify claiming the provider's copy is also
deleted. Provider and model changes require validating this privacy contract in
addition to quality and cost.

## Security

- Require a valid Supabase JWT for every app-facing processing route.
- Treat both anonymous and linked Auth users as authenticated service owners.
- Never trust an owner ID, quota, cost, result, or Storage path supplied by the
  client without server-side derivation/validation.
- Keep service-role and AI-provider keys only in server-managed secrets.
- Limit internal worker invocation with a dedicated worker secret or equivalent
  service identity; never reuse the service-role key as a worker token.
- Apply RLS to service tables even when Edge Functions normally use a service
  client.
- Use random job IDs and idempotency keys; do not expose sequential usage IDs.
- Exclude request bodies from gateway and function logging.

## Cleanup and Retention Jobs

Scheduled cleanup is a privacy control, not optional housekeeping. It must:

1. find expired jobs
2. delete every related Storage object
3. clear or delete input/result payloads
4. remove processing-asset rows
5. remove the job control row
6. delete detailed usage after 90 days or aggregate eligible account totals
7. delete inactive guest identities after 90 days when no active job remains

Cleanup must be idempotent and observable through content-free counts and error
codes. Tests should prove that database and Storage failures are retried and do
not silently extend retention.

## Testing Strategy

Database tests should cover:

- owner isolation and RLS
- idempotent job creation
- atomic quota reservation and usage recording
- lease claim, expiry, retry, and completion
- acknowledgement and time-based deletion
- inactive guest expiry
- absence of menu-domain tables after the reset

Edge Function tests should cover:

- authentication and ownership
- consent/privacy-notice version
- typed payload validation and size limits
- signed upload/download authorization
- job lifecycle and expiry responses
- sanitized error responses
- worker authentication

Contract/evaluation tests should cover:

- capture matching against supplied menu text
- no requirement for existing dish photos
- complete capture partitioning and not-a-dish rejection
- foreign/duplicate local IDs rejected in provider output
- high/low confidence represented for client adoption policy
- prompt and result schema version compatibility

Privacy tests should fail when logs or durable usage rows contain known fixture
content, signed URLs, filenames, or local menu IDs.

## Operations

Keep the Supabase project under `backend/supabase/` and run CLI commands from
`backend/`. Production secrets and environment-specific state remain outside
the repository.

The pre-launch migration is intentionally destructive. Before applying it to
any environment, verify that no real user relies on its cloud menu data and
take a recoverable administrative snapshot. The transition sequence is defined
in [local-first-transition-plan.md](local-first-transition-plan.md).

## Explicit Non-Goals

- cloud menu backup or restore
- multi-device menu synchronization
- public menu hosting
- direct client table access
- server menu CRUD
- durable capture, dish, note, plan, or review history
- product analytics in MVP
- device fingerprinting or advanced quota-abuse controls
- custom local database/media encryption in MVP
- export/import in this backend design
