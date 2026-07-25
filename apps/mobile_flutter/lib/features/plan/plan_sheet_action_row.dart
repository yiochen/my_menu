import 'package:flutter/material.dart';

import 'package:mymenu/shared/theme/my_menu_theme.dart';

class PlanSheetActionRow extends StatelessWidget {
  const PlanSheetActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
    this.showChevron = true,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final Color color = destructive ? MyMenuColors.red : MyMenuColors.ink;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        minTileHeight: 58,
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style:
              Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
        ),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: showChevron ? const Icon(Icons.chevron_right) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }
}
