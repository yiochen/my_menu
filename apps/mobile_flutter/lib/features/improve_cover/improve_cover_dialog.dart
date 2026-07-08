import 'package:flutter/material.dart';

import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/shared/widgets/app_dialog.dart';

Future<void> showImproveCoverDialog(
  BuildContext context,
  MyMenuState state,
  String dishId,
) async {
  String prompt = '';
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AppDialog(
        title: 'Improve Cover',
        subtitle: 'Describe the cover image you want for this dish.',
        icon: Icons.auto_awesome,
        content: TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Sharper plating, brighter bowl, cleaner background',
          ),
          onChanged: (String value) {
            prompt = value;
          },
        ),
        actions: <AppDialogAction>[
          AppDialogAction(
            label: 'Cancel',
            icon: Icons.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppDialogAction(
            label: 'Run',
            icon: Icons.auto_awesome,
            isPrimary: true,
            onPressed: () {
              state.improveCover(dishId, prompt);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
