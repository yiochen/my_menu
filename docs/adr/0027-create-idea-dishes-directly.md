---
status: accepted
---

# Create Idea Dishes directly

Saving Add Idea atomically creates a new local Dish and optional standalone Note
without AI grouping, Photos or Unorganized placement, Review, or Organization
allowance. The implementation may reuse local adoption code with a predetermined
new-Dish outcome, then enqueue a separate context-grounded Cover job only after
AI consent permits it. This deliberately gives ideas a direct-create lifecycle
while sharing local persistence and processing infrastructure.
