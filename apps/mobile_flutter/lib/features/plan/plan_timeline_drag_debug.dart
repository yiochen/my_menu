part of 'plan_timeline.dart';

class _MealCenter {
  const _MealCenter(this.mealId, this.centerY);

  final String mealId;
  final double centerY;
}

class _DropDebugPainter extends CustomPainter {
  const _DropDebugPainter({
    required this.thresholdYs,
    required this.ghostCenterY,
  });

  final List<double> thresholdYs;
  final double? ghostCenterY;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint thresholdPaint = Paint()
      ..color = const Color(0xAA00AEEF)
      ..strokeWidth = 1;
    final Paint ghostPaint = Paint()
      ..color = const Color(0xCCFF3B30)
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
  bool shouldRepaint(covariant _DropDebugPainter other) {
    return other.ghostCenterY != ghostCenterY ||
        other.thresholdYs.length != thresholdYs.length ||
        !_listsEqual(other.thresholdYs, thresholdYs);
  }

  bool _listsEqual(List<double> a, List<double> b) {
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

class _MeasuredRow extends StatefulWidget {
  const _MeasuredRow({
    required this.onSizeChanged,
    required this.child,
  });

  final ValueChanged<double> onSizeChanged;
  final Widget child;

  @override
  State<_MeasuredRow> createState() => _MeasuredRowState();
}

class _MeasuredRowState extends State<_MeasuredRow> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportSize());
  }

  @override
  void didUpdateWidget(covariant _MeasuredRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportSize());
  }

  void _reportSize() {
    if (!mounted) {
      return;
    }
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      widget.onSizeChanged(renderObject.size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _PlanTimelineDivider extends StatelessWidget {
  const _PlanTimelineDivider({required this.tokens});

  final PlanThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: tokens.dayDividerPadding,
      child: const Divider(height: 1, color: Color(0xFFE9E1D7)),
    );
  }
}

class _AnimatedInsertionSlot extends StatelessWidget {
  const _AnimatedInsertionSlot({
    required this.tokens,
    required this.isActive,
    required this.hasLeadingRow,
    required this.hasTrailingRow,
    required this.gapHeight,
    super.key,
  });

  final PlanThemeTokens tokens;
  final bool isActive;
  final bool hasLeadingRow;
  final bool hasTrailingRow;
  final double gapHeight;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: tokens.dragGapAnimationDuration,
      curve: tokens.dragGapAnimationCurve,
      child: Column(
        children: <Widget>[
          if (hasLeadingRow && (isActive || hasTrailingRow))
            _PlanTimelineDivider(tokens: tokens),
          _AnimatedInsertionPlaceholder(
            radius: tokens.dragSlotRadius,
            height: isActive ? gapHeight : 0,
            duration: tokens.dragGapAnimationDuration,
            curve: tokens.dragGapAnimationCurve,
          ),
          if (isActive && hasTrailingRow) _PlanTimelineDivider(tokens: tokens),
        ],
      ),
    );
  }
}

class _AnimatedInsertionPlaceholder extends StatelessWidget {
  const _AnimatedInsertionPlaceholder({
    required this.radius,
    required this.height,
    required this.duration,
    required this.curve,
  });

  final double radius;
  final double height;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: height),
      duration: duration,
      curve: curve,
      builder: (BuildContext context, double animatedHeight, Widget? child) {
        if (animatedHeight <= 0.5) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: double.infinity,
          height: animatedHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF8EAC1),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: const Color(0xFFB06D00)),
            ),
          ),
        );
      },
    );
  }
}
