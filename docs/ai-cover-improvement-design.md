# AI Cover Improvement Design

## Purpose

MyMenu creates an aspirational Cover for a new Dish as part of the capture
experience, while preserving real Source photos as documentary cooking history.
People can later improve, compare, switch, or delete generated Covers without
changing Sources or Journal entries.

This design expands [issue #57](https://github.com/yiochen/my_menu/issues/57)
from manual Improve Cover plumbing into the complete automatic and manual Cover
lifecycle.

## Product Rules

- AI Cover generation is enabled by accepting the versioned AI consent.
- Automatic Cover generation is on by default after consent and can be disabled
  independently in Settings.
- A photo capture is organized first; Cover generation is a separate processing
  job started only after the grouping outcome is locally adopted or resolved.
- Add Idea creates a Dish and optional standalone Note immediately without AI
  grouping, then starts a separate Cover job when permitted.
- A newly eligible Dish receives at most one automatic Cover opportunity.
- Adding Sources to an established Dish never refreshes its Cover automatically.
- Manual Improve Cover remains available whenever Cover allowance permits.
- Generated Covers never appear in the Journal and never become Sources.
- Every valid delivered generated image is retained locally in Cover history
  until explicitly deleted.

## Domain Model

### Cover

The current visual selected for a Dish. It may reference a Source photo, a
generated image in Cover history, or nothing. When nothing is selected, the app
renders a non-media Cover placeholder.

### Source

A real photo from a cooking occasion. Sources remain documentary Journal content
even when one also serves as the Cover.

### Note

A standalone Dish memory. Notes are independent Journal items; Sources and
cooking occasions do not own notes or captions.

### Proposed Cover

The one valid generated image awaiting a manual accept-or-keep-current decision.
A Dish has at most one unresolved Proposed Cover.

### Cover history

The local collection of every valid generated image delivered for a Dish,
including automatic Covers, declined Proposed Covers, and candidates superseded
by Try another. Validation-rejected output is never retained.

### Grounding

All Cover jobs use the same input schema and server prompt template:

- **Source-grounded**: the Dish currently has Sources, so one to three selected
  Sources are included.
- **Context-grounded**: the Dish currently has no Sources, so the image list is
  empty and generation relies on title and Notes.

Grounding is provenance and validation metadata, not a user-visible generation
mode.

## Entry Flows

### Photo Capture

1. Save the capture and media locally.
2. If AI consent exists, enqueue capture grouping.
3. Adopt a confident grouping proposal locally or wait for Review resolution.
4. For every newly eligible Dish, select up to three suitable Sources from that
   capture and enqueue a separate Cover job.
5. Download and validate the result.
6. Automatically adopt a valid high-confidence result.
7. A Cover failure never blocks or rolls back organization.

The grouping and Cover operations use different typed processing jobs,
idempotency keys, failure states, and allowance pools. They may share local
adoption helpers but not one remote job.

### Add Idea

1. Atomically save a new local Dish and its optional standalone Note.
2. Do not call grouping, create Review, show the Idea in Photos or Unorganized,
   or consume Organization allowance.
3. If current AI consent permits automatic Covers, enqueue the Cover job.
4. If consent has not been decided, save first and show consent afterward.
5. Create no Cover outbox entry and upload no title or Note before acceptance.
6. Acceptance in that immediate flow may enqueue the just-created Dish.
   Postponement or decline leaves no deferred request and later consent does not
   backfill it.

## Automatic Eligibility

An automatic opportunity may be created for:

- a new photo-based Dish after grouping adoption;
- a new Dish saved through Add Idea; or
- a source-less legacy Dish when it receives its first Sources.

The opportunity is not created when AI consent is missing, Automatic AI covers
is disabled, or the Dish was already eligible before the setting was enabled.
There is no automatic backfill.

The opportunity is terminal when:

- a valid automatic Cover is adopted;
- the person undoes the automatic Cover;
- the person makes a newer local Cover choice;
- the person chooses manual customization instead;
- no initial Source is suitable;
- Cover allowance is unavailable;
- automatic Cover validation fails; or
- the preference is disabled while the work is pending.

A terminal outcome may leave a Source Cover or the Cover placeholder. Improve
Cover remains available later as an explicit, chargeable operation.

## Automatic Source Selection

- Select one to three Sources only from the triggering capture and resulting
  Dish assignment.
- Prefer sharp, unobstructed views where the prepared food dominates.
- Prefer complementary angles over near-duplicates.
- Never add older Dish Sources implicitly.
- Record the exact selected IDs in Cover provenance.
- If no initial Source is suitable, do not fall back to context-grounded
  generation while Sources exist; skip automatic generation terminally.

The grouping proposal may recommend the Source set, but the client validates
that each ID belongs to the triggering capture and adopted Dish before creating
the Cover job.

## Grouping Corrections

Before automatic adoption, a grouping correction supersedes Cover work based on
the old Source partition:

- cancel or discard stale work;
- restart the original new Dish using its corrected Source set;
- start a chain for every newly split-out Dish;
- do not refresh a Source moved into an established Dish; and
- do not rearm a Dish whose automatic Cover was already adopted or undone.

For example, splitting `{A, B, C}` into `{A, B}` and a new Dish `{C}` produces
two current automatic Cover chains. Superseded attempts are zero-charge.

## Unified Generation Contract

The versioned input contains:

```text
dishTitle: normalized string
sourceImages: 0..3 explicitly selected local media assets
notes: all current standalone Notes with stable ordering and timestamps
treatment:
  look: enum
  view: enum
  finish: enum
```

It excludes Dish description, structured ingredients, recipe steps, generated
Cover history, unselected or older Source images, and broader Menu context.

The title and Notes are untrusted quoted context, never prompt instructions.
They cannot override prompt policy, treatment constraints, or validation.
Generation snapshots title, Notes, selected Sources, and treatment at
submission. Later title or Note edits do not restart a job; using updated text
requires a new generation.

### Note Interpretation

- Sources anchor Dish identity when present.
- Appearance-relevant Notes may intentionally change visible food or
  presentation beyond the Sources, including ingredients, doneness, garnish,
  serving vessel, and plating.
- Nonvisual Notes are ignored.
- The newest appearance-relevant Note wins when Notes conflict.
- When recency is missing or the conflict remains ambiguous, apply neither
  direction and fall back to title and Sources.
- Notes cannot control photographic style, lighting, camera angle, background
  mood, or other production treatment.

## Cover Treatment

Improve Cover exposes bounded choices rather than a freeform prompt:

| Parameter | Values |
| --- | --- |
| Look | Natural polish; Bright & fresh; Warm & cozy; Dark & refined |
| View | Let MyMenu choose; Overhead; Angled; Close-up |
| Finish | Light touch; Menu-ready; Editorial |

The automatic default is **Natural polish / Let MyMenu choose / Menu-ready**.
The client sends versioned enum values; the server owns and versions the prompt
template. Image-production instructions smuggled through title or Notes are
ignored.

## Cover Validation

Every generated output must pass hard validation before it is presented or
adopted:

- provider safety checks;
- supported file type, dimensions, and integrity;
- a recognizable prepared Dish consistent with the input context;
- no text, logos, or people; and
- no prominent contradiction of title, Sources, or appearance-relevant Notes.

Source-grounded validation requires visible food identity to remain grounded in
selected Sources plus explicit appearance Notes. Context-grounded validation may
infer plausible visual details needed to render a source-less Dish but may not
contradict explicit title or Note context.

Automatic adoption additionally requires high confidence. An internal provider
or validation failure produces no Cover, consumes no user-facing Cover unit,
and does not regenerate automatically.

## Automatic Adoption and Races

- A valid automatic result becomes the current Cover without another review.
- The previous Cover selection is retained so Undo can restore it exactly.
- Adoption creates a persistent, non-blocking notice with Undo, Improve again,
  and acknowledgement actions. It never creates a Review item.
- Undo restores the previous selection, keeps the generated image in Cover
  history, and permanently consumes the automatic opportunity for that Dish.
- A newer local Cover choice made after the job began always wins. Discard the
  late automatic result at zero units and do not retain it in Cover history.
- Title and Note edits do not stale the job.
- Source reassignment before adoption does stale the job and follows the
  grouping-correction rules.
- Choosing Customize instead cancels or invalidates the automatic chain and
  enters manual Improve Cover. Automatic and manual jobs never run concurrently
  for one Dish.

After adoption, a generated Cover is an independent local asset. Moving or
deleting its former Sources does not invalidate it.

## Manual Improve Cover

### Selection

- If the Dish has Sources, require the person to select one to three Sources.
- MyMenu may preselect a recommended set, but the final selection is explicit.
- If the Dish has no Sources, use zero images without exposing another mode.
- Always include title, all standalone Notes, and selected treatment.
- Never offer generated Cover history as generation input.

### Background Completion

- Closing the sheet or app does not cancel generation.
- The processing outbox resumes upload, polling, download, and acknowledgement.
- A valid Proposed Cover is stored locally and the Dish shows a persistent
  Cover ready to review notice.
- Cancellation must be explicit.
- A pending Proposed Cover has no local time-based expiry.

### Proposal Lifecycle

- Deliver one Proposed Cover per generation, not a gallery.
- Present Use this cover, Try another, and Keep current.
- Improve Cover reopens an existing unresolved proposal.
- Try another keeps the old paid proposal until a new valid proposal arrives;
  then the old image moves to Cover history.
- If replacement generation fails, the previous proposal remains available.
- Keep current archives the valid image in Cover history.
- Accepting makes it current and leaves prior generated Covers in history.
- Before delivery, moving or deleting any selected Source invalidates the job;
  discard late output and charge zero units.
- After delivery, a Proposed Cover is independent local media and remains
  available even if former Sources move or are deleted.

## Cover History and Switching

- Retain every valid delivered generated image locally with no automatic TTL.
- Keep Cover history separate from Journal, Sources, and cooking occasions.
- Change cover shows generated history and a Choose from Sources action.
- Selecting a Source as Cover stores a reference; it remains in the Journal and
  is not copied into generated history.
- Switching among local Covers is offline and consumes no allowance.
- Historical and current generated Covers may be explicitly deleted.
- Deleting the current generated Cover clears the selection and shows the Cover
  placeholder; no replacement is required.
- Deleting a Source that currently serves as Cover follows the same placeholder
  rule.
- Deleting the Dish removes all of its generated Cover history.
- Cover history is never uploaded as a generation reference.

## Cover Provenance

Store locally with every valid generated image:

- automatic or manual origin;
- Source- or context-grounded provenance;
- selected Source IDs, when any;
- Cover treatment values and contract version;
- processing proposal ID;
- creation time; and
- proposal, acknowledgement, and Undo state.

Do not retain the rendered server prompt. Deleted Source image data is not
retained through provenance; opaque historical IDs may remain.

## Consent and Privacy

- One versioned AI consent covers both organization and Cover generation.
- Acceptance enables automatic Covers by default; there is no separate checkbox
  on the consent sheet.
- Consent explicitly discloses automatic adoption, upload of zero to three
  selected Sources, upload of every standalone Note, provider handling, actual
  retention, and durable content-free usage metadata.
- Settings can disable Automatic AI covers without disabling organization.
- Enabling the setting later is prospective and does not backfill Dishes.
- Disabling it cancels pending automatic chains, discards late output, and keeps
  already adopted Covers.
- Older consent that covered organization but not image generation cannot
  authorize Cover jobs until the new version is accepted.
- Withdrawing AI consent cancels server-assisted work but preserves delivered
  local Cover history and offline switching.
- No Cover outbox entry or upload exists before consent acceptance.
- Server inputs and outputs are acknowledged and deleted after durable local
  receipt; unacknowledged jobs expire under the processing-job retention policy.

## Allowance and Charging

Organization allowance and Cover allowance are independent. Exhausting Cover
allowance never blocks capture grouping.

- A successfully adopted automatic Cover consumes one Cover unit.
- A valid manual Proposed Cover consumes one unit when delivered, even if the
  person keeps the current Cover.
- Superseded automatic attempts, provider failures, validation rejection,
  cancellation before delivery, and stale discarded results consume zero
  user-facing units but retain content-free outcome records.
- Automatic generation may consume the final Cover unit; no hidden unit is
  reserved for manual work.
- Remaining Cover allowance is visible in Settings and Improve Cover, not added
  as a per-capture confirmation.
- Manual jobs take priority over automatic jobs that have not reached the
  provider. Already submitted automatic work keeps its reservation.

When a capture produces more eligible Dishes than available Cover allowance,
allocate in original capture order using each Dish's earliest Source position.
Continue until the available number of valid automatic Covers is adopted or no
eligible Dishes remain. A zero-charge failure passes capacity to the next Dish;
unserved Dishes then terminate with their Source Cover or placeholder.

## Note Model Change

- Remove `SourcePhoto.note` and the corresponding local/database/API fields.
- All Notes are standalone `DishNote` records.
- Add Idea's optional Note becomes the first standalone Note on its Dish.
- MyMenu has no production user data, so discard existing seeded/test
  Source-note values instead of migrating them.
- Update Journal rendering and fixtures so no Note depends on a Source or
  cooking occasion.

## Required States

| Situation | Result |
| --- | --- |
| Grouping uncertain | Wait for Review resolution before Cover work |
| Existing Dish receives another Source | Keep current Cover; no automatic job |
| Add Idea saved with consent | Create Dish immediately; enqueue Cover job |
| Add Idea saved before consent | Save locally; enqueue only on immediate acceptance |
| Automatic setting enabled later | No backfill |
| Initial Sources unsuitable | Keep Source Cover; automatic opportunity terminal |
| Cover allowance exhausted | Keep Source Cover or placeholder; terminal |
| Automatic validation fails | Keep Source Cover or placeholder; zero charge |
| Grouping split before adoption | Supersede and restart for resulting new Dishes |
| New local Cover choice during automatic job | Local choice wins; discard result |
| Title or Note edited during job | Deliver snapshot result; no restart |
| Selected Source moved during manual job | Invalidate before delivery |
| Source moved after valid delivery | Keep Proposed/current Cover |
| Automatic Cover undone | Restore prior selection; retain image in history |
| Current Cover deleted | Show placeholder |
| AI consent withdrawn | Cancel AI work; retain local history |

## Explicit Non-Goals

- Freeform image prompting
- Multiple generated candidates per request
- Automatic refresh of established Covers
- Automatic backfill of existing Dishes
- Generated images in Journal or Sources
- Generated images as generation inputs
- Permanent Original, Restaurant Style, or Next Time Cover modes
- Cloud storage of permanent Covers or Cover history
- Silent truncation of selected Source sets

## Implementation Acceptance Criteria

- Photo grouping and Cover generation are independent typed processing jobs.
- Add Idea creates its local Dish and standalone Note without grouping.
- The unified versioned generation contract supports zero to three images and
  all standalone Notes.
- Source selection, note interpretation, treatment enums, and validation rules
  are enforced server-side and validated client-side where applicable.
- Automatic opportunity, provenance, Cover history, persistent notices, and
  proposal state survive restart.
- Result adoption and all Cover switches are idempotent local transactions.
- Remote inputs and outputs are deleted after durable local receipt.
- Tests cover consent, offline retry, restart, grouping correction, batch
  allocation, validation failure, allowance exhaustion, automatic Undo, manual
  replacement, history switching/deletion, Source movement, and expiry.
