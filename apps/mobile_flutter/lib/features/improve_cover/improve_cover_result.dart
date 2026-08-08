import 'package:flutter/material.dart';

import 'package:mymenu/domain/covers/generated_cover.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class ImproveCoverResult extends StatelessWidget {
  const ImproveCoverResult({
    required this.dish,
    required this.proposal,
    required this.onUseCover,
    required this.onTryAnother,
    required this.onKeepCurrent,
    super.key,
  });

  final Dish dish;
  final GeneratedCover proposal;
  final VoidCallback onUseCover;
  final VoidCallback onTryAnother;
  final VoidCallback onKeepCurrent;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.94,
      child: WarmPage(
        includeBottomChromeSpace: false,
        topPadding: 18,
        child: ListView(
          children: <Widget>[
            const Eyebrow('Ready to compare'),
            Text('Choose the cover image',
                style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                    child: _CoverOption(
                        label: 'Current cover',
                        child: DishArtwork(dish: dish))),
                const SizedBox(width: 10),
                Expanded(
                    child: _CoverOption(
                        label: 'Proposed cover',
                        selected: true,
                        child: AppImage(
                            imageRef: proposal.localPath, fit: BoxFit.cover))),
              ],
            ),
            const SizedBox(height: 16),
            const StatusStrip(
                icon: Icons.check_circle_outline,
                text:
                    'Your current cover and every generated version remain available in Change cover.'),
            const SizedBox(height: 18),
            PrimaryPillButton(
                key: const ValueKey<String>('use_cover_button'),
                label: 'Use this cover',
                icon: Icons.arrow_forward,
                onPressed: onUseCover),
            const SizedBox(height: 10),
            PrimaryPillButton(
                label: 'Try another',
                onPressed: onTryAnother,
                backgroundColor: MyMenuColors.oat,
                foregroundColor: MyMenuColors.ink),
            const SizedBox(height: 10),
            TextButton(
                onPressed: onKeepCurrent,
                child: const Text('Keep current cover')),
          ],
        ),
      ),
    );
  }
}

class _CoverOption extends StatelessWidget {
  const _CoverOption(
      {required this.label, required this.child, this.selected = false});
  final String label;
  final Widget child;
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
              color: selected ? MyMenuColors.orange : MyMenuColors.line,
              width: selected ? 2 : 1),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(height: 180, child: child)),
              Padding(
                  padding: const EdgeInsets.all(7),
                  child: Text(label,
                      style: Theme.of(context).textTheme.labelLarge)),
            ]),
      );
}
