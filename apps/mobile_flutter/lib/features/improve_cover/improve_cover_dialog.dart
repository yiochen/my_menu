import 'package:flutter/material.dart';

import 'package:mymenu/domain/sync/my_menu_state.dart';

Future<void> showImproveCoverDialog(
  BuildContext context,
  MyMenuState state,
  String dishId,
) async {
  String prompt = '';
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Improve Cover'),
        content: TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Sharper plating, brighter bowl, cleaner background',
          ),
          onChanged: (String value) {
            prompt = value;
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              state.improveCover(dishId, prompt);
              Navigator.of(context).pop();
            },
            child: const Text('Run'),
          ),
        ],
      );
    },
  );
}
