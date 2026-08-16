import 'package:flutter/material.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
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
  final Set<String>? dishIds = await showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PlanPickerSheet(state: state, date: date),
  );
  if (dishIds != null && context.mounted) {
    await runLocalWriteWithFeedback(
      context,
      () => state.replacePlannedDishesForDay(
        dayKeyForDate(date),
        dishIds,
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
  late final Set<String> _selectedDishIds;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedDishIds = widget.state
        .plannedMealsForDay(dayKeyForDate(widget.date))
        .map((PlannedMeal meal) => meal.dishId)
        .toSet();
  }

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
                    'Choose dishes',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select everything you want to cook that day.',
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
            _selectionSummary(context),
            const SizedBox(height: 4),
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
                    selected: _selectedDishIds.contains(dish.id),
                    onTap: () => setState(() {
                      if (!_selectedDishIds.add(dish.id)) {
                        _selectedDishIds.remove(dish.id);
                      }
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            PrimaryPillButton(
              key: const ValueKey<String>('plan_save_dishes'),
              label: 'Save ${_weekdays[widget.date.weekday - 1]}',
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    Navigator.pop(context, Set<String>.unmodifiable(_selectedDishIds));
  }

  Widget _selectionSummary(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          '${_selectedDishIds.length} selected',
          key: const ValueKey<String>('plan_selected_dish_count'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const Spacer(),
        TextButton(
          key: const ValueKey<String>('plan_clear_all_dishes'),
          onPressed: _selectedDishIds.isEmpty
              ? null
              : () => setState(_selectedDishIds.clear),
          child: const Text('Clear all'),
        ),
      ],
    );
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
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
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
                      Text(
                        dish.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${dish.prepMinutes} min · '
                        'Made ${dish.madeCount} times',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? MyMenuColors.orange : MyMenuColors.softInk,
                ),
              ],
            ),
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
