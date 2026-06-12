import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({required this.onOpenReview, super.key});

  final VoidCallback onOpenReview;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final Dish recommendedDish = state.recommendedDish();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: <Widget>[
        _PlanHeader(onOpenReview: onOpenReview),
        const SizedBox(height: 20),
        _WeekCard(plan: state.plan),
        const SizedBox(height: 20),
        _CookTonightCard(dish: recommendedDish),
        if (state.reviewItems.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          _ReviewCard(
            count: state.reviewItems.length,
            onTap: onOpenReview,
          ),
        ],
      ],
    );
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({required this.onOpenReview});

  final VoidCallback onOpenReview;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Plan', style: Theme.of(context).textTheme.labelLarge),
              Text(
                'What are we cooking this week?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onOpenReview,
          icon: Badge(
            isLabelVisible: state.reviewItems.isNotEmpty,
            label: Text(state.reviewItems.length.toString()),
            child: const Icon(Icons.fact_check_outlined),
          ),
        ),
      ],
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.plan});

  final List<PlannedMeal> plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('This Week', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final PlannedMeal meal in plan) ...<Widget>[
              _PlanRow(meal: meal),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.meal});

  final PlannedMeal meal;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final Dish? dish =
        meal.dishId == null ? null : state.dishById(meal.dishId!);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openPlanDialog(context, state, meal),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EFE7),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 44,
              child: Text(
                meal.label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: Text(
                dish?.title ?? 'Choose a dish later',
                style: dish == null
                    ? Theme.of(context).textTheme.bodyMedium
                    : Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPlanDialog(
    BuildContext context,
    MyMenuState state,
    PlannedMeal meal,
  ) async {
    String selectedDishId = meal.dishId ?? state.dishes.first.id;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setDialogState,
          ) {
            return AlertDialog(
              title: Text('Plan ${meal.label}'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: state.dishes.map((Dish dish) {
                    return RadioListTile<String>(
                      value: dish.id,
                      groupValue: selectedDishId,
                      title: Text(dish.title),
                      subtitle:
                          Text('${dish.prepMinutes} min · ${dish.category}'),
                      onChanged: (String? value) {
                        if (value != null) {
                          setDialogState(() => selectedDishId = value);
                        }
                      },
                    );
                  }).toList(growable: false),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    state.planDish(meal.dayKey, selectedDishId);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Plan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _CookTonightCard extends StatelessWidget {
  const _CookTonightCard({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFE8F2FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                DishDetailScreen(dishId: dish.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Cook Tonight',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                dish.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('${dish.prepMinutes} min · Last made ${dish.lastMadeLabel}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF0D9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ListTile(
        title: Text('$count capture needs review'),
        subtitle: const Text('Help the app confirm a dish match.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
