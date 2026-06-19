part of 'plan_timeline.dart';

extension _PlanDayCardLayout on _PlanDayCardState {
  Widget _buildRestingMealsColumn(List<PlannedMeal> meals) {
    return Column(
      children: <Widget>[
        for (int index = 0; index < meals.length; index++) ...<Widget>[
          _buildMeasuredMealRow(meals[index]),
          if (index != meals.length - 1)
            _PlanTimelineDivider(tokens: widget.tokens),
        ],
      ],
    );
  }

  Widget _buildDraggingMealsColumn(
    List<PlannedMeal> visibleMeals,
    int? sourceNoOpIndex,
  ) {
    final double gapHeight = dragGapHeightFor(
      widget.tokens,
      draggingMealHeight: widget.draggingMealHeight,
    );

    return Column(
      children: <Widget>[
        for (int index = 0; index <= visibleMeals.length; index++) ...<Widget>[
          _AnimatedInsertionSlot(
            key: ValueKey<String>('plan_drag_slot_$index'),
            tokens: widget.tokens,
            isActive: _hoveredInsertionIndex == index,
            hasLeadingRow: index > 0,
            hasTrailingRow: index < visibleMeals.length,
            gapHeight: gapHeight,
          ),
          if (index < visibleMeals.length)
            _buildMeasuredMealRow(visibleMeals[index]),
        ],
        SizedBox(height: widget.tokens.mealToAddSpacing),
      ],
    );
  }

  Widget _buildMeasuredMealRow(PlannedMeal meal) {
    return KeyedSubtree(
      key: _rowKeyForMeal(meal.id),
      child: _MeasuredRow(
        onSizeChanged: (double height) {
          _cacheRowHeight(meal.id, height);
        },
        child: _PlannedDishRow(
          meal: meal,
          onDragStarted: widget.onDragStarted,
          onDragMoved: widget.onDragMoved,
          onDragEnded: widget.onDragEnded,
        ),
      ),
    );
  }

  int? _sourceNoOpIndexFor(List<PlannedMeal> meals) {
    final String? draggingMealId = widget.draggingMealId;
    if (draggingMealId == null) {
      return null;
    }
    final int index = meals.indexWhere(
      (PlannedMeal meal) => meal.id == draggingMealId,
    );
    return index == -1 ? null : index;
  }

  bool _isSourceNoOpIndex(List<PlannedMeal> meals, int insertionIndex) {
    return _sourceNoOpIndexFor(meals) == insertionIndex;
  }
}
