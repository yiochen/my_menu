---
status: accepted
---

# Finish in-flight processing before identity switches

MyMenu delays non-destructive sign-in and sign-out while a server processing job
is in flight because another service identity cannot retrieve that job's result.
Purely local pending work may follow the new identity; account deletion instead
cancels remote work while preserving local captures for a later retry.
