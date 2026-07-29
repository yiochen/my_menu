import 'package:flutter/material.dart';

import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

Future<bool> confirmCaptureBatchRemoval(
  BuildContext context,
  CaptureBatch batch,
) async {
  final int count = batch.items.length;
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            key: const ValueKey<String>('remove_capture_batch_dialog'),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: MyMenuColors.red,
            ),
            title: const Text('Remove pending upload?'),
            content: Text(
              'This stops processing and removes '
              '$count ${count == 1 ? 'photo' : 'photos'} from MyMenu. '
              'Photos in your phone’s library are not changed.',
            ),
            actions: <Widget>[
              TextButton(
                key: const ValueKey<String>('keep_capture_batch'),
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Keep'),
              ),
              FilledButton(
                key: const ValueKey<String>('confirm_remove_capture_batch'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: MyMenuColors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Remove upload'),
              ),
            ],
          );
        },
      ) ??
      false;
}
