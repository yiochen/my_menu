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

**Menu context**:
Text from existing local dishes—including titles, descriptions, recipes, and
notes—supplied to a processing job so it can relate new input to known dishes.
_Avoid_: Cloud menu, menu backup

**AI provider**:
An external service that receives processing-job inputs and produces an
enrichment proposal under MyMenu's privacy requirements.
_Avoid_: MyMenu server, local processor

**AI usage record**:
A content-free record of processing consumed by a guest installation or MyMenu
account for quota, billing, and dispute handling.
_Avoid_: Job history, processing result

**Guest installation**:
An unsigned-in MyMenu installation with its own server-processing allowance and
no identity that a person can recover on another device.
_Avoid_: Anonymous account, guest account

**MyMenu account**:
An optional signed-in identity that owns paid access and AI usage allowance but
never owns the device-local menu.
_Avoid_: User profile, cloud menu account
