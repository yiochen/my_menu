import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class DishHistoryContent extends StatelessWidget {
  const DishHistoryContent({required this.dish, super.key});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${dish.madeCount} times made',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          '${dish.sourcePhotos.length} source photos across '
          '${dish.madeCount} cooking occasions',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        const Eyebrow('Latest'),
        const SizedBox(height: 8),
        _OccasionCard(
          dish: dish,
          date: 'July 18, 2026',
          meta: '3 photos · Dinner',
          cookLabel: 'Cook #8',
          note:
              '“Broil for the last 2 minutes—the crispy edges made it way better.”',
          photoCount: 3,
        ),
        const SizedBox(height: 10),
        _OccasionCard(
          dish: dish,
          date: 'May 9, 2026',
          meta: '2 photos · Family dinner',
          cookLabel: 'Cook #7',
          note:
              'Kids liked this glaze. Keep the chili crisp on the table next time.',
          photoCount: 2,
        ),
        const SizedBox(height: 10),
        const StatusStrip(
          icon: Icons.history,
          text: '6 earlier cooking occasions contain 7 more photos.',
        ),
      ],
    );
  }
}

class _OccasionCard extends StatelessWidget {
  const _OccasionCard({
    required this.dish,
    required this.date,
    required this.meta,
    required this.cookLabel,
    required this.note,
    required this.photoCount,
  });

  final Dish dish;
  final String date;
  final String meta;
  final String cookLabel;
  final String note;
  final int photoCount;

  @override
  Widget build(BuildContext context) {
    return WarmCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(date, style: Theme.of(context).textTheme.titleMedium),
                    Text(meta, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              WarmPill(label: cookLabel, compact: true),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: List<Widget>.generate(
              photoCount,
              (int index) => Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: index == photoCount - 1 ? 0 : 7),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: DishArtwork(dish: dish),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(note, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
