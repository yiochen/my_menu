# Plan Drag And Drop Implementation

## Goal

Build a Trello-style drag-and-drop experience for the Plan timeline where:

- a dish can be reordered within a day
- a dish can be moved to another day
- a dish can be dropped into an empty day
- a dish can be dropped onto `+ Add another day`
- a dish can be dropped onto trash
- the insertion gap matches the actual dragged row height

## State Ownership

Keep reusable drag session mechanics in
`apps/mobile_flutter/lib/shared/drag_drop/drag_drop_board.dart`.

Keep Plan-specific overlay state in
`apps/mobile_flutter/lib/features/plan/plan_screen.dart`.

Terminology:

- `Dish` is the reusable recipe-like content:
  title, thumbnail, prep time, and other display data
- `PlannedMeal` is the plan entry instance:
  a unique planned item with its own `id`, `dayKey`, `dishId`, and optional
  label such as `Lunch` or `Dinner`

Drag-and-drop should operate on `PlannedMeal`, not `Dish`, so duplicate dishes
are handled correctly. If the same dish is planned twice, those are still two
different `PlannedMeal` records with different `PlannedMeal.id` values.

The shared board tracks:

- the dragged `DragDropPayload`
- the measured dragged item height
- the latest global drag position for edge autoscroll

The Plan screen tracks:

- `dragSession`
- `isAddAnotherDayHighlighted`
- `isTrashHighlighted`

Expose drag state to the Plan screen through:

- `onDragSessionChanged`
- `DragDropSession<String, String, PlannedMeal>?`

Pseudo code:

```dart
class PlanScreenState {
  DragDropSession<String, String, PlannedMeal>? dragSession;
  bool isAddAnotherDayHighlighted;
  bool isTrashHighlighted;
}
```

Pseudo data shape:

```dart
class Dish {
  String id;
  String title;
  String heroImageUrl;
}

class PlannedMeal {
  String id;      // unique plan-entry id
  String dayKey;  // which day this entry belongs to
  String dishId;  // points to Dish.id
  String? label;
}
```

## Drag Start

The shared board wraps each planned dish row in a
`LongPressDraggable<DragDropPayload<String, String, PlannedMeal>>`.

Measure each row's rendered height after paint and cache it by planned item id.

Send the resulting drag session to `PlanScreen` for overlay/shade behavior.

Pseudo code:

```dart
onDragStarted() {
  final rowHeight = measuredRowHeightFor(meal.id);
  notifyDragSessionChanged(payloadFor(meal, rowHeight));
}
```

## Drag Session Behavior

When dragging starts:

- store the meal
- store the row height
- dim non-timeline sections
- show trash target

While dragging:

- keep timeline interactive
- auto-scroll near top and bottom edges

When dragging ends or completes:

- clear drag state
- clear highlights
- hide trash target

Pseudo code:

```dart
handleDragSessionChanged(session) {
  dragSession = session;
  clearHighlights();
}
```

## Timeline Rendering

Keep timeline rendering in
`apps/mobile_flutter/lib/features/plan/plan_timeline.dart`.

Pass drag session data down to each day card.

Each day card should keep normal vertical layout.

Instead of building a `Stack` with absolutely positioned insertion targets, the
card renders a normal list of children:

- visible planned-meal rows
- fixed-height dividers between visible rows
- one placeholder child inserted at the computed insertion index

The insertion index is computed from drag geometry, not from dedicated hit-test
widgets layered on top of the list.

Pseudo code:

```dart
PlanTimeline(
  draggingMealId: draggingMeal?.id,
  draggingMealHeight: draggingMealHeight,
)
```

## Original Position Placeholder

When the dragged dish belongs to the current day card, do not render the full
row in-place.

Remove that row from the visible rows list.

Replace it with a thin placeholder inserted at the dragged meal's original
index.

Keep that placeholder at the original insertion index.

Pseudo code:

```dart
visibleMeals = meals.where((meal) => meal.id != draggingMealId);
placeholderIndex = sourceMealOriginalIndex;
```

## Insertion Gap Sizing

Use the actual `draggingMealHeight` as the active insertion gap height.

Do not hardcode hover gap size.

Fall back to token-based row height only when no measured height exists.

Pseudo code:

```dart
double activeGapHeight = draggingMealHeight ?? defaultRowHeight;
```

## Drop Target Behavior

Keep the whole meals area for one day card as a single `DragTarget<PlannedMeal>`.

On drag move inside that day card:

- set hovered insertion index
- animate the placeholder at that index open

On leave:

- clear hovered insertion index

On accept:

- move the meal to the target day and index
- clear drag state

Pseudo code:

```dart
DragTarget(
  onWillAccept: () => true,
  onMove: (details) {
    hoveredInsertionIndex = insertionIndexForPointer(details.offset);
  },
  onLeave: () {
    hoveredInsertionIndex = null;
  },
  onAccept: (meal) {
    moveMeal(meal, dayKey, hoveredInsertionIndex);
    hoveredInsertionIndex = null;
  },
)
```

## Day Layout Computation

Build the day card from normal list children, not absolute-positioned overlays.

The key idea is to separate:

- geometry used for insertion-index calculation
- children used for rendering

During drag, compute insertion index from a frozen set of row anchors based on
the original day order, before any placeholder animation changes the visible
layout.

Those anchors must account for:

