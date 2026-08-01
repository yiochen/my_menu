# MyMenu mobile mockup brief

## Intent

MyMenu serves home cooks who already photograph food and want those moments to become useful cooking memory. The primary jobs are: decide what to cook this week, revisit a dish the user can already make, capture a cooking moment in seconds, and steadily add notes, sources, and recipe detail.

The primary delivery device is iPhone 14, with iPhone SE and Pixel 7 as stress viewports. The visual direction is Soft Modern / Warm Minimalist: cream canvas, tactile white and oat surfaces, orange action color, charcoal copy, rounded geometric type, generous radii, and restrained ambient shadows.

Assumptions: the user has an existing local menu; the sample week begins Monday, July 20, 2026; AI review is contextual rather than a tab; AI-only actions can pause offline while local viewing, notes, and planning remain available.

## Model

- Dish: durable object with cover, recipe, ingredients, notes, sources, made count, last-made date, favorite state, and planned meals.
- Dish deletion: a menu-level, multi-select mutation that removes each selected dish and its dependent MyMenu history, notes, source copies, and planned meals. Ideas and other dishes with no cooking history are still eligible; temporary processing placeholders are not dishes yet and stay visible but unselectable. Deletion never changes originals in the phone photo library and remains briefly recoverable as one atomic Undo.
- Cooking occasion: one time the user made a dish. It determines made count and can contain several source photos plus notes.
- Source photo: documentary image captured during one cooking occasion; photo count and made count are intentionally distinct.
- Note: first-class mutable memory; created and corrected from dish detail.
- Planned meal: one dish on one day; created from an empty day or “Cook again,” and removable or reschedulable from its row menu.
- Capture item: starts as photo import, camera capture, or idea; AI later connects it to a dish or creates one.
- Review item: temporary uncertainty with two explicit outcomes—confirm an existing dish or create a new one.

Counts are internally reconciled in the screens: the menu begins with 24 dishes and shows 22 after two selected dishes are deleted; “recently added” is a subset of all dishes; Miso Salmon Bowl has been made 8 times and shows three recent source moments with additional history reachable below; the review card and queue both show 2 unresolved items.

## Shell and interaction contract

Plan and Menu retain the same floating bottom shell: Plan first, centered global capture action, Menu second. Menu carries the contextual capture-review count. Menu uses one compact fixed search-and-filter utility region instead of an oversized title block; its shadow appears only after vertical scrolling begins. Dish count belongs beside the collection heading. The icon-only filter trigger stays fixed at the left of a compact horizontally scrolling quick-filter row, and selection replaces the search field in place. Plan uses a fixed, horizontally pageable seven-day calendar and a horizontally pageable selected-day card; the month/year opens date selection and one Today control replaces week arrows. The orange filled action is reserved for the highest-frequency contextual task. Rows open their detail or picker task; infrequent move/remove actions live in a row overflow and remain reversible. Capture starts as a modal with one close path and no request to classify before capturing, while a completed created-dish result opens as a full screen.

Capture outcomes explicitly distinguish local save from AI organization. The normal path shows automatic matching or creation with Correct and Undo. Offline capture queues organization without blocking capture. Add Idea captures only the idea and an optional note; planning remains a separate Plan task. Improve Cover is a persistent chip on the cover image and never alters source photos; it progresses through source selection, optional freeform visual direction, generation, comparison, and explicit acceptance.

Long-pressing any finished dish is the visual entry into multi-select mode; the transition gives haptic feedback, selects that dish, and replaces the sticky search bar with a compact close–count–Select all header. Assistive technologies expose a semantic Select dish action on each card rather than requiring the gesture. Ideas and dishes with zero history can be selected, while processing placeholders cannot. Selection temporarily replaces the primary navigation with one quiet deletion action, while the destructive filled action appears only in the confirmation sheet. Confirmation names the selected dishes and explains dependent data removal before a locally applied result returns to the stable Menu shell with a brief atomic Undo.

## Coverage decisions

- Plan: typical selected day includes two planned dishes and one add action. A separate next-week empty date proves paging and non-today planning; an action sheet proves move/remove/undo.
- Menu: typical/dense content is represented as one unified grid under a sticky search utility bar, controlled by All, Favorites, Recently added, and Filters. Menu-level management covers long-press entry, multi-selection across the current filtered results, a replacement selection header, scoped destructive confirmation, updated counts, and Undo. Empty is represented separately because it materially changes the primary task.
- Dish detail: Journal is the primary leftmost page and combines notes, cooking occasions, and source photos into one informal bulletin board; Recipe is the adjacent swipeable page, and the shared selector slides continuously with taps or horizontal swipes. Cook Again visibly branches into cooking now or planning later.
- Menu status details: captures needing attention use a compact circular count badge on Menu, while newly created dishes use a styled white “New” label that gives one brief wobble as the card appears.
- Capture: canonical modal, local-save/organizing, matched, created, offline-queued, camera-permission, valid idea, and validation states are required.
- Review: queue, alternate-dish search-empty, and correction paths are required because AI uncertainty must remain recoverable without becoming primary navigation.
- Improve Cover: source selection, generating, proposed result, offline, and online error states are required; the current cover and originals remain safe throughout.
