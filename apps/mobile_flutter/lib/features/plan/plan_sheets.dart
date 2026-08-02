import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';
import 'package:mymenu/features/plan/plan_sheet_action_row.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/local_write_feedback.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

part 'plan_actions_sheet.dart';

Future<void> showPlanPickerSheet(
  BuildContext context,
  MyMenuState state, {
  required DateTime date,
}) async {
  final String? dishId = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PlanPickerSheet(state: state, date: date),
  );
  if (dishId != null && context.mounted) {
    await runLocalWriteWithFeedback(
      context,
      () => state.addPlannedMeal(
        dayKeyForDate(date),
        dishId,
        label: 'Dinner',
      ),
    );
  }
}

class _PlanPickerSheet extends StatefulWidget {
  const _PlanPickerSheet({required this.state, required this.date});

  final MyMenuState state;
  final DateTime date;

  @override
  State<_PlanPickerSheet> createState() => _PlanPickerSheetState();
}

class _PlanPickerSheetState extends State<_PlanPickerSheet> {
  String? _selectedDishId = 'dish_salmon';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final List<Dish> dishes = widget.state.dishes.where((Dish dish) {
      return dish.title.toLowerCase().contains(_query.toLowerCase());
    }).toList(growable: false);

    return FractionallySizedBox(
      heightFactor: 0.94,
      child: WarmPage(
        includeBottomChromeSpace: false,
        topPadding: 10,
        child: Column(
          children: <Widget>[
            SheetTopBar(
              title: 'Add to ${_weekdays[widget.date.weekday - 1]}',
              closeOnLeft: true,
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Eyebrow(
                    '${_weekdays[widget.date.weekday - 1]} · '
                    '${_months[widget.date.month - 1]} ${widget.date.day}',
                  ),
                  Text(
                    'Add another dish',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose one more from your personal menu.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey<String>('plan_dish_search'),
              onChanged: (String value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search your dishes',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: <Widget>[
                WarmPill(label: 'Suggested', selected: true),
                SizedBox(width: 8),
                WarmPill(label: 'Quick'),
                SizedBox(width: 8),
                WarmPill(label: 'Favorites'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: dishes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (BuildContext context, int index) {
                  final Dish dish = dishes[index];
                  return _DishChoice(
                    dish: dish,
                    selected: dish.id == _selectedDishId,
                    onTap: () => setState(() => _selectedDishId = dish.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            PrimaryPillButton(
              label: 'Add to ${_weekdays[widget.date.weekday - 1]}',
              icon: Icons.arrow_forward,
              onPressed: _selectedDishId == null ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    Navigator.pop(context, _selectedDishId);
  }
}

class _DishChoice extends StatelessWidget {
  const _DishChoice({
    required this.dish,
    required this.selected,
    required this.onTap,
  });

  final Dish dish;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? MyMenuColors.orangeSoft : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? MyMenuColors.orange : MyMenuColors.line,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: DishArtwork(dish: dish),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(dish.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '${dish.prepMinutes} min · Made ${dish.madeCount} times',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? MyMenuColors.orange : MyMenuColors.softInk,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const List<String> _weekdays = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
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
