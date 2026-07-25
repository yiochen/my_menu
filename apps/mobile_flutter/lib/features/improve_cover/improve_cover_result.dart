import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class ImproveCoverResult extends StatelessWidget {
  const ImproveCoverResult({
    required this.dish,
    required this.onUseCover,
    required this.onKeepCurrent,
    super.key,
  });

  final Dish dish;
  final VoidCallback onUseCover;
  final VoidCallback onKeepCurrent;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.94,
      child: WarmPage(
        includeBottomChromeSpace: false,
        topPadding: 10,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: <Widget>[
                      const SheetTopBarPlaceholder(
                        title: 'Choose the cover image',
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Eyebrow('Ready to compare'),
                            Text(
                              'Which feels more like your menu?',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'The proposed cover is inspired by three real '
                              'source photos. Those originals stay untouched.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _CoverOption(
                              dish: dish,
                              label: 'Current cover',
                              selected: false,
                              improved: false,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _CoverOption(
                              dish: dish,
                              label: '✨ Proposed cover',
                              selected: true,
                              improved: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      WarmCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            _SafetyLine(
                              text: '${dish.sourcePhotos.length} source photos '
                                  'and ${dish.madeCount} cooking occasions stay '
                                  'unchanged.',
                            ),
                            const SizedBox(height: 10),
                            const _SafetyLine(
                              text: 'The current cover remains available until '
                                  'you confirm.',
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      PrimaryPillButton(
                        label: 'Use this cover',
                        icon: Icons.arrow_forward,
                        onPressed: onUseCover,
                      ),
                      const SizedBox(height: 10),
                      PrimaryPillButton(
                        label: 'Keep current cover',
                        onPressed: onKeepCurrent,
                        backgroundColor: MyMenuColors.oat,
                        foregroundColor: MyMenuColors.ink,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SheetTopBarPlaceholder extends StatelessWidget {
  const SheetTopBarPlaceholder({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      ),
    );
  }
}

class _CoverOption extends StatelessWidget {
  const _CoverOption({
    required this.dish,
    required this.label,
    required this.selected,
    required this.improved,
  });

  final Dish dish;
  final String label;
  final bool selected;
  final bool improved;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(selected ? 6 : 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: selected ? MyMenuColors.orange : MyMenuColors.line,
          width: selected ? 2 : 1,
        ),
        boxShadow: myMenuCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: MediaQuery.sizeOf(context).width <= 400 ? 170 : 185,
              child: DishArtwork(dish: dish, improved: improved),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 9, 4, 4),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyLine extends StatelessWidget {
  const _SafetyLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(Icons.check, size: 17, color: MyMenuColors.green),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
