import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/shared/widgets/app_image.dart';

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
    final List<_JournalEntry> entries = _journalEntriesFor(dish);
    if (entries.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _JournalActions(onAddPhoto: onAddPhoto, onAddNote: onAddNote),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
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
        for (int index = 0; index < entries.length; index += 1) ...<Widget>[
          if (entries[index].photoGroup case final _PhotoGroup photoGroup)
            _InstantPhotoPost(
              photoGroup: photoGroup,
              clockwise: index.isOdd,
            )
          else
            _BulletinNote(note: entries[index].note!),
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
    required this.photoGroup,
    required this.clockwise,
  });

  final _PhotoGroup photoGroup;
  final bool clockwise;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: clockwise ? 0.012 : -0.014,
      child: Container(
        key: ValueKey<String>(
          'journal_photo_${photoGroup.photos.first.id ?? photoGroup.photos.first.url}',
        ),
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
                  imageRef: photoGroup.photos.first.url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (photoGroup.photos.length > 1) ...<Widget>[
              const SizedBox(height: 8),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: photoGroup.photos.length - 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 7),
                  itemBuilder: (BuildContext context, int index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AppImage(
                        imageRef: photoGroup.photos[index + 1].url,
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
              _dateLabel(context, photoGroup),
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
        key: ValueKey<String>('dish_note_${note.id}'),
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

class _PhotoGroup {
  const _PhotoGroup({
    required this.photos,
    required this.capturedAt,
    required this.addedAt,
  });

  final List<SourcePhoto> photos;
  final DateTime? capturedAt;
  final DateTime? addedAt;
}

class _JournalEntry {
  const _JournalEntry({
    required this.addedAt,
    required this.sequence,
    this.photoGroup,
    this.note,
  });

  final DateTime? addedAt;
  final int sequence;
  final _PhotoGroup? photoGroup;
  final DishNote? note;
}

List<_JournalEntry> _journalEntriesFor(Dish dish) {
  final List<_PhotoGroup> photoGroups = _photoGroupsFor(dish);
  final List<_JournalEntry> entries = <_JournalEntry>[
    for (int index = 0; index < photoGroups.length; index += 1)
      _JournalEntry(
        photoGroup: photoGroups[index],
        addedAt: photoGroups[index].addedAt,
        sequence: index,
      ),
    for (int index = 0; index < dish.notes.length; index += 1)
      _JournalEntry(
        note: dish.notes[index],
        addedAt: dish.notes[index].createdAt,
        sequence: photoGroups.length + index,
      ),
  ]..sort((_JournalEntry left, _JournalEntry right) {
      final DateTime? leftDate = left.addedAt;
      final DateTime? rightDate = right.addedAt;
      if (leftDate != null && rightDate != null) {
        final int dateOrder = rightDate.compareTo(leftDate);
        if (dateOrder != 0) return dateOrder;
      } else if (leftDate != null) {
        return -1;
      } else if (rightDate != null) {
        return 1;
      }
      return right.sequence.compareTo(left.sequence);
    });
  return entries;
}

List<_PhotoGroup> _photoGroupsFor(Dish dish) {
  final Map<String, List<SourcePhoto>> grouped = <String, List<SourcePhoto>>{};
  for (int index = 0; index < dish.sourcePhotos.length; index += 1) {
    final SourcePhoto photo = dish.sourcePhotos[index];
    final String key = photo.ingestId ??
        photo.id ??
        photo.captureId ??
        'ungrouped-source-$index';
    grouped.putIfAbsent(key, () => <SourcePhoto>[]).add(photo);
  }
  final List<_PhotoGroup> photoGroups = grouped.values.map((
    List<SourcePhoto> photos,
  ) {
    final List<DateTime> dates = photos
        .map((SourcePhoto photo) => photo.capturedAt)
        .whereType<DateTime>()
        .toList(growable: false)
      ..sort();
    final List<DateTime> addedDates = photos
        .map((SourcePhoto photo) => photo.addedAt)
        .whereType<DateTime>()
        .toList(growable: false)
      ..sort();
    return _PhotoGroup(
      photos: photos,
      capturedAt: dates.isEmpty ? null : dates.last,
      addedAt: addedDates.isNotEmpty
          ? addedDates.last
          : dates.isEmpty
              ? null
              : dates.last,
    );
  }).toList(growable: false)
    ..sort((_PhotoGroup left, _PhotoGroup right) {
      final DateTime leftDate =
          left.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime rightDate =
          right.addedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return rightDate.compareTo(leftDate);
    });
  return photoGroups;
}

String _dateLabel(BuildContext context, _PhotoGroup photoGroup) {
  final DateTime? capturedAt = photoGroup.capturedAt;
  if (capturedAt != null) {
    return MaterialLocalizations.of(context).formatMediumDate(capturedAt);
  }
  return photoGroup.photos.first.capturedLabel;
}
