import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';
import 'package:mymenu/features/plan/plan_sheets.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class PlanSelectedDay extends StatelessWidget {
  const PlanSelectedDay({
    required this.date,
    required this.meals,
    required this.state,
    required this.onAdd,
    required this.onChanged,
    super.key,
  });

  final DateTime date;
  final List<PlannedMeal> meals;
  final MyMenuState state;
  final VoidCallback onAdd;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return WarmCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          _SelectedDayHeader(date: date, count: meals.length),
          const SizedBox(height: 10),
          if (meals.isEmpty)
            _EmptyDay(date: date, onAdd: onAdd)
          else ...<Widget>[
            for (final PlannedMeal meal in meals) ...<Widget>[
              _PlanMealRow(
                meal: meal,
                dish: state.dishById(meal.dishId),
                onTap: () => _openDish(context, meal.dishId),
                onMore: () async {
                  await showPlanActionsSheet(
                    context,
                    state,
                    meal: meal,
                    currentDate: date,
                  );
                  onChanged();
                },
              ),
              const SizedBox(height: 10),
            ],
            PrimaryPillButton(
              label: '+ Add another dish',
              onPressed: onAdd,
              backgroundColor: MyMenuColors.orangeSoft,
              foregroundColor: MyMenuColors.orangeDark,
            ),
          ],
        ],
      ),
    );
  }

  void _openDish(BuildContext context, String dishId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DishDetailScreen(dishId: dishId),
      ),
    );
  }
}

class _SelectedDayHeader extends StatelessWidget {
  const _SelectedDayHeader({required this.date, required this.count});

  final DateTime date;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Eyebrow(_isSampleToday(date) ? 'Today' : 'Selected day'),
              const SizedBox(height: 2),
              Text(
                _longDate(date),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 2),
              Text(
                count == 0
                    ? 'Nothing planned yet'
                    : '$count ${count == 1 ? 'dish' : 'dishes'} planned',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (_isSampleToday(date))
          const WarmPill(label: 'Tonight', orange: true),
      ],
    );
  }
}

class _PlanMealRow extends StatelessWidget {
  const _PlanMealRow({
    required this.meal,
    required this.dish,
    required this.onTap,
    required this.onMore,
  });

  final PlannedMeal meal;
  final Dish dish;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey<String>('planned_meal_${meal.id}'),
      color: const Color(0xFFF7F4EF),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 74),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      dish.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${meal.label ?? 'Dinner'} · ${dish.prepMinutes} min',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onMore,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  fixedSize: const Size(34, 34),
                ),
                icon: const Icon(Icons.more_horiz_rounded, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.date, required this.onAdd});

  final DateTime date;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
      child: Column(
        children: <Widget>[
          const _EmptyPlate(size: 112),
          const SizedBox(height: 6),
          Text(
            '${_weekdays[date.weekday - 1]} is wide open',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Choose one dish or make it a feast.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 170,
            child: PrimaryPillButton(
              label: 'Add a dish',
              icon: Icons.add,
              onPressed: onAdd,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlate extends StatelessWidget {
  const _EmptyPlate({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
              width: size * 0.72,
              height: size * 0.72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: MyMenuColors.oat2,
                  width: size * 0.085,
                ),
                boxShadow: myMenuCardShadow,
              ),
            ),
          ),
          const Positioned(
            right: 4,
            top: 4,
            child: Icon(Icons.auto_awesome, color: MyMenuColors.orange),
          ),
        ],
      ),
    );
  }
}

bool _isSampleToday(DateTime date) {
  return date.year == 2026 && date.month == 7 && date.day == 22;
}

String _longDate(DateTime date) {
  return '${_weekdays[date.weekday - 1]}, '
      '${_months[date.month - 1]} ${date.day}';
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
