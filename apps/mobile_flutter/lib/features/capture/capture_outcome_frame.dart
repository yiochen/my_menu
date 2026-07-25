import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class CaptureOutcomeFrame extends StatelessWidget {
  const CaptureOutcomeFrame({
    required this.topLabel,
    required this.headline,
    required this.description,
    required this.art,
    required this.body,
    required this.onClose,
    this.footer,
    super.key,
  });

  final String topLabel;
  final String headline;
  final String description;
  final Widget art;
  final Widget body;
  final VoidCallback onClose;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return WarmPage(
      includeBottomChromeSpace: false,
      topPadding: 10,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SheetTopBar(title: topLabel, onClose: onClose),
          const SizedBox(height: 18),
          art,
          const SizedBox(height: 14),
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
          const SizedBox(height: 18),
          body,
          if (footer != null) ...<Widget>[
            const SizedBox(height: 16),
            footer!,
          ],
        ],
      ),
    );
  }
}

class CaptureResultIcon extends StatelessWidget {
  const CaptureResultIcon({
    required this.icon,
    required this.color,
    required this.background,
    super.key,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Icon(icon, size: 42, color: color),
    );
  }
}

class CaptureDishResultArt extends StatelessWidget {
  const CaptureDishResultArt({required this.dish, super.key});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(38),
      child: SizedBox(width: 124, height: 124, child: DishArtwork(dish: dish)),
    );
  }
}

class CaptureStatusLine extends StatelessWidget {
  const CaptureStatusLine({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: MyMenuColors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class CaptureDishSafeSummary extends StatelessWidget {
  const CaptureDishSafeSummary({
    required this.dish,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final Dish dish;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child:
              SizedBox(width: 54, height: 54, child: DishArtwork(dish: dish)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class CapturePermissionAction extends StatelessWidget {
  const CapturePermissionAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return WarmCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: ListTile(
          minTileHeight: 72,
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
