import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/app/app_shell_theme.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/plan/plan_dish_dialog.dart';
import 'package:mymenu/features/plan/plan_theme.dart';

part 'plan_timeline_day_chrome.dart';
part 'plan_timeline_day_card.dart';
part 'plan_timeline_day_card_layout.dart';
part 'plan_timeline_drag_debug.dart';
part 'plan_timeline_label_chip.dart';
part 'plan_timeline_row.dart';
part 'plan_timeline_drop_zones.dart';

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

typedef PlanMealMovedCallback = void Function(
  PlannedMeal meal,
  String targetDayKey,
  int targetIndex,
);

typedef PlanMealDragStartedCallback = void Function(
  PlannedMeal meal,
  double rowHeight,
  double touchOffsetY,
);

double dragGapHeightFor(
  PlanThemeTokens tokens, {
  double? draggingMealHeight,
}) {
  if (draggingMealHeight != null) {
    return draggingMealHeight;
  }
  final double rowHeight =
      tokens.dishThumbHeight + tokens.dishRowInset.vertical;
  return rowHeight * 0.5;
}

class PlanTimeline extends StatelessWidget {
  const PlanTimeline({
    required this.dates,
    required this.draggingMealId,
    required this.draggingMealHeight,
    required this.draggingTouchOffsetY,
    required this.draggingGlobalPosition,
    required this.onDragStarted,
    required this.onDragMoved,
    required this.onDragEnded,
    required this.onMealMoved,
    super.key,
  });

  final List<DateTime> dates;
  final String? draggingMealId;
  final double? draggingMealHeight;
  final double? draggingTouchOffsetY;
  final Offset? draggingGlobalPosition;
  final PlanMealDragStartedCallback onDragStarted;
  final ValueChanged<Offset> onDragMoved;
  final VoidCallback onDragEnded;
  final PlanMealMovedCallback onMealMoved;

  @override
  Widget build(BuildContext context) {
    final PlanThemeTokens tokens = context.planTheme;

    return Column(
      children: dates.map((DateTime date) {
        return Padding(
          padding: EdgeInsets.only(bottom: tokens.dayRowSpacing),
          child: _PlanDayCard(
            date: date,
            tokens: tokens,
            draggingMealId: draggingMealId,
            draggingMealHeight: draggingMealHeight,
            draggingTouchOffsetY: draggingTouchOffsetY,
            draggingGlobalPosition: draggingGlobalPosition,
            onDragStarted: onDragStarted,
            onDragMoved: onDragMoved,
            onDragEnded: onDragEnded,
            onMealMoved: onMealMoved,
          ),
        );
      }).toList(growable: false),
    );
  }
}
