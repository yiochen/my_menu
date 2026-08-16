import 'package:flutter/material.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/app/app_shell_theme.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/features/plan/plan_dish_dialog.dart';
import 'package:mymenu/features/plan/plan_theme.dart';
import 'package:mymenu/shared/drag_drop/drag_drop_board.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';

part 'plan_timeline_day_chrome.dart';
part 'plan_timeline_drag_drop_ui.dart';
part 'plan_timeline_label_chip.dart';
part 'plan_timeline_row.dart';

String monthShort(DateTime date) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[date.month - 1];
}

String weekdayShort(DateTime date) {
  const List<String> weekdays = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  return weekdays[date.weekday - 1];
}

typedef PlanDragDropPayload = DragDropPayload<String, String, PlannedMeal>;
typedef PlanDragDropSession = DragDropSession<String, String, PlannedMeal>;
typedef PlanDragDropMove = DragDropMove<String, String, PlannedMeal>;
typedef PlanMealMovedCallback = void Function(PlanDragDropMove move);

class PlanTimeline extends StatelessWidget {
  const PlanTimeline({
    required this.dates,
    required this.scrollController,
    required this.dragSession,
    required this.onDragSessionChanged,
    required this.onMealMoved,
    super.key,
  });

  final List<DateTime> dates;
  final ScrollController scrollController;
  final PlanDragDropSession? dragSession;
  final ValueChanged<PlanDragDropSession?> onDragSessionChanged;
  final PlanMealMovedCallback onMealMoved;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final PlanThemeTokens tokens = context.planTheme;
    final Map<String, DateTime> datesByKey = <String, DateTime>{
      for (final DateTime date in dates) dayKeyForDate(date): date,
    };

    return DragDropBoard<String, String, PlannedMeal>(
      groupIds: datesByKey.keys.toList(growable: false),
      itemsForGroup: state.plannedMealsForDay,
      itemIdOf: (PlannedMeal meal) => meal.id,
      defaultItemExtent: tokens.dishThumbHeight + tokens.dishRowInset.vertical,
      separatorExtent: tokens.dayDividerPadding.vertical + 1,
      scrollController: scrollController,
      dragSession: dragSession,
      autoScrollTriggerExtent: tokens.dragAutoScrollTrigger,
      autoScrollMaxStep: tokens.dragAutoScrollStep,
      debugOptions: const DragDropDebugOptions(showThresholds: true),
      onDragSessionChanged: onDragSessionChanged,
      onDragPositionChanged: (Offset position) {
        final PlanDragDropSession? session = dragSession;
        if (session == null) {
          return;
        }
        onDragSessionChanged(session.copyWith(globalPosition: position));
      },
      onMove: onMealMoved,
      separatorBuilder: (BuildContext context) {
        return _PlanTimelineDivider(tokens: tokens);
      },
      gapBuilder: (BuildContext context,
          DragDropGapState<String, String, PlannedMeal> gapState) {
        return _PlanDragGap(tokens: tokens, gapState: gapState);
      },
      emptyGroupBuilder: (BuildContext context,
          DragDropEmptyGroupState<String, String, PlannedMeal> groupState) {
        return _EmptyDayDropZone(tokens: tokens, state: groupState);
      },
      itemBuilder: (BuildContext context,
          DragDropItemState<String, String, PlannedMeal> itemState) {
        return _PlannedDishRow(
          key: ValueKey<String>('planned_meal_${itemState.itemId}'),
          meal: itemState.item,
        );
      },
      feedbackBuilder: (BuildContext context,
          DragDropItemState<String, String, PlannedMeal> itemState) {
        return _PlannedDishFeedback(meal: itemState.item);
      },
      groupBuilder: (
        BuildContext context,
        DragDropGroupState<String, String, PlannedMeal> groupState,
        Widget child,
      ) {
        return _PlanDayDropGroup(
          date: datesByKey[groupState.groupId]!,
          dayKey: groupState.groupId,
          tokens: tokens,
          isDragging: groupState.isDragging,
          hasItems: groupState.items.isNotEmpty,
          child: child,
        );
      },
    );
  }
}
