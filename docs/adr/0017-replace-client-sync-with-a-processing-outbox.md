---
status: accepted
---

# Replace client sync with a processing outbox

The Flutter app will remove generic sync operations, cursors, remote hydration,
remote deletion, and server-authoritative reconciliation. A narrow local
processing outbox will track upload, submission, retry, result download, and
proposal adoption, while every cooking-domain record remains ordinary local
state without replication metadata or tombstones.
