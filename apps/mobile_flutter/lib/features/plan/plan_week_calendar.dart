import 'package:flutter/material.dart';

import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class PlanWeekCalendar extends StatelessWidget {
  const PlanWeekCalendar({
    required this.dates,
    required this.selectedDate,
    required this.plan,
    required this.weekOffset,
    required this.onPrevious,
    required this.onNext,
    required this.onSelect,
    super.key,
  });

  final List<DateTime> dates;
  final DateTime selectedDate;
  final List<PlannedMeal> plan;
  final int weekOffset;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Eyebrow(weekOffset == 0 ? 'This week' : 'Next week'),
                  const SizedBox(height: 2),
                  Text(
                    _rangeLabel(dates),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            CircleIconButton(
              icon: Icons.chevron_left_rounded,
              size: 32,
              onPressed: onPrevious,
            ),
            const SizedBox(width: 6),
            CircleIconButton(
              icon: Icons.chevron_right_rounded,
              size: 32,
              onPressed: onNext,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: dates.map((DateTime date) {
            final int count = plan
                .where(
                  (PlannedMeal meal) => meal.dayKey == dayKeyForDate(date),
                )
                .length;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: _DayChip(
                  date: date,
                  count: count,
                  selected: _sameDay(date, selectedDate),
                  today: _sameDay(date, DateTime(2026, 7, 22)),
                  onTap: () => onSelect(date),
                ),
              ),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.date,
    required this.count,
    required this.selected,
    required this.today,
    required this.onTap,
  });

  final DateTime date;
  final int count;
  final bool selected;
  final bool today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? MyMenuColors.ink : MyMenuColors.oat,
      borderRadius: BorderRadius.circular(
        MediaQuery.sizeOf(context).width <= 380 ? 14 : 16,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: today
                ? Border.all(color: MyMenuColors.orange, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _weekdays[date.weekday - 1],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? Colors.white70 : MyMenuColors.muted,
                      fontSize: 9,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                '${date.day}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: selected ? Colors.white : MyMenuColors.ink,
                    ),
              ),
              const SizedBox(height: 2),
              _CountMarker(count: count),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountMarker extends StatelessWidget {
  const _CountMarker({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const SizedBox(height: 14);
    }
    return Container(
      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: MyMenuColors.orangeAction,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _rangeLabel(List<DateTime> dates) {
  final DateTime first = dates.first;
  final DateTime last = dates.last;
  if (first.month == last.month) {
    return '${_months[first.month - 1]} ${first.day}–${last.day}';
  }
  return '${_months[first.month - 1]} ${first.day}–'
      '${_months[last.month - 1]} ${last.day}';
}

const List<String> _weekdays = <String>[
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];
const List<String> _months = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
