part of 'plan_timeline.dart';

class _PlanDayDropGroup extends StatelessWidget {
  const _PlanDayDropGroup({
    required this.date,
    required this.dayKey,
    required this.tokens,
    required this.isDragging,
    required this.hasItems,
    required this.child,
  });

  final DateTime date;
  final String dayKey;
  final PlanThemeTokens tokens;
  final bool isDragging;
  final bool hasItems;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.dayRowSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: tokens.dayColumnWidth,
            child: _PlanDateColumn(date: date),
          ),
          SizedBox(width: tokens.dayColumnGap),
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              color: const Color(0xFFFFFCF7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.cardRadius),
                side: const BorderSide(color: Color(0xFFE8DFD2)),
              ),
              child: Padding(
                padding: tokens.dayCardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    child,
                    if (hasItems) SizedBox(height: tokens.mealToAddSpacing),
                    _AddDishRow(
                      dayKey: dayKey,
                      tokens: tokens,
                      enabled: !isDragging,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

class _PlanDragGap extends StatelessWidget {
  const _PlanDragGap({
    required this.tokens,
    required this.gapState,
  });

  final PlanThemeTokens tokens;
  final DragDropGapState<String, String, PlannedMeal> gapState;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        end: gapState.isActive ? gapState.draggedItemExtent : 0,
      ),
      duration: tokens.dragGapAnimationDuration,
      curve: tokens.dragGapAnimationCurve,
      builder: (BuildContext context, double height, Widget? child) {
        if (height <= 0.5) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: double.infinity,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF8EAC1),
              borderRadius: BorderRadius.circular(tokens.dragSlotRadius),
              border: Border.all(color: const Color(0xFFB06D00)),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyDayDropZone extends StatelessWidget {
  const _EmptyDayDropZone({
    required this.tokens,
    required this.state,
  });

  final PlanThemeTokens tokens;
  final DragDropEmptyGroupState<String, String, PlannedMeal> state;

  @override
  Widget build(BuildContext context) {
    final double height = state.isDragging ? tokens.emptyDayDropHeight : 0;

    return AnimatedSize(
      duration: tokens.dragGapAnimationDuration,
      curve: tokens.dragGapAnimationCurve,
      child: SizedBox(
        height: height,
        child: height == 0
            ? null
            : DecoratedBox(
                decoration: BoxDecoration(
                  color: state.isActive
                      ? const Color(0xFFF8EAC1)
                      : const Color(0xFFF7F1E6),
                  borderRadius: BorderRadius.circular(tokens.dragSlotRadius),
                  border: Border.all(
                    color: state.isActive
                        ? const Color(0xFFB06D00)
                        : const Color(0xFFE8DFD2),
                  ),
                ),
                child: const SizedBox.expand(),
              ),
      ),
    );
  }
}
