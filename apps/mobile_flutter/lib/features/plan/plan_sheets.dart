import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';
import 'package:mymenu/features/plan/plan_sheet_action_row.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

Future<void> showPlanPickerSheet(
  BuildContext context,
  MyMenuState state, {
  required DateTime date,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PlanPickerSheet(state: state, date: date),
  );
}

Future<void> showPlanActionsSheet(
  BuildContext context,
  MyMenuState state, {
  required PlannedMeal meal,
  required DateTime currentDate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => _PlanActionsSheet(
      state: state,
      meal: meal,
      currentDate: currentDate,
    ),
  );
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
    widget.state.addPlannedMeal(
      dayKeyForDate(widget.date),
      _selectedDishId!,
      label: 'Dinner',
    );
    Navigator.pop(context);
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

class _PlanActionsSheet extends StatelessWidget {
  const _PlanActionsSheet({
    required this.state,
    required this.meal,
    required this.currentDate,
  });

  final MyMenuState state;
  final PlannedMeal meal;
  final DateTime currentDate;

  @override
  Widget build(BuildContext context) {
    final Dish dish = state.dishById(meal.dishId);
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: WarmPage(
        includeBottomChromeSpace: false,
        topPadding: 10,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SheetTopBar(
              title: 'Planned dish',
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            WarmCard(
              padding: const EdgeInsets.all(16),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(dish.title,
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          '${_weekdays[currentDate.weekday - 1]}, '
                          '${_months[currentDate.month - 1]} ${currentDate.day} '
                          '· ${meal.label ?? 'Dinner'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            WarmCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  PlanSheetActionRow(
                    icon: Icons.redo_rounded,
                    title: 'Move to another day',
                    subtitle: 'Keep it planned, change the date',
                    onTap: () => _move(context),
                  ),
                  PlanSheetActionRow(
                    icon: Icons.open_in_new_rounded,
                    title: 'Open dish',
                    subtitle: 'Recipe, notes, and history',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DishDetailScreen(dishId: dish.id),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  PlanSheetActionRow(
                    icon: Icons.remove_circle_outline,
                    title: 'Remove from plan',
                    subtitle: 'The dish stays in your menu',
                    destructive: true,
                    showChevron: false,
                    onTap: () => _remove(context, dish),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const StatusStrip(
              icon: Icons.info_outline,
              text: 'Removing a plan never deletes the dish or its history.',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _move(BuildContext context) async {
    final DateTime? target = await showDatePicker(
      context: context,
      initialDate: currentDate.add(const Duration(days: 1)),
      firstDate: DateTime(2026, 7, 20),
      lastDate: DateTime(2026, 8, 31),
    );
    if (target == null || !context.mounted) {
      return;
    }
    state.movePlannedMeal(
      meal.id,
      targetDayKey: dayKeyForDate(target),
      targetIndex: 0,
    );
    Navigator.pop(context);
  }

  void _remove(BuildContext context, Dish dish) {
    final String previousDayKey = meal.dayKey;
    state.removePlannedMeal(meal.id);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 98),
        backgroundColor: Colors.white,
        content: Text(
          '${dish.title} removed',
          style: const TextStyle(color: MyMenuColors.ink),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: MyMenuColors.orangeDark,
          onPressed: () => state.addPlannedMeal(
            previousDayKey,
            meal.dishId,
            label: meal.label,
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