- each row's original height
- each separator's fixed height

The separator height is stable, so it can be treated as a fixed constant in the
computation.

Pseudo code:

```dart
rowHeight = measuredOrTokenRowHeight;
dividerHeight = fixedDividerHeight;

cursor = 0;
for each meal in originalMeals {
  centerY[meal.id] = cursor + rowHeight / 2;
  cursor += rowHeight;
  if (meal is not last) {
    cursor += dividerHeight;
  }
}
```

Then compute insertion index from those frozen centers.

Important detail:

- skip the dragged meal itself when comparing pointer position
- keep the other meals in their original order
- do not use animated positions as input

Pseudo code:

```dart
int insertionIndexForPointer(pointerY) {
  var insertionIndex = 0;

  for (final meal in originalMeals) {
    if (meal.id == draggingMealId) continue;
    if (pointerY > centerY[meal.id]) {
      insertionIndex += 1;
    }
  }

  return insertionIndex;
}
```

Finally, render the list with a placeholder child inserted at the computed
index.

Pseudo code:

```dart
children = [
  for (int index = 0; index <= visibleMeals.length; index++) {
    if (placeholderIndex == index) {
      placeholder(height: activeOrThinPlaceholderHeight);
    }

    if (index < visibleMeals.length) {
      row(visibleMeals[index]);
      if (index != visibleMeals.length - 1) {
        divider(height: fixedDividerHeight);
      }
    }
  }
]
```

This keeps the rendering model simple:

- the day card stays a normal vertical list
- the placeholder is just another child in that list
- the insertion math uses frozen anchors, not animated positions

## Card Activation And Exit Detection

Whether the pointer is "inside" a day card does not depend on whether the
placeholder animation has finished.

Instead:

- each day card owns one `DragTarget`
- if drag callbacks are arriving for that card, it is the active card
- when `onLeave` fires, the pointer has left that card

That means card activation is based on the card's stable drag-target bounds,
while insertion index is based on frozen row-center anchors.

## Cross-Day Moves

Any day card can accept a dragged meal.

Dropping onto a band in another day should call
`movePlannedMeal(meal.id, targetDayKey, targetIndex)`.

The state layer handles removing from the old day and inserting into the new
day.

Pseudo code:

```dart
movePlannedMeal(
  meal.id,
  targetDayKey: targetDayKey,
  targetIndex: insertionIndex,
);
```

## Empty Day Behavior

Empty day cards should still expose a drop zone while dragging.

At rest, the empty-day target should be subtle.

On hover, it should expand visually to show a valid landing area.

Accepting a drop inserts at index `0`.

Pseudo code:

```dart
if (dayMeals.isEmpty) {
  showEmptyDayDragTarget(
    onAccept: (meal) => moveMeal(meal, dayKey, 0),
  );
}
```

## Add Another Day Target

Keep `+ Add another day` as a screen-level `DragTarget`.

On hover:

- highlight button

On drop:

- show date picker
- call `ensurePlanDateVisible(selectedDate)`
- move meal into that date

Insert at the end of that day's current list.

Pseudo code:

```dart
onAccept(meal) async {
  final date = await showDatePicker(...);
  ensurePlanDateVisible(date);
  moveMeal(meal, dayKeyForDate(date), endOfDayList);
}
```

## Trash Target

Show the trash target only while dragging.

Place it at center-right over the dimmed screen.

On hover:

- highlight target

On drop:

- remove the planned meal
- clear drag state

Pseudo code:

```dart
onAccept(meal) {
  removePlannedMeal(meal.id);
  handleDragEnded();
}
```

## Overlay Behavior

While dragging:

- only the timeline remains visually primary
- header, cook-tonight, menu strip, and review card are shaded
- bottom nav and FAB are hidden by app shell

The timeline stays interactive above the dimmed sections.

## Files And Responsibilities

- `apps/mobile_flutter/lib/features/plan/plan_screen.dart`
  Plan overlay state, add-another-day target, trash target
- `apps/mobile_flutter/lib/shared/drag_drop/drag_drop_board.dart`
  reusable board API, drag session, edge autoscroll, move payloads
- `apps/mobile_flutter/lib/shared/drag_drop/drag_drop_group.dart`
  reusable group drop target, measured rows, insertion index, animated slots
- `apps/mobile_flutter/lib/features/plan/plan_timeline.dart`
  Plan wiring into `DragDropBoard<String, String, PlannedMeal>`
- `apps/mobile_flutter/lib/features/plan/plan_timeline_drag_drop_ui.dart`
  Plan-specific day card chrome, dividers, empty-day target, yellow gap
- `apps/mobile_flutter/lib/features/plan/plan_timeline_row.dart`
  Plan dish row and drag feedback visuals
- `apps/mobile_flutter/lib/domain/sync/my_menu_state.dart`
  move, remove, and extend plan data

## Validation

Validate the behavior with the following checks:

- dragging the first dish from a populated day leaves a placeholder, not an
  empty card
- hover gap height matches the exact dragged row height
- hover highlight does not paint over adjacent dish rows
- reordering within a day inserts at the expected index
- moving across days inserts correctly
- empty day accepts a drop
- `+ Add another day` accepts drop and prompts for date
- trash removes meal
- auto-scroll works near top and bottom

Run:

- `dart analyze`
- `dart run tool/structural_lint.dart`
- `flutter test`
