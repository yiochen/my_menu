import 'package:flutter/material.dart';

import 'package:mymenu/domain/covers/generated_cover.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/features/improve_cover/improve_cover_treatment_picker.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class ImproveCoverSelection extends StatelessWidget {
  const ImproveCoverSelection({
    required this.dish,
    required this.selectedSourceIds,
    required this.treatment,
    required this.autoScrollToTreatment,
    required this.onToggleSource,
    required this.onTreatmentChanged,
    required this.onGenerate,
    required this.coverAllowanceRemaining,
    required this.horizontalPadding,
    super.key,
  });

  final Dish dish;
  final Set<String> selectedSourceIds;
  final CoverTreatment treatment;
  final bool autoScrollToTreatment;
  final ValueChanged<String> onToggleSource;
  final ValueChanged<CoverTreatment> onTreatmentChanged;
  final VoidCallback? onGenerate;
  final int? coverAllowanceRemaining;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('improve_cover_scroll_view'),
      padding: const EdgeInsets.only(top: 16, bottom: 28),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Eyebrow('Make it menu-worthy'),
              Text(
                dish.sourcePhotos.isEmpty
                    ? 'Create a cover from your dish'
                    : 'Choose up to three Sources',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 7),
              Text(
                dish.sourcePhotos.isEmpty
                    ? 'MyMenu uses the title and standalone Notes as visual context.'
                    : 'Your originals stay unchanged. The title and all standalone Notes are also used when they help describe appearance.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              _CurrentCover(dish: dish),
              if (dish.sourcePhotos.isNotEmpty) ...<Widget>[
                const SizedBox(height: 18),
                Text(
                  '${selectedSourceIds.length} of ${dish.sourcePhotos.length} selected',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: dish.sourcePhotos.map((SourcePhoto source) {
                    final String? id = source.id;
                    if (id == null) return const SizedBox.shrink();
                    final bool selected = selectedSourceIds.contains(id);
                    return _SourceChoice(
                      source: source,
                      selected: selected,
                      enabled: selected || selectedSourceIds.length < 3,
                      onTap: () => onToggleSource(id),
                    );
                  }).toList(growable: false),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
        ImproveCoverTreatmentSection(
          treatment: treatment,
          autoScrollToSelection: autoScrollToTreatment,
          horizontalPadding: horizontalPadding,
          onChanged: onTreatmentChanged,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            18,
            horizontalPadding,
            0,
          ),
          child: Column(
            children: <Widget>[
              StatusStrip(
                icon: Icons.image_outlined,
                text: coverAllowanceRemaining == null
                    ? 'Cover allowance unavailable offline'
                    : '$coverAllowanceRemaining of 10 Cover generations remaining',
              ),
              const SizedBox(height: 10),
              const StatusStrip(
                icon: Icons.auto_awesome,
                text: 'No freeform prompt is sent. Nonvisual Note details '
                    'are ignored.',
              ),
              const SizedBox(height: 14),
              PrimaryPillButton(
                key: const ValueKey<String>('generate_cover_button'),
                label: 'Generate new cover',
                icon: Icons.arrow_forward,
                onPressed: onGenerate,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CurrentCover extends StatelessWidget {
  const _CurrentCover({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return WarmCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child:
                SizedBox(width: 76, height: 76, child: DishArtwork(dish: dish)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('CURRENT COVER',
                    style: Theme.of(context).textTheme.labelSmall),
                Text(dish.title,
                    style: Theme.of(context).textTheme.titleMedium),
                Text('Stays active until you choose a replacement',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.check, color: MyMenuColors.green),
        ],
      ),
    );
  }
}

class _SourceChoice extends StatelessWidget {
  const _SourceChoice({
    required this.source,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final SourcePhoto source;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: MyMenuColors.oat,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? MyMenuColors.orange : Colors.transparent,
            width: 3,
          ),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Opacity(
                opacity: enabled ? 1 : 0.45,
                child: AppImage(
                    imageRef: source.thumbnailUrl ?? source.url,
                    fit: BoxFit.cover),
              ),
              if (selected)
                const Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: MyMenuColors.orange,
                    child: Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
