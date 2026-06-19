part of 'plan_screen.dart';

class _PlanTrashTarget extends StatelessWidget {
  const _PlanTrashTarget({
    required this.tokens,
    required this.isDragging,
    required this.isHighlighted,
    required this.onHighlightChanged,
    required this.onMealAccepted,
  });

  final PlanThemeTokens tokens;
  final bool isDragging;
  final bool isHighlighted;
  final ValueChanged<bool> onHighlightChanged;
  final ValueChanged<PlanDragDropPayload> onMealAccepted;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: tokens.dragTrashRightOffset,
      top: (MediaQuery.sizeOf(context).height - tokens.dragTrashSize) / 2,
      child: DragTarget<PlanDragDropPayload>(
        key: const ValueKey<String>('plan_trash_target'),
        onWillAcceptWithDetails:
            (DragTargetDetails<PlanDragDropPayload> details) {
          onHighlightChanged(true);
          return true;
        },
        onLeave: (PlanDragDropPayload? data) {
          if (!isDragging) {
            return;
          }
          onHighlightChanged(false);
        },
        onAcceptWithDetails: (DragTargetDetails<PlanDragDropPayload> details) {
          onMealAccepted(details.data);
        },
        builder: (
          BuildContext context,
          List<PlanDragDropPayload?> candidateData,
          List<dynamic> rejectedData,
        ) {
          final bool isActive = isHighlighted || candidateData.isNotEmpty;
          return AnimatedScale(
            duration: const Duration(milliseconds: 140),
            scale: isActive ? 1.08 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: tokens.dragTrashSize,
              height: tokens.dragTrashSize,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFD1495B)
                    : const Color(0xFFFFFCF7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? const Color(0xFFD1495B)
                      : const Color(0xFFE8DFD2),
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(
                Icons.delete_outline,
                size: tokens.dragTrashIconSize,
                color: isActive ? Colors.white : const Color(0xFF8F3E4C),
              ),
            ),
          );
        },
      ),
    );
  }
}
