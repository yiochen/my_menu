import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_controller.dart';

class DebugFeedbackPanelSection extends StatefulWidget {
  const DebugFeedbackPanelSection({
    required this.controller,
    required this.onStart,
    super.key,
  });

  final DebugFeedbackController controller;
  final VoidCallback onStart;

  @override
  State<DebugFeedbackPanelSection> createState() =>
      _DebugFeedbackPanelSectionState();
}

class _DebugFeedbackPanelSectionState extends State<DebugFeedbackPanelSection> {
  bool _confirmingClear = false;

  @override
  Widget build(BuildContext context) {
    final int count = widget.controller.entries.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          key: const ValueKey<String>('debug_feedback_start'),
          leading: const Icon(Icons.ads_click_rounded),
          title: const Text('Collect UI feedback'),
          subtitle: const Text('Tap meaningful interface elements'),
          dense: true,
          onTap: widget.onStart,
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
                onPressed: _confirmingClear
                    ? null
                    : () => setState(() => _confirmingClear = true),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ),
            dense: true,
            onTap: () => _copy(context),
          ),
        if (_confirmingClear && count > 0)
          Padding(
            key: const ValueKey<String>(
              'debug_feedback_clear_confirmation',
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text('Clear all saved feedback?'),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      key: const ValueKey<String>(
                        'debug_feedback_cancel_clear',
                      ),
                      onPressed: () => setState(() => _confirmingClear = false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 6),
                    FilledButton(
                      key: const ValueKey<String>(
                        'debug_feedback_confirm_clear',
                      ),
                      onPressed: _clear,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: widget.controller.buildAgentPrompt()),
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Feedback prompt copied')),
    );
  }

  void _clear() {
    setState(() => _confirmingClear = false);
    widget.controller.clear();
  }
}
