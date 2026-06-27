import 'package:flutter/material.dart';

Future<void> showAnimatedStateSheet(
  BuildContext context, {
  required Listenable animation,
  required Widget Function(BuildContext context) builder,
  double heightFactor = 0.8,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: heightFactor,
        child: AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, _) => builder(context),
        ),
      );
    },
  );
}
