import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class ImproveCoverGenerating extends StatelessWidget {
  const ImproveCoverGenerating({
    required this.dish,
    required this.onClose,
    super.key,
  });

  final Dish dish;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return _StatusPage(
      title: 'Improve cover image',
      onClose: onClose,
      art: _DishStatusArt(dish: dish, pulsing: true),
      eyebrow: 'Creating a new cover',
      headline: 'Plating it up…',
      description:
          'Using three source photos to make something more menu-worthy.',
      card: Column(
        children: <Widget>[
          const LinearProgressIndicator(
            value: 0.72,
            color: MyMenuColors.orange,
            backgroundColor: MyMenuColors.oat2,
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              const Expanded(child: Text('Generating details and light')),
              Text('About 8 sec', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const Divider(height: 28),
          const _CheckLine(text: 'Original source photos unchanged'),
          const SizedBox(height: 10),
          const _CheckLine(text: 'Current cover remains active'),
        ],
      ),
      footer: const StatusStrip(
        icon: Icons.open_in_new,
        text: 'You can close this screen. We’ll show the proposed cover '
            'when it’s ready.',
      ),
      actionLabel: 'Generating cover…',
      action: null,
    );
  }
}

class ImproveCoverOffline extends StatelessWidget {
  const ImproveCoverOffline({
    required this.dish,
    required this.onClose,
    required this.onRetry,
    super.key,
  });

  final Dish dish;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _StatusPage(
      title: 'Improve cover',
      onClose: onClose,
      art: const _IconStatusArt(icon: Icons.cloud_off_outlined),
      eyebrow: 'You’re offline',
      headline: 'Your dish is still right here',
      description: 'Cover improvements need a connection, but you can keep '
          'viewing and editing everything saved on this device.',
      card: Column(
        children: <Widget>[
          _DishSafeRow(
            dish: dish,
            subtitle: 'Current cover is safe',
          ),
          const Divider(height: 24),
          const _CheckLine(text: 'Recipe, notes, and sources available'),
          const SizedBox(height: 10),
          const _CheckLine(text: 'New local edits will save normally'),
        ],
      ),
      footer: WarmCard(
        padding: const EdgeInsets.all(16),
        color: MyMenuColors.oat,
        shadow: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Want us to remember?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 5),
            Text(
              'We can nudge you when cover improvement is available again.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actionLabel: 'Try connection again',
      action: onRetry,
    );
  }
}

class ImproveCoverError extends StatelessWidget {
  const ImproveCoverError({
    required this.dish,
    required this.selectedCount,
    required this.onClose,
    required this.onRetry,
    super.key,
  });

  final Dish dish;
  final int selectedCount;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _StatusPage(
      title: 'Improve cover image',
      onClose: onClose,
      art: const _IconStatusArt(
        icon: Icons.warning_amber_rounded,
        color: MyMenuColors.red,
        background: MyMenuColors.redSoft,
      ),
      eyebrow: 'Generation stopped',
      eyebrowColor: MyMenuColors.red,
      headline: 'That cover didn’t finish',
      description: 'Your connection is working, but the AI service had a '
          'problem. Nothing was replaced.',
      card: Column(
        children: <Widget>[
          _DishSafeRow(
            dish: dish,
            subtitle: '$selectedCount selected sources are remembered',
          ),
          const Divider(height: 24),
          const _CheckLine(text: 'All source photos are safe'),
          const SizedBox(height: 10),
          const _CheckLine(text: 'No AI result was saved'),
        ],
      ),
      footer: const StatusStrip(
        icon: Icons.info_outline,
        text: 'This is a service error, not an offline state.',
      ),
      actionLabel: 'Try generation again',
      action: onRetry,
    );
  }
}

class _StatusPage extends StatelessWidget {
  const _StatusPage({
    required this.title,
    required this.onClose,
    required this.art,
    required this.eyebrow,
    required this.headline,
    required this.description,
    required this.card,
    required this.footer,
    required this.actionLabel,
    required this.action,
    this.eyebrowColor,
  });

  final String title;
  final VoidCallback onClose;
  final Widget art;
  final String eyebrow;
  final Color? eyebrowColor;
  final String headline;
  final String description;
  final Widget card;
  final Widget footer;
  final String actionLabel;
  final VoidCallback? action;

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
                      SheetTopBar(title: title, onClose: onClose),
                      const SizedBox(height: 18),
                      art,
                      const SizedBox(height: 14),
                      Eyebrow(eyebrow, color: eyebrowColor),
                      Text(
                        headline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      WarmCard(
                        padding: const EdgeInsets.all(16),
                        child: card,
                      ),
                      const Spacer(),
                      footer,
                      const SizedBox(height: 12),
                      PrimaryPillButton(
                        label: actionLabel,
                        onPressed: action,
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

class _DishStatusArt extends StatelessWidget {
  const _DishStatusArt({required this.dish, this.pulsing = false});

  final Dish dish;
  final bool pulsing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      height: 124,
      padding: pulsing ? const EdgeInsets.all(10) : EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        border: pulsing
            ? Border.all(color: const Color(0x55FF710A), width: 2)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: DishArtwork(dish: dish),
      ),
    );
  }
}

class _IconStatusArt extends StatelessWidget {
  const _IconStatusArt({
    required this.icon,
    this.color = MyMenuColors.muted,
    this.background = MyMenuColors.oat,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Icon(icon, size: 54, color: color),
    );
  }
}

class _DishSafeRow extends StatelessWidget {
  const _DishSafeRow({required this.dish, required this.subtitle});

  final Dish dish;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: SizedBox(
            width: 54,
            height: 54,
            child: DishArtwork(dish: dish),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(dish.title, style: Theme.of(context).textTheme.titleMedium),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const Icon(Icons.check, color: MyMenuColors.green),
      ],
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(Icons.check, size: 17, color: MyMenuColors.green),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
      ],
    );
  }
}
