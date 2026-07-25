import 'package:flutter/material.dart';

import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class MenuSearchEmpty extends StatelessWidget {
  const MenuSearchEmpty({required this.onClear, super.key});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            color: MyMenuColors.orangeSoft,
            borderRadius: BorderRadius.circular(38),
          ),
          child: const Icon(
            Icons.search_off_rounded,
            size: 52,
            color: MyMenuColors.orange,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No dish named that—yet',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Try fewer words or search for an ingredient or note.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 150,
          child: PrimaryPillButton(
            label: 'Clear search',
            onPressed: onClear,
            backgroundColor: MyMenuColors.oat,
            foregroundColor: MyMenuColors.ink,
          ),
        ),
      ],
    );
  }
}

class MenuEmpty extends StatelessWidget {
  const MenuEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(Icons.auto_awesome, size: 96, color: MyMenuColors.orange),
        const SizedBox(height: 16),
        Text(
          'Capture your first cooking moment',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'A photo, an import, or even a rough idea is enough. '
          'MyMenu organizes it after capture.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        const StatusStrip(
          icon: Icons.arrow_downward_rounded,
          text: 'Tap the orange + below to begin',
          color: MyMenuColors.orangeDark,
          background: MyMenuColors.orangeSoft,
        ),
      ],
    );
  }
}
