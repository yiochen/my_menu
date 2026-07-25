import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/plan/plan_selected_day.dart';
import 'package:mymenu/features/plan/plan_sheets.dart';
import 'package:mymenu/features/plan/plan_support_cards.dart';
import 'package:mymenu/features/plan/plan_week_calendar.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({
    required this.onOpenReview,
    super.key,
  });

  final VoidCallback onOpenReview;

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  static final DateTime _sampleMonday = DateTime(2026, 7, 20);
  DateTime _selectedDate = DateTime(2026, 7, 22);
  int _weekOffset = 0;

  List<DateTime> get _week {
    final DateTime first = _sampleMonday.add(Duration(days: _weekOffset * 7));
    return List<DateTime>.generate(
      7,
      (int index) => first.add(Duration(days: index)),
      growable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final String selectedKey = dayKeyForDate(_selectedDate);

    return WarmPage(
      topPadding: 0,
      bottomPadding: 0,
      child: ListView(
        key: const ValueKey<String>('plan_screen'),
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top + MyMenuUnits.pageTop,
        ),
        children: <Widget>[
          _PlanHeader(reviewCount: state.reviewItems.length),
          const SizedBox(height: 16),
          PlanWeekCalendar(
            dates: _week,
            selectedDate: _selectedDate,
            plan: state.plan,
            weekOffset: _weekOffset,
            onPrevious: _previousWeek,
            onNext: _nextWeek,
            onSelect: (DateTime date) => setState(() => _selectedDate = date),
          ),
          const SizedBox(height: 16),
          PlanSelectedDay(
            date: _selectedDate,
            meals: state.plannedMealsForDay(selectedKey),
            state: state,
            onAdd: () => showPlanPickerSheet(
              context,
              state,
              date: _selectedDate,
            ),
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 16),
          if (_weekOffset == 0) ...<Widget>[
            PlanSuggestionCard(
              state: state,
              date: _selectedDate,
              onAdded: () => setState(() {}),
            ),
            const SizedBox(height: 16),
            if (state.reviewItems.isNotEmpty)
              PlanReviewCard(
                key: const ValueKey<String>('plan_review_card'),
                count: state.reviewItems.length,
                onTap: widget.onOpenReview,
              ),
          ] else
            const _WeekNavigationHint(),
          const SizedBox(
            key: ValueKey<String>('plan_bottom_scroll_clearance'),
            height: MyMenuUnits.pageBottom,
          ),
        ],
      ),
    );
  }

  void _previousWeek() {
    setState(() {
      _weekOffset -= 1;
      _selectedDate = _week.first;
    });
  }

  void _nextWeek() {
    setState(() {
      _weekOffset += 1;
      _selectedDate = _weekOffset == 1 ? DateTime(2026, 8) : _week.first;
    });
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({required this.reviewCount});

  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'What are we cooking?',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text('Plan', style: Theme.of(context).textTheme.displaySmall),
              ],
            ),
          ),
          const MyMenuAvatar(),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              CircleIconButton(
                icon: Icons.notifications_none_rounded,
                semanticLabel: 'Notifications',
                onPressed: () {},
              ),
              if (reviewCount > 0)
                Positioned(
                  right: 8,
                  top: 7,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: MyMenuColors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekNavigationHint extends StatelessWidget {
  const _WeekNavigationHint();

  @override
  Widget build(BuildContext context) {
    return const StatusStrip(
      icon: Icons.swap_horiz_rounded,
      text: 'Swipe the calendar or use arrows to move by week.',
    );
  }
}
