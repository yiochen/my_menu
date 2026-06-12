import 'package:flutter/material.dart';

import 'package:mymenu/domain/sync/my_menu_state.dart';

enum CaptureAction {
  addIdea,
  mockCapture,
}

Future<void> showCaptureSheet(
  BuildContext context,
  MyMenuState state,
) async {
  final CaptureAction? action = await showModalBottomSheet<CaptureAction>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Capture',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'This Flutter pass keeps capture mocked so we can preserve the product loop before device APIs are wired in.',
                ),
                const SizedBox(height: 16),
                _CaptureActionTile(
                  icon: Icons.lightbulb_outline,
                  title: 'Add dish idea',
                  subtitle: 'Save a cooking idea from text.',
                  onTap: () =>
                      Navigator.of(sheetContext).pop(CaptureAction.addIdea),
                ),
                _CaptureActionTile(
                  icon: Icons.photo_camera_back_outlined,
                  title: 'Mock photo capture',
                  subtitle: 'Simulate a capture with a short description.',
                  onTap: () =>
                      Navigator.of(sheetContext).pop(CaptureAction.mockCapture),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  if (!context.mounted || action == null) {
    return;
  }

  if (action == CaptureAction.addIdea) {
    await _showTextPrompt(
      context,
      title: 'New Dish Idea',
      hint: 'Lemongrass chicken bowls',
      onSubmit: state.addIdea,
    );
    return;
  }

  await _showTextPrompt(
    context,
    title: 'Describe the Capture',
    hint: 'salmon bowl dinner',
    onSubmit: state.addMockCapture,
  );
}

class _CaptureActionTile extends StatelessWidget {
  const _CaptureActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}

Future<void> _showTextPrompt(
  BuildContext context, {
  required String title,
  required String hint,
  required ValueChanged<String> onSubmit,
}) async {
  String value = '';
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: TextFormField(
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(hintText: hint),
          onChanged: (String nextValue) {
            value = nextValue;
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onSubmit(value);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
