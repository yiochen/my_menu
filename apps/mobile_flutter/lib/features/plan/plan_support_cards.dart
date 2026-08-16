import 'package:flutter/material.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/local_write_feedback.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class PlanSuggestionCard extends StatelessWidget {
  const PlanSuggestionCard({
    required this.state,
    required this.date,
    required this.onAdded,
    super.key,
  });

  final MyMenuState state;
  final DateTime date;
  final VoidCallback onAdded;

  @override
  Widget build(BuildContext context) {
    final Dish dish = state.recommendedDish();
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x47FF710A)),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: SizedBox(
              width: 50,
              height: 50,
              child: DishArtwork(dish: dish),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Eyebrow('Suggestion · not planned'),
                Text(
                  dish.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Made ${dish.madeCount} times · ${dish.prepMinutes} min',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          WarmPill(
            label: 'Add',
            orange: true,
            compact: true,
            onPressed: () async {
              final bool saved = await runLocalWriteWithFeedback(
                context,
                () => state.addPlannedMeal(
                  dayKeyForDate(date),
                  dish.id,
                  label: 'Dinner',
                ),
              );
              if (saved) {
                onAdded();
              }
            },
          ),
        ],
      ),
    );
  }
}

class PlanReviewCard extends StatelessWidget {
  const PlanReviewCard({
    required this.count,
    required this.onTap,
    super.key,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: WarmCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: MyMenuColors.orangeSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 18,
                color: MyMenuColors.orangeDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '$count captures need a quick look',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Help MyMenu place them right.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: MyMenuColors.softInk),
          ],
        ),
      ),
    );
  }
}
