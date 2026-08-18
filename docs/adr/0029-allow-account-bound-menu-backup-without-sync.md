---
status: accepted
---

# Allow account-bound menu backup without sync

After V1, MyMenu may let an account store and restore an encrypted snapshot of
the device-local menu. The backup exists only for explicit recovery: it is not
live server menu state, does not make the server a menu authority, and does not
introduce continuous multi-device synchronization. Deleting the account
permanently deletes every account-bound backup without erasing a live
device-local menu.
