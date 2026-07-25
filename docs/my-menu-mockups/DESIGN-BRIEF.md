# MyMenu mobile mockup brief

## Intent

MyMenu serves home cooks who already photograph food and want those moments to become useful cooking memory. The primary jobs are: decide what to cook this week, revisit a dish the user can already make, capture a cooking moment in seconds, and steadily add notes, sources, and recipe detail.

The primary delivery device is iPhone 14, with iPhone SE and Pixel 7 as stress viewports. The visual direction is Soft Modern / Warm Minimalist: cream canvas, tactile white and oat surfaces, orange action color, charcoal copy, rounded geometric type, generous radii, and restrained ambient shadows.

Assumptions: the user has an existing local menu; the sample week begins Monday, July 20, 2026; AI review is contextual rather than a tab; AI-only actions can pause offline while local viewing, notes, and planning remain available.

## Model

- Dish: durable object with cover, recipe, ingredients, notes, sources, made count, last-made date, favorite state, and planned meals.
- Cooking occasion: one time the user made a dish. It determines made count and can contain several source photos plus notes.
- Source photo: documentary image captured during one cooking occasion; photo count and made count are intentionally distinct.
- Note: first-class mutable memory; created and corrected from dish detail.
- Planned meal: one dish on one day; created from an empty day or “Cook again,” and removable or reschedulable from its row menu.
- Capture item: starts as photo import, camera capture, or idea; AI later connects it to a dish or creates one.
- Review item: temporary uncertainty with two explicit outcomes—confirm an existing dish or create a new one.

Counts are internally reconciled in the screens: the menu contains 24 dishes; “recently added” is a subset of all dishes; Miso Salmon Bowl has been made 8 times and shows three recent source moments with additional history reachable below; the review card and queue both show 2 unresolved items.

## Shell and interaction contract

Plan and Menu retain the same floating bottom shell: Plan first, centered global capture action, Menu second. Plan uses a seven-day calendar with a single selected-day content region; a day can contain zero, one, or several planned dishes. Previous/next controls move by week. The orange filled action is reserved for the highest-frequency contextual task. Rows open their detail or picker task; infrequent move/remove actions live in a row overflow and remain reversible. Capture is a modal with one close path and no request to classify before capturing.

Capture outcomes explicitly distinguish local save from AI organization. The normal path shows automatic matching or creation with Correct and Undo. Offline capture queues organization without blocking capture. Add Idea captures only the idea and an optional note; planning remains a separate Plan task. Improve Cover is a persistent chip on the cover image and never alters source photos; it progresses through source selection, optional freeform visual direction, generation, comparison, and explicit acceptance.

## Coverage decisions

- Plan: typical selected day includes two planned dishes, one add action, and a clearly unplanned suggestion. A separate next-week empty date proves non-today planning; an action sheet proves move/remove/undo.
- Menu: typical/dense content is represented as one unified grid controlled by All, Favorites, Recently added, and Filters. Empty is represented separately because it materially changes the primary task.
- Dish detail: nested recipe, ingredients, notes, cooking occasions, and source photos are covered through top and scrolled states. Cook Again visibly branches into cooking now or planning later.
- Capture: canonical modal, local-save/organizing, matched, created, offline-queued, camera-permission, valid idea, and validation states are required.
- Review: queue, alternate-dish search-empty, and correction paths are required because AI uncertainty must remain recoverable without becoming primary navigation.
- Improve Cover: source selection, generating, proposed result, offline, and online error states are required; the current cover and originals remain safe throughout.
