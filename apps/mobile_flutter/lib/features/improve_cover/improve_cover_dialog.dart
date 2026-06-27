import 'package:flutter/material.dart';

import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/shared/widgets/text_prompt_dialog.dart';

Future<void> showImproveCoverDialog(
  BuildContext context,
  MyMenuState state,
  String dishId,
) async {
  final String? prompt = await showTextPromptDialog(
    context,
    title: 'Improve Cover',
    hint: 'Sharper plating, brighter bowl, cleaner background',
    submitLabel: 'Run',
  );
  if (prompt != null) {
    state.improveCover(dishId, prompt);
  }
}
