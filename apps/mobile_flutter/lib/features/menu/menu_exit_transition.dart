import 'package:flutter/material.dart';

class MenuExitTransition extends StatefulWidget {
  const MenuExitTransition({
    required this.removing,
    required this.duration,
    required this.onExitCompleted,
    required this.child,
    super.key,
  });

  final bool removing;
  final Duration duration;
  final VoidCallback onExitCompleted;
  final Widget child;

  @override
  State<MenuExitTransition> createState() => _MenuExitTransitionState();
}

class _MenuExitTransitionState extends State<MenuExitTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      animationBehavior: AnimationBehavior.preserve,
    )..addStatusListener(_handleStatus);
    final CurvedAnimation curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _opacity = Tween<double>(begin: 1, end: 0).animate(curved);
    _scale = Tween<double>(begin: 1, end: 0.82).animate(curved);
    if (widget.removing) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant MenuExitTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.removing && widget.removing) {
      _controller.forward(from: 0);
    } else if (oldWidget.removing && !widget.removing) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleStatus)
      ..dispose();
    super.dispose();
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && widget.removing) {
      widget.onExitCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
