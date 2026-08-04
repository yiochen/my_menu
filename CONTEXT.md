# MyMenu

MyMenu is a personal cooking memory system for capturing, organizing, and
revisiting dishes a person cooks.

## Language

**Device-local menu**:
A person's menu and cooking memory that belongs to one device and is not
automatically recoverable on another device.
_Avoid_: Cloud library, synchronized menu

**Processing job**:
A time-limited request for server assistance that exists only long enough to
produce and return an enrichment for the device-local menu.
_Avoid_: Cloud record, synced operation

**Processing outbox**:
The device-local record of requested server assistance and the delivery and
adoption state of its enrichment proposal.
_Avoid_: Sync queue, replication log

**Enrichment proposal**:
A processing job's suggested addition or change, which has no effect on the
device-local menu until the device adopts it.
_Avoid_: Server mutation, synced update

**Review item**:
A local decision presented when an enrichment proposal cannot be safely
adopted automatically.
_Avoid_: Server review queue, failed job

**Cover**:
The best current, aspirational visual representation of a dish. A cover may be
AI-generated or reference a source photo; source photos remain part of the
documentary cooking history while serving as a cover.
_Avoid_: Hero image, source image

**Cover placeholder**:
The app-provided presentation shown when a dish has no selected cover. It is not
stored media and never appears in Cover history or the Journal.
_Avoid_: Default cover, generated fallback

**Source photo**:
A real photo captured or imported from a time the person made a dish. It is
preserved independently of whichever image is the current cover.
_Avoid_: Original cover, generation input

**Note**:
A standalone memory belonging to a Dish and displayed independently in its
Journal.
_Avoid_: Source note, photo caption, cooking-occasion note

**Generation source set**:
The exact one-to-three source photos authorized as visual references for a
cover operation, rather than the dish's entire source library.
_Avoid_: All dish photos, implicit sources, generated covers

**Source-grounded cover**:
A generated Cover whose context includes a Generation source set because the
Dish currently has Sources.
_Avoid_: Photo edit, image-only prompt

**Context-grounded cover**:
A generated Cover based on Dish title and Notes because the Dish currently has
no Sources. It is aspirational imagery and never documentary evidence.
_Avoid_: Idea-only prompt, Source photo, cooking record

**Automatic cover generation**:
The one-time creation and adoption of an AI-generated cover for an AI-enabled
new Dish or when a source-less legacy Dish first receives Sources. It is
prospective, locally undoable, and never an automatic refresh.
_Avoid_: Automatic cover refresh, background Improve Cover

**Improve Cover**:
A person-initiated operation that proposes a new Cover from the Dish context,
including selected Sources when any exist. The current Cover changes only when
the person accepts the proposal.
_Avoid_: Edit source, automatic cover generation

**Proposed cover**:
The single generated image stored locally while awaiting a person's decision
during Improve Cover. It has no effect on the current cover until accepted.
_Avoid_: Cover gallery, automatic cover

**Cover history**:
The device-local collection of every valid generated cover delivered for a
dish, whether or not it was ever selected. It is separate from the Journal.
_Avoid_: Journal entry, source gallery, proposed-cover queue

**Cover treatment**:
A versioned set of bounded choices for the look, view, and finish of a generated
cover.
_Avoid_: Prompt, freeform direction

**Cover provenance**:
Device-local metadata identifying how a generated cover was created, including
its origin, source-photo references, treatment, proposal, and acknowledgement
state; it does not retain deleted source image data.
_Avoid_: Prompt history, server generation record

**Cover validation**:
The semantic and technical gate confirming that a generated image safely
represents the same dish under its Source- or context-grounding rules before MyMenu
may present or adopt it. Automatic adoption additionally requires high
confidence.
_Avoid_: User review, generation success

**Cover generation chain**:
The related automatic generation attempts superseded as grouping corrections
change a dish's source photos. The chain consumes allowance only when its
current result becomes the cover.
_Avoid_: Retry charge, independent cover jobs

**Menu context**:
Text from existing local dishes—including titles, descriptions, recipes, and
notes—supplied to a processing job so it can relate new input to known dishes.
_Avoid_: Cloud menu, menu backup

**AI provider**:
An external service that receives processing-job inputs and produces an
enrichment proposal under MyMenu's privacy requirements.
_Avoid_: MyMenu server, local processor

**AI consent**:
The versioned agreement authorizing both AI organization and automatic cover
generation under the disclosed provider handling. Automatic covers may be
disabled later without withdrawing consent for organization.
_Avoid_: Cover consent, grouping consent

**AI usage record**:
A content-free record of processing consumed by a guest installation or MyMenu
account for quota, billing, and dispute handling.
_Avoid_: Job history, processing result

**Organization allowance**:
The processing entitlement available for AI capture grouping. It is independent
of Cover allowance.
_Avoid_: AI allowance, cover credits

**Cover allowance**:
The processing entitlement available for automatic and manual cover generation.
Its exhaustion never prevents AI organization.
_Avoid_: AI allowance, organization credits

**Guest installation**:
An unsigned-in MyMenu installation with its own server-processing allowance and
no identity that a person can recover on another device.
_Avoid_: Anonymous account, guest account

**MyMenu account**:
An optional signed-in identity that owns paid access and AI usage allowance but
never owns the device-local menu.
_Avoid_: User profile, cloud menu account
