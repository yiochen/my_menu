part of 'plan_timeline.dart';

class _EmptyDayDropZone extends StatelessWidget {
  const _EmptyDayDropZone({
    required this.dayKey,
    required this.isDragging,
    required this.tokens,
    required this.onMealMoved,
  });

  final String dayKey;
  final bool isDragging;
  final PlanThemeTokens tokens;
  final PlanMealMovedCallback onMealMoved;

  @override
  Widget build(BuildContext context) {
    return DragTarget<PlannedMeal>(
      onWillAcceptWithDetails: (DragTargetDetails<PlannedMeal> details) => true,
      onAcceptWithDetails: (DragTargetDetails<PlannedMeal> details) {
        onMealMoved(details.data, dayKey, 0);
      },
      builder: (
        BuildContext context,
        List<PlannedMeal?> candidateData,
        List<dynamic> rejectedData,
      ) {
        final bool isActive = candidateData.isNotEmpty;
        final double height = !isDragging
            ? 0
            : (isActive
                ? tokens.emptyDayDropHoverHeight
                : tokens.emptyDayDropHeight);

        return AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: SizedBox(
            height: height,
            child: height == 0
                ? null
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFF8EAC1)
                          : const Color(0xFFF7F1E6),
                      borderRadius:
                          BorderRadius.circular(tokens.dragSlotRadius),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFFB06D00)
                            : const Color(0xFFE8DFD2),
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
          ),
        );
      },
    );
  }
}
