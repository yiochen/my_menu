---
status: accepted
---

# Expire inactive guest identities

An unsigned-in guest identity and its remaining content-free usage records will
be deleted after 90 days without server processing, once no processing job is
active. A returning installation silently receives a new guest identity while
its device-local menu remains unchanged; signed-in MyMenu accounts do not
expire through inactivity.
