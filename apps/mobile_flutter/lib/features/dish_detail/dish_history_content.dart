import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class DishHistoryContent extends StatelessWidget {
  const DishHistoryContent({required this.dish, super.key});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final List<_CookingOccasion> occasions = _occasionsFor(dish);
    if (occasions.isEmpty) {
      return WarmCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'No cooking history yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Ideas can live in your Menu before you cook them. Source photos '
              'will appear here after the first cooking occasion.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${occasions.length} '
          '${occasions.length == 1 ? 'time' : 'times'} made',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          '${dish.sourcePhotos.length} source '
          '${dish.sourcePhotos.length == 1 ? 'photo' : 'photos'} across '
          '${occasions.length} cooking '
          '${occasions.length == 1 ? 'occasion' : 'occasions'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        const Eyebrow('Newest first'),
        const SizedBox(height: 8),
        for (int index = 0; index < occasions.length; index += 1) ...<Widget>[
          _OccasionCard(
            occasion: occasions[index],
            cookNumber: occasions.length - index,
          ),
          if (index != occasions.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _OccasionCard extends StatelessWidget {
  const _OccasionCard({
    required this.occasion,
    required this.cookNumber,
  });

  final _CookingOccasion occasion;
  final int cookNumber;

  @override
  Widget build(BuildContext context) {
    final List<String> notes = occasion.photos
        .map((SourcePhoto photo) => photo.note?.trim())
        .whereType<String>()
        .where((String note) => note.isNotEmpty)
        .toSet()
        .toList(growable: false);
    return WarmCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _dateLabel(context, occasion),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${occasion.photos.length} source '
                      '${occasion.photos.length == 1 ? 'photo' : 'photos'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              WarmPill(label: 'Cook #$cookNumber', compact: true),
            ],
          ),
          const SizedBox(height: 11),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: occasion.photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: AppImage(
                    imageRef: occasion.photos[index].url,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          if (notes.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(notes.first, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  String _dateLabel(BuildContext context, _CookingOccasion occasion) {
    final DateTime? capturedAt = occasion.capturedAt;
    if (capturedAt != null) {
      return MaterialLocalizations.of(context).formatMediumDate(capturedAt);
    }
    return occasion.photos.first.capturedLabel;
  }
}

class _CookingOccasion {
  const _CookingOccasion({
    required this.photos,
    required this.capturedAt,
  });

  final List<SourcePhoto> photos;
  final DateTime? capturedAt;
}

List<_CookingOccasion> _occasionsFor(Dish dish) {
  final Map<String, List<SourcePhoto>> grouped = <String, List<SourcePhoto>>{};
  for (int index = 0; index < dish.sourcePhotos.length; index += 1) {
    final SourcePhoto photo = dish.sourcePhotos[index];
    final String key =
        photo.cookingOccasionId ?? photo.id ?? 'source-photo-$index';
    grouped.putIfAbsent(key, () => <SourcePhoto>[]).add(photo);
  }
  final List<_CookingOccasion> occasions = grouped.values.map((
    List<SourcePhoto> photos,
  ) {
    final List<DateTime> dates = photos
        .map((SourcePhoto photo) => photo.capturedAt)
        .whereType<DateTime>()
        .toList(growable: false)
      ..sort();
    return _CookingOccasion(
      photos: photos,
      capturedAt: dates.isEmpty ? null : dates.last,
    );
  }).toList(growable: false)
    ..sort((_CookingOccasion left, _CookingOccasion right) {
      final DateTime leftDate =
          left.capturedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime rightDate =
          right.capturedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return rightDate.compareTo(leftDate);
    });
  return occasions;
}
