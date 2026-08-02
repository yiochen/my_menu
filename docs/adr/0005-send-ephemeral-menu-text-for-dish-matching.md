---
status: accepted
---

# Send ephemeral menu text for dish matching

Capture-processing jobs may receive a temporary snapshot of text from every
local dish, including titles, descriptions, recipes, and notes, so AI can
propose matches with existing dishes. The snapshot follows the processing
job's deletion policy and never becomes durable server menu state, deliberately
trading disclosure of menu text for more accurate organization.

Existing dish covers and source photos are excluded from automatic matching.
They may be uploaded only when the person explicitly selects them for an
image-based operation such as improving a cover; ambiguous text matches return
candidate dishes for local review.
