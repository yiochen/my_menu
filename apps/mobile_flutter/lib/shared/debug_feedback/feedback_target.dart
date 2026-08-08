import 'package:flutter/widgets.dart';

class FeedbackTarget extends StatelessWidget {
  const FeedbackTarget({
    required this.id,
    required this.label,
    required this.child,
    super.key,
  });

  final String id;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class ExcludeFromFeedback extends StatelessWidget {
  const ExcludeFromFeedback({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
