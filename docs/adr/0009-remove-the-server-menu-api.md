---
status: accepted
---

# Remove the server menu API

The server will expose only account, entitlement, quota, and typed processing-
job operations plus its internal worker. Dish, note, plan, capture, review,
deletion, hydration, and sync APIs will be removed; processing features share a
small job lifecycle while keeping type-specific request and result contracts.
