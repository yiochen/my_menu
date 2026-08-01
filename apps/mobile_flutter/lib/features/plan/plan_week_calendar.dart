import 'package:flutter/material.dart';

import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class PlanWeekCalendar extends StatefulWidget {
  const PlanWeekCalendar({
    required this.selectedDate,
    required this.plan,
    required this.onPickDate,
    required this.onToday,
    required this.onSelect,
    super.key,
  });

  final DateTime selectedDate;
  final List<PlannedMeal> plan;
  final VoidCallback onPickDate;
  final VoidCallback onToday;
  final ValueChanged<DateTime> onSelect;

  @override
  State<PlanWeekCalendar> createState() => _PlanWeekCalendarState();
}

class _PlanWeekCalendarState extends State<PlanWeekCalendar> {
  static final DateTime _sampleMonday = DateTime(2026, 7, 20);
  static const int _originPage = 500;
  late final PageController _controller = PageController(
    initialPage: _pageForDate(widget.selectedDate),
  );

  @override
  void didUpdateWidget(covariant PlanWeekCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameDay(oldWidget.selectedDate, widget.selectedDate) &&
        _controller.hasClients) {
      final int target = _pageForDate(widget.selectedDate);
      final int current = _controller.page?.round() ?? target;
      if (target != current) {
        _controller.animateToPage(
          target,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            TextButton.icon(
              key: const ValueKey<String>('plan_month_picker'),
              onPressed: widget.onPickDate,
              style: TextButton.styleFrom(
                foregroundColor: MyMenuColors.ink,
                padding: EdgeInsets.zero,
              ),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              label: Text(
                _monthYear(widget.selectedDate),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const Spacer(),
            CircleIconButton(
              key: const ValueKey<String>('plan_today_button'),
              icon: Icons.today_outlined,
              semanticLabel: 'Jump to today',
              onPressed: widget.onToday,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: PageView.builder(
            key: const ValueKey<String>('plan_week_page_view'),
            controller: _controller,
            onPageChanged: (int page) {
              final DateTime monday = _mondayForPage(page);
              final DateTime sunday = monday.add(const Duration(days: 6));
              if (widget.selectedDate.isBefore(monday) ||
                  widget.selectedDate.isAfter(sunday)) {
                widget.onSelect(monday);
              }
            },
            itemBuilder: (BuildContext context, int page) {
              final DateTime monday = _mondayForPage(page);
              final List<DateTime> dates = List<DateTime>.generate(
                7,
                (int index) => monday.add(Duration(days: index)),
                growable: false,
              );
              return Row(
                children: dates.map((DateTime date) {
                  final int count = widget.plan
                      .where(
                        (PlannedMeal meal) =>
                            meal.dayKey == dayKeyForDate(date),
                      )
                      .length;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: _DayChip(
                        date: date,
                        count: count,
                        selected: _sameDay(date, widget.selectedDate),
                        today: _sameDay(date, DateTime(2026, 7, 22)),
                        onTap: () => widget.onSelect(date),
                      ),
                    ),
                  );
                }).toList(growable: false),
              );
            },
          ),
        ),
      ],
    );
  }

  int _pageForDate(DateTime date) {
    final DateTime monday = _mondayFor(date);
    final int weekOffset = DateTime.utc(monday.year, monday.month, monday.day)
            .difference(
              DateTime.utc(
                _sampleMonday.year,
                _sampleMonday.month,
                _sampleMonday.day,
              ),
            )
            .inDays ~/
        7;
    return _originPage + weekOffset;
  }

  DateTime _mondayForPage(int page) {
    final DateTime utcMonday = DateTime.utc(
      _sampleMonday.year,
      _sampleMonday.month,
      _sampleMonday.day,
    ).add(Duration(days: (page - _originPage) * 7));
    return DateTime(utcMonday.year, utcMonday.month, utcMonday.day);
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
              _CountMarker(
                key: ValueKey<String>(
                  'plan_day_count_${dayKeyForDate(date)}',
                ),
                count: count,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountMarker extends StatelessWidget {
  const _CountMarker({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const SizedBox(height: 14);
    }
    return Container(
      width: 14,
      height: 14,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: MyMenuColors.orangeAction,
        shape: BoxShape.circle,
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

DateTime _mondayFor(DateTime date) => DateTime(date.year, date.month, date.day)
    .subtract(Duration(days: date.weekday - DateTime.monday));

bool _sameDay(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;

String _monthYear(DateTime date) => '${_months[date.month - 1]} ${date.year}';

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
