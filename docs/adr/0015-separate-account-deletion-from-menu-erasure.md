---
status: accepted
---

# Separate account deletion from menu erasure

Deleting a MyMenu account removes its server identity, entitlements, active
jobs and assets, and deletable usage records, then returns the installation to
guest service. It does not alter the device-local menu; erasing the local
database and photos is a separate, explicitly destructive action because the
account does not own that content.
