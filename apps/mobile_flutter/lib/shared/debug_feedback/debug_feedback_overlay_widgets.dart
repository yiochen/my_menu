import 'package:flutter/material.dart';

class DebugFeedbackHighlight extends StatelessWidget {
  const DebugFeedbackHighlight({required this.bounds, super.key});

  final Rect bounds;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        key: const ValueKey<String>('debug_feedback_highlight'),
        painter: _DebugFeedbackHighlightPainter(bounds),
      ),
    );
  }
}

class _DebugFeedbackHighlightPainter extends CustomPainter {
  const _DebugFeedbackHighlightPainter(this.bounds);

  final Rect bounds;

  @override
  void paint(Canvas canvas, Size size) {
    if (bounds.isEmpty) {
      return;
    }
    canvas.drawRect(
      bounds.inflate(2),
      Paint()
        ..color = const Color(0xFFFF7A00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_DebugFeedbackHighlightPainter oldDelegate) {
    return bounds != oldDelegate.bounds;
  }
}

class DebugFeedbackNotice extends StatelessWidget {
  const DebugFeedbackNotice({required this.message, super.key});

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
