import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class DishHistoryContent extends StatelessWidget {
  const DishHistoryContent({
    required this.dish,
    this.onAddPhoto,
    this.onAddNote,
    super.key,
  });

  final Dish dish;
  final VoidCallback? onAddPhoto;
  final VoidCallback? onAddNote;

  @override
  Widget build(BuildContext context) {
    final List<_CookingOccasion> occasions = _occasionsFor(dish);
    if (occasions.isEmpty && dish.notes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _JournalActions(onAddPhoto: onAddPhoto, onAddNote: onAddNote),
          const SizedBox(height: 12),
          WarmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'No journal entries yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Ideas can live in your Menu before you cook them. Photos '
                  'and notes will collect here over time.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _JournalActions(onAddPhoto: onAddPhoto, onAddNote: onAddNote),
        const SizedBox(height: 18),
        for (int index = 0; index < occasions.length; index += 1) ...<Widget>[
          _InstantPhotoPost(
            occasion: occasions[index],
            notes: _notesForOccasion(dish, occasions[index], index),
            clockwise: index.isOdd,
          ),
          const SizedBox(height: 18),
        ],
        for (int index = occasions.length;
            index < dish.notes.length;
            index += 1) ...<Widget>[
          _BulletinNote(note: dish.notes[index]),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _JournalActions extends StatelessWidget {
  const _JournalActions({required this.onAddPhoto, required this.onAddNote});

  final VoidCallback? onAddPhoto;
  final VoidCallback? onAddNote;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        IconButton.filledTonal(
          key: const ValueKey<String>('journal_add_photo'),
          tooltip: 'Add photo',
          onPressed: onAddPhoto,
          icon: const Icon(Icons.add_photo_alternate_outlined),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          key: const ValueKey<String>('journal_add_note'),
          tooltip: 'Add note',
          onPressed: onAddNote,
          icon: const Icon(Icons.note_add_outlined),
        ),
      ],
    );
  }
}

class _InstantPhotoPost extends StatelessWidget {
  const _InstantPhotoPost({
    required this.occasion,
    required this.notes,
    required this.clockwise,
  });

  final _CookingOccasion occasion;
  final List<String> notes;
  final bool clockwise;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: clockwise ? 0.012 : -0.014,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFEFA),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x21302318),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.08,
              child: ClipRect(
                child: AppImage(
                  imageRef: occasion.photos.first.url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (occasion.photos.length > 1) ...<Widget>[
              const SizedBox(height: 8),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: occasion.photos.length - 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 7),
                  itemBuilder: (BuildContext context, int index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AppImage(
                        imageRef: occasion.photos[index + 1].url,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              _dateLabel(context, occasion),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            for (final String note in notes) ...<Widget>[
              const SizedBox(height: 7),
              Text(
                note,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MyMenuColors.ink,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BulletinNote extends StatelessWidget {
  const _BulletinNote({required this.note});

  final DishNote note;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.01,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 22),
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF2B9),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x1F4F3D14),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Text(note.body, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

class _CookingOccasion {
  const _CookingOccasion({required this.photos, required this.capturedAt});

  final List<SourcePhoto> photos;
  final DateTime? capturedAt;
}

List<_CookingOccasion> _occasionsFor(Dish dish) {
  final Map<String, List<SourcePhoto>> grouped = <String, List<SourcePhoto>>{};
  for (int index = 0; index < dish.sourcePhotos.length; index += 1) {
    final SourcePhoto photo = dish.sourcePhotos[index];
    final String key = photo.cookingOccasionId ??
        photo.capturedLabel.trim().toLowerCase().replaceAll(' ', '-');
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

List<String> _notesForOccasion(
  Dish dish,
  _CookingOccasion occasion,
  int index,
) {
  final Set<String> notes = occasion.photos
      .map((SourcePhoto photo) => photo.note?.trim())
      .whereType<String>()
      .where((String note) => note.isNotEmpty)
      .toSet();
  if (index < dish.notes.length) {
    notes.add(dish.notes[index].body);
  }
  return notes.toList(growable: false);
}

String _dateLabel(BuildContext context, _CookingOccasion occasion) {
  final DateTime? capturedAt = occasion.capturedAt;
  if (capturedAt != null) {
    return MaterialLocalizations.of(context).formatMediumDate(capturedAt);
  }
  return occasion.photos.first.capturedLabel;
}
