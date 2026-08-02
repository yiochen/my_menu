---
status: accepted
---

# Reset the pre-launch cloud menu schema

The existing server menu schema, stored media, RPCs, Edge Functions, tests, and
historical migrations are treated as pre-launch state and may be destructively
replaced by the reduced service schema. This avoids preserving a cloud-recovery
contract or migration path for data on which no real users depend.
