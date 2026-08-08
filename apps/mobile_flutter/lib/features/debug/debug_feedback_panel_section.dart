import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_controller.dart';

class DebugFeedbackPanelSection extends StatelessWidget {
  const DebugFeedbackPanelSection({
    required this.controller,
    required this.onStart,
    super.key,
  });

  final DebugFeedbackController controller;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final int count = controller.entries.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          key: const ValueKey<String>('debug_feedback_start'),
          leading: const Icon(Icons.ads_click_rounded),
          title: const Text('Collect UI feedback'),
          subtitle: const Text('Tap meaningful interface elements'),
          dense: true,
          onTap: onStart,
        ),
        if (count > 0)
          ListTile(
            key: const ValueKey<String>('debug_feedback_copy_from_panel'),
            leading: const Icon(Icons.copy_all_rounded),
            title: const Text('Copy feedback for agent'),
            subtitle: Text('$count ${count == 1 ? 'comment' : 'comments'}'),
            trailing: Semantics(
              label: 'Clear feedback',
              button: true,
              child: IconButton(
                key: const ValueKey<String>('debug_feedback_clear'),
                onPressed: () => _confirmClear(context),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ),
            dense: true,
            onTap: () => _copy(context),
          ),
      ],
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: controller.buildAgentPrompt()),
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Feedback prompt copied')),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final bool shouldClear = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Clear all feedback?'),
              content: const Text(
                'This removes every saved comment from this debug session.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Clear'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (shouldClear) {
      controller.clear();
    }
  }
}
