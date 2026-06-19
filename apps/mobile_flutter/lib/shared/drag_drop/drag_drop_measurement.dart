part of 'drag_drop_board.dart';

class _MeasuredDragDropItem extends StatefulWidget {
  const _MeasuredDragDropItem({
    required this.onExtentChanged,
    required this.child,
  });

  final ValueChanged<double> onExtentChanged;
  final Widget child;

  @override
  State<_MeasuredDragDropItem> createState() => _MeasuredDragDropItemState();
}

class _MeasuredDragDropItemState extends State<_MeasuredDragDropItem> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportExtent());
  }

  @override
  void didUpdateWidget(covariant _MeasuredDragDropItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportExtent());
  }

  void _reportExtent() {
    if (!mounted) {
      return;
    }
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      widget.onExtentChanged(renderObject.size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
