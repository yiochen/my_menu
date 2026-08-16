import 'package:flutter/material.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/features/plan/plan_selected_day.dart';
import 'package:mymenu/features/plan/plan_sheets.dart';
import 'package:mymenu/features/plan/plan_week_calendar.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({
    required this.onOpenReview,
    required this.onOpenPhotos,
    super.key,
  });

  // Review entry now lives on the Menu navigation badge. This callback stays
  // in the public contract while callers migrate without changing Plan UI.
  final VoidCallback onOpenReview;
  final VoidCallback onOpenPhotos;

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  static final DateTime _sampleToday = DateTime(2026, 7, 22);
  static final DateTime _pageEpochUtc = DateTime.utc(2021);
  static const int _pageCount = 7305;

  late DateTime _selectedDate = _sampleToday;
  late final PageController _dayController = PageController(
    initialPage: _pageForDate(_sampleToday),
  );

  @override
  void dispose() {
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final double horizontal = MyMenuUnits.pageHorizontal(context);

    return WarmPage(
      topPadding: 0,
      bottomPadding: 0,
      horizontalPadding: 0,
      child: Column(
        children: <Widget>[
          Material(
            color: MyMenuColors.cream,
            elevation: 5,
            shadowColor: const Color(0x1A302318),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                MediaQuery.paddingOf(context).top + 12,
                horizontal,
                12,
              ),
              child: PlanWeekCalendar(
                selectedDate: _selectedDate,
                plan: state.plan,
                unorganizedPhotoCount: state.unorganizedPhotoCount,
                organizingPhotos: state.isOrganizingPhotos,
                onPickDate: _pickDate,
                onToday: () => _selectDate(_sampleToday),
                onSelect: _selectDate,
                onOpenPhotos: widget.onOpenPhotos,
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              key: const ValueKey<String>('plan_screen'),
              controller: _dayController,
              onPageChanged: (int page) {
                final DateTime date = _dateForPage(page);
                if (!_sameDay(date, _selectedDate)) {
                  setState(() => _selectedDate = date);
                }
              },
              itemBuilder: (BuildContext context, int page) {
                // Let the delegate discover the final page lazily. Supplying a
                // large finite child count makes Flutter precompute the full
                // scroll extent, which can exceed its layout precision
                // tolerance on fractional Android logical widths.
                if (page >= _pageCount) {
                  return null;
                }
                final DateTime date = _dateForPage(page);
                final String dayKey = dayKeyForDate(date);
                return ListView(
                  key: ValueKey<String>('plan_day_page_$dayKey'),
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    16,
                    horizontal,
                    MyMenuUnits.pageBottom,
                  ),
                  children: <Widget>[
                    PlanSelectedDay(
                      date: date,
                      meals: state.plannedMealsForDay(dayKey),
                      state: state,
                      onAdd: () => showPlanPickerSheet(
                        context,
                        state,
                        date: date,
                      ),
                      onChanged: () => setState(() {}),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2040, 12, 31),
      helpText: 'Choose a day to plan',
    );
    if (date != null && mounted) {
      _selectDate(date);
    }
  }

  void _selectDate(DateTime date) {
    final DateTime normalized = DateTime(date.year, date.month, date.day);
    setState(() => _selectedDate = normalized);
    _dayController.animateToPage(
      _pageForDate(normalized),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  static int _pageForDate(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day)
          .difference(_pageEpochUtc)
          .inDays;

  static DateTime _dateForPage(int page) {
    final DateTime utc = _pageEpochUtc.add(Duration(days: page));
    return DateTime(utc.year, utc.month, utc.day);
  }
}

bool _sameDay(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;
