part of 'drag_drop_board.dart';

class _DragDropDebugPainter extends CustomPainter {
  const _DragDropDebugPainter({
    required this.thresholdYs,
    required this.ghostCenterY,
    required this.options,
  });

  final List<double> thresholdYs;
  final double? ghostCenterY;
  final DragDropDebugOptions options;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint thresholdPaint = Paint()
      ..color = options.thresholdColor
      ..strokeWidth = 1;
    final Paint ghostPaint = Paint()
      ..color = options.ghostCenterColor
      ..strokeWidth = 2;

    for (final double y in thresholdYs) {
      if (y < 0 || y > size.height) {
        continue;
      }
      canvas.drawLine(Offset(0, y), Offset(size.width, y), thresholdPaint);
    }

    final double? ghostY = ghostCenterY;
    if (ghostY != null && ghostY >= 0 && ghostY <= size.height) {
      canvas.drawLine(
        Offset(0, ghostY),
        Offset(size.width, ghostY),
        ghostPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DragDropDebugPainter oldDelegate) {
    return oldDelegate.ghostCenterY != ghostCenterY ||
        oldDelegate.thresholdYs.length != thresholdYs.length ||
        !_listEquals(oldDelegate.thresholdYs, thresholdYs) ||
        oldDelegate.options != options;
  }

  bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
