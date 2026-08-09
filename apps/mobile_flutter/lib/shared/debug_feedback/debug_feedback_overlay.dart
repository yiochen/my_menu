import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_composer.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_controller.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_models.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_source_reader.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_target_finder.dart';

class DebugFeedbackOverlay extends StatefulWidget {
  const DebugFeedbackOverlay({
    required this.controller,
    required this.child,
    this.targetFinder = const DebugFeedbackTargetFinder(),
    this.sourceReader = const DebugFeedbackSourceReader(),
    super.key,
  });

  final DebugFeedbackController controller;
  final DebugFeedbackTargetFinder targetFinder;
  final DebugFeedbackSourceReader sourceReader;
  final Widget child;

  @override
  State<DebugFeedbackOverlay> createState() => _DebugFeedbackOverlayState();
}

class _DebugFeedbackOverlayState extends State<DebugFeedbackOverlay> {
  final GlobalKey _contentKey = GlobalKey();
  List<DebugFeedbackCandidate> _candidates = const <DebugFeedbackCandidate>[];
  int _candidateIndex = 0;
  String? _notice;

  DebugFeedbackCandidate? get _selection => _candidates.isEmpty
      ? null
      : _candidates[_candidateIndex.clamp(0, _candidates.length - 1)];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_controllerChanged);
  }

  @override
  void didUpdateWidget(DebugFeedbackOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_controllerChanged);
      widget.controller.addListener(_controllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerChanged);
    super.dispose();
  }

  void _controllerChanged() {
    if (!widget.controller.collecting && _candidates.isNotEmpty) {
      setState(_clearSelection);
    } else if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.collecting) {
      return widget.child;
    }
    final DebugFeedbackCandidate? selection = _selection;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        IgnorePointer(
          key: _contentKey,
          child: widget.child,
        ),
        if (selection == null)
          GestureDetector(
            key: const ValueKey<String>('debug_feedback_picker'),
            behavior: HitTestBehavior.opaque,
            onTapUp: _selectAt,
          ),
        IgnorePointer(
          child: CustomPaint(
            painter: _FeedbackHighlightPainter(selection?.bounds),
          ),
        ),
        _buildToolbar(context),
        if (_notice != null && selection == null)
          _FeedbackNotice(message: _notice!),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final int count = widget.controller.entries.length;
    return Positioned(
      left: 12,
      top: MediaQuery.paddingOf(context).top + 10,
      right: 12,
      child: Material(
        color: Theme.of(context).colorScheme.inverseSurface,
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 8),
              const Icon(Icons.ads_click_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selection == null
                      ? 'Tap an interface element'
                      : 'Comment on selection',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (count > 0)
                Semantics(
                  label:
                      'Copy $count feedback ${count == 1 ? 'item' : 'items'}',
                  button: true,
                  child: IconButton(
                    key: const ValueKey<String>('debug_feedback_copy'),
                    onPressed: () => _copyFeedback(context),
                    icon: Badge(
                      label: Text('$count'),
                      child: const Icon(Icons.copy_all_rounded),
                    ),
                    color: Colors.white,
                  ),
                ),
              TextButton(
                key: const ValueKey<String>('debug_feedback_done'),
                onPressed: widget.controller.stopCollecting,
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectAt(TapUpDetails details) async {
    final RenderObject? root = _contentKey.currentContext?.findRenderObject();
    if (root is! RenderIgnorePointer || root.child == null) {
      return;
    }
    final List<DebugFeedbackCandidate> candidates = widget.targetFinder.find(
      position: details.globalPosition,
      root: root.child!,
    );
    if (candidates.isEmpty) {
      setState(() => _notice = 'No meaningful element at that point');
      return;
    }
    final int explicitIndex = candidates.indexWhere(
      (DebugFeedbackCandidate candidate) => candidate.explicit,
    );
    final int initialIndex = explicitIndex < 0 ? 0 : explicitIndex;
    final List<String?> sourceLocations = candidates
        .map(
          (DebugFeedbackCandidate candidate) =>
              widget.sourceReader.read(candidate.element),
        )
        .toList(growable: false);
    final Future<_DebugFeedbackDraft?> route = showGeneralDialog(
      context: candidates[initialIndex].element,
      barrierDismissible: true,
      barrierLabel: 'Cancel feedback comment',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return _DebugFeedbackCommentRoute(
          candidates: candidates,
          sourceLocations: sourceLocations,
          initialIndex: initialIndex,
        );
      },
    );
    widget.controller.stopCollecting();
    final _DebugFeedbackDraft? draft = await route;
    if (!mounted) {
      return;
    }
    if (draft != null) {
      widget.controller.add(
        target: draft.candidate.snapshot.withSourceLocation(
          draft.sourceLocation,
        ),
        comment: draft.comment,
      );
    }
    widget.controller.startCollecting();
    setState(() {
      _notice = draft == null ? null : 'Feedback saved. Tap another element.';
    });
  }

  void _clearSelection() {
    _candidates = const <DebugFeedbackCandidate>[];
    _candidateIndex = 0;
  }

  Future<void> _copyFeedback(BuildContext context) async {
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
}

class _DebugFeedbackDraft {
  const _DebugFeedbackDraft({
    required this.candidate,
    required this.comment,
    required this.sourceLocation,
  });

  final DebugFeedbackCandidate candidate;
  final String comment;
  final String? sourceLocation;
}

class _DebugFeedbackCommentRoute extends StatefulWidget {
  const _DebugFeedbackCommentRoute({
    required this.candidates,
    required this.sourceLocations,
    required this.initialIndex,
  });

  final List<DebugFeedbackCandidate> candidates;
  final List<String?> sourceLocations;
  final int initialIndex;

  @override
  State<_DebugFeedbackCommentRoute> createState() =>
      _DebugFeedbackCommentRouteState();
}

class _DebugFeedbackCommentRouteState
    extends State<_DebugFeedbackCommentRoute> {
  late int _candidateIndex = widget.initialIndex;

  DebugFeedbackCandidate get _candidate => widget.candidates[_candidateIndex];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        DebugFeedbackComposer(
          candidate: _candidate,
          candidateIndex: _candidateIndex,
          candidateCount: widget.candidates.length,
          onMoreSpecific: _candidateIndex > 0
              ? () => setState(() => _candidateIndex -= 1)
              : null,
          onBroader: _candidateIndex + 1 < widget.candidates.length
              ? () => setState(() => _candidateIndex += 1)
              : null,
          onCancel: () => Navigator.pop(context),
          onSave: (String comment) {
            Navigator.pop(
              context,
              _DebugFeedbackDraft(
                candidate: _candidate,
                comment: comment,
                sourceLocation: widget.sourceLocations[_candidateIndex],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _FeedbackHighlightPainter extends CustomPainter {
  const _FeedbackHighlightPainter(this.bounds);

  final Rect? bounds;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect? target = bounds;
    if (target == null || target.isEmpty) {
      return;
    }
    canvas.drawRect(
      target.inflate(2),
      Paint()
        ..color = const Color(0xFFFF7A00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_FeedbackHighlightPainter oldDelegate) {
    return bounds != oldDelegate.bounds;
  }
}

class _FeedbackNotice extends StatelessWidget {
  const _FeedbackNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 32,
      right: 32,
      top: MediaQuery.paddingOf(context).top + 82,
      child: Material(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
