import 'package:flutter/material.dart';

import 'package:mymenu/domain/covers/generated_cover.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class CoverHistorySelection extends StatelessWidget {
  const CoverHistorySelection({
    required this.state,
    required this.dishId,
    required this.horizontalPadding,
    required this.onDone,
    super.key,
  });

  final MyMenuState state;
  final String dishId;
  final double horizontalPadding;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final Dish dish = state.dishById(dishId);
    final List<GeneratedCover> covers = state.coverHistoryForDish(dishId);
    return ListView(
      key: const ValueKey<String>('existing_cover_scroll_view'),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        16,
        horizontalPadding,
        28,
      ),
      children: <Widget>[
        Text(
          'Generated covers',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
            'Every generated cover stays on this device unless you delete the Dish.',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 14),
        if (covers.isEmpty)
          const StatusStrip(
              icon: Icons.photo_library_outlined,
              text: 'No generated covers yet.')
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: covers.map((GeneratedCover cover) {
              return _CoverTile(
                imageRef: cover.thumbnailPath ?? cover.localPath,
                label: cover.state == GeneratedCoverState.current
                    ? 'Current'
                    : cover.state == GeneratedCoverState.proposed
                        ? 'Proposed'
                        : 'Previous',
                onTap: () async {
                  await state.selectGeneratedCover(cover.id);
                  if (context.mounted) onDone();
                },
                onDelete: () async {
                  await state.deleteGeneratedCover(cover.id);
                  if (context.mounted) onDone();
                },
              );
            }).toList(growable: false),
          ),
        if (dish.sourcePhotos.isNotEmpty) ...<Widget>[
          const SizedBox(height: 24),
          Text('Choose from Sources',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: dish.sourcePhotos.map((SourcePhoto source) {
              return _CoverTile(
                imageRef: source.thumbnailUrl ?? source.url,
                label: source.capturedLabel,
                onTap: source.id == null
                    ? null
                    : () async {
                        await state.selectSourceAsCover(dishId, source.id!);
                        if (context.mounted) onDone();
                      },
              );
            }).toList(growable: false),
          ),
        ],
      ],
    );
  }
}

class _CoverTile extends StatelessWidget {
  const _CoverTile({
    required this.imageRef,
    required this.label,
    this.onTap,
    this.onDelete,
  });
  final String imageRef;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 142,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: 142,
                      height: 142,
                      child: AppImage(
                        imageRef: imageRef,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (onDelete != null)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: IconButton.filledTonal(
                        tooltip: 'Delete generated cover',
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
}
