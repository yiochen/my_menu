---
status: accepted
---

# Keep Supabase as reduced service infrastructure

MyMenu will retain Supabase Auth for guest and optional signed-in identities,
Postgres for entitlements, content-free usage, and ephemeral job metadata,
Storage for expiring job assets, and Edge Functions for orchestration. Supabase
will no longer hold or expose the cooking domain, avoiding an unrelated
infrastructure migration while sharply reducing its data responsibility.
