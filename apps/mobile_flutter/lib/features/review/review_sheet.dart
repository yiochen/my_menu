import 'package:flutter/material.dart';

import 'package:mymenu/domain/capture/review_item.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/shared/widgets/animated_state_sheet.dart';
import 'package:mymenu/shared/widgets/app_image.dart';

Future<void> showReviewSheet(
  BuildContext context,
  MyMenuState state,
) async {
  await showAnimatedStateSheet(
    context,
    animation: state,
    heightFactor: 0.75,
    builder: (BuildContext context) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: <Widget>[
          Text(
            'Review Queue',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          if (state.reviewItems.isEmpty)
            const Text('Nothing needs review right now.')
          else
            for (final ReviewItem item in state.reviewItems) ...<Widget>[
              _ReviewCard(item: item, state: state),
              const SizedBox(height: 12),
            ],
        ],
      );
    },
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.item,
    required this.state,
  });

  final ReviewItem item;
  final MyMenuState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              item.summary,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (item.imageRef != null) ...<Widget>[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AppImage(
                  imageRef: item.imageRef!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text('Confidence ${item.confidenceLabel}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.suggestedDishIds.map((String dishId) {
                final Dish dish = state.dishById(dishId);
                return ActionChip(
                  label: Text(dish.title),
                  onPressed: () => state.resolveReviewToDish(item.id, dishId),
                );
              }).toList(growable: false),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => state.createDishFromReview(item.id),
              child: const Text('Create new dish'),
            ),
          ],
        ),
      ),
    );
  }
}
