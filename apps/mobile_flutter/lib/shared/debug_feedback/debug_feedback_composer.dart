import 'package:flutter/material.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_models.dart';

class DebugFeedbackComposer extends StatefulWidget {
  const DebugFeedbackComposer({
    required this.candidate,
    required this.candidateIndex,
    required this.candidateCount,
    required this.onMoreSpecific,
    required this.onBroader,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final DebugFeedbackCandidate candidate;
  final int candidateIndex;
  final int candidateCount;
  final VoidCallback? onMoreSpecific;
  final VoidCallback? onBroader;
  final VoidCallback onCancel;
  final ValueChanged<String> onSave;

  @override
  State<DebugFeedbackComposer> createState() => _DebugFeedbackComposerState();
}

class _DebugFeedbackComposerState extends State<DebugFeedbackComposer> {
  late final TextEditingController _commentController;
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController()..addListener(_commentChanged);
  }

  @override
  void dispose() {
    _commentController
      ..removeListener(_commentChanged)
      ..dispose();
    super.dispose();
  }

  void _commentChanged() {
    final bool canSave = _commentController.text.trim().isNotEmpty;
    if (_canSave != canSave) {
      setState(() => _canSave = canSave);
    }
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12 + viewInsets.bottom,
      child: Material(
        key: const ValueKey<String>('debug_feedback_composer'),
        elevation: 14,
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _TargetChooser(
                candidate: widget.candidate,
                candidateIndex: widget.candidateIndex,
                candidateCount: widget.candidateCount,
                onMoreSpecific: widget.onMoreSpecific,
                onBroader: widget.onBroader,
              ),
              const SizedBox(height: 10),
              TextField(
                key: const ValueKey<String>('debug_feedback_comment'),
                controller: _commentController,
                autofocus: true,
                minLines: 2,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'What should change?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    key:
                        const ValueKey<String>('debug_feedback_cancel_comment'),
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    key: const ValueKey<String>('debug_feedback_save_comment'),
                    onPressed: _canSave
                        ? () => widget.onSave(_commentController.text)
                        : null,
                    icon: const Icon(Icons.add_comment_rounded),
                    label: const Text('Save comment'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TargetChooser extends StatelessWidget {
  const _TargetChooser({
    required this.candidate,
    required this.candidateIndex,
    required this.candidateCount,
    required this.onMoreSpecific,
    required this.onBroader,
  });

  final DebugFeedbackCandidate candidate;
  final int candidateIndex;
  final int candidateCount;
  final VoidCallback? onMoreSpecific;
  final VoidCallback? onBroader;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Semantics(
          label: 'Select a more specific element',
          button: true,
          enabled: onMoreSpecific != null,
          child: IconButton(
            onPressed: onMoreSpecific,
            icon: const Icon(Icons.arrow_downward_rounded),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                candidate.snapshot.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                '${candidate.snapshot.widgetType} · '
                '${candidateIndex + 1} of $candidateCount meaningful targets',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Semantics(
          label: 'Select a broader element',
          button: true,
          enabled: onBroader != null,
          child: IconButton(
            onPressed: onBroader,
            icon: const Icon(Icons.arrow_upward_rounded),
          ),
        ),
      ],
    );
  }
}
