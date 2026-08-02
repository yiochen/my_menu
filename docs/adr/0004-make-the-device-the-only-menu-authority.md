---
status: accepted
---

# Make the device the only menu authority

Server processing will return enrichment proposals rather than creating or
mutating dishes, captures, notes, plans, or other menu state. Only the device
can adopt a proposal into its local menu, which removes server CRUD and sync
machinery at the cost of making the client responsible for validation,
idempotency, and recovery when applying results.
