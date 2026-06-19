part of 'plan_timeline.dart';

class _PlanDayCard extends StatefulWidget {
  const _PlanDayCard({
    required this.date,
    required this.tokens,
    required this.draggingMealId,
    required this.draggingMealHeight,
    required this.draggingTouchOffsetY,
    required this.draggingGlobalPosition,
    required this.onDragStarted,
    required this.onDragMoved,
    required this.onDragEnded,
    required this.onMealMoved,
  });

  final DateTime date;
  final PlanThemeTokens tokens;
  final String? draggingMealId;
  final double? draggingMealHeight;
  final double? draggingTouchOffsetY;
  final Offset? draggingGlobalPosition;
  final PlanMealDragStartedCallback onDragStarted;
  final ValueChanged<Offset> onDragMoved;
  final VoidCallback onDragEnded;
  final PlanMealMovedCallback onMealMoved;

  @override
  State<_PlanDayCard> createState() => _PlanDayCardState();
}

class _PlanDayCardState extends State<_PlanDayCard> {
  final GlobalKey _mealsKey = GlobalKey();
  final Map<String, GlobalKey> _mealRowKeys = <String, GlobalKey>{};
  final Map<String, double> _mealRowHeights = <String, double>{};
  List<double> _debugThresholdYs = const <double>[];
  double? _debugGhostCenterY;
  int? _hoveredInsertionIndex;

  bool get isDragging => widget.draggingMealId != null;

  GlobalKey _rowKeyForMeal(String mealId) {
    return _mealRowKeys.putIfAbsent(mealId, GlobalKey.new);
  }

  @override
  void didUpdateWidget(covariant _PlanDayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isDragging && _hoveredInsertionIndex != null) {
      _hoveredInsertionIndex = null;
    }
    if (!isDragging &&
        (_debugThresholdYs.isNotEmpty || _debugGhostCenterY != null)) {
      _debugThresholdYs = const <double>[];
      _debugGhostCenterY = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final String dayKey = dayKeyForDate(widget.date);
    final List<PlannedMeal> meals = state.plannedMealsForDay(dayKey);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: widget.tokens.dayColumnWidth,
          child: _PlanDateColumn(date: widget.date),
        ),
        SizedBox(width: widget.tokens.dayColumnGap),
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            color: const Color(0xFFFFFCF7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.tokens.cardRadius),
              side: const BorderSide(color: Color(0xFFE8DFD2)),
            ),
            child: Padding(
              padding: widget.tokens.dayCardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (meals.isEmpty)
                    _EmptyDayDropZone(
                      dayKey: dayKey,
                      isDragging: isDragging,
                      tokens: widget.tokens,
                      onMealMoved: widget.onMealMoved,
                    )
                  else
                    _buildMealsStack(meals, dayKey),
                  if (meals.isNotEmpty)
                    SizedBox(height: widget.tokens.mealToAddSpacing),
                  _AddDishRow(
                    dayKey: dayKey,
                    tokens: widget.tokens,
                    enabled: !isDragging,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealsStack(List<PlannedMeal> meals, String dayKey) {
    final List<PlannedMeal> visibleMeals = meals
        .where((PlannedMeal meal) => meal.id != widget.draggingMealId)
        .toList(growable: false);
    final int? sourceNoOpIndex = _sourceNoOpIndexFor(meals);

    return DragTarget<PlannedMeal>(
      onWillAcceptWithDetails: (DragTargetDetails<PlannedMeal> details) => true,
      onMove: (DragTargetDetails<PlannedMeal> details) {
        final int nextIndex = _insertionIndexForOffset(
          meals,
          details.offset,
        );
        _updateDebugOverlay(
          meals,
          details.offset,
        );
        if (_hoveredInsertionIndex == nextIndex) {
          return;
        }
        setState(() {
          _hoveredInsertionIndex = nextIndex;
        });
      },
      onLeave: (PlannedMeal? data) {
        if (_hoveredInsertionIndex == null) {
          return;
        }
        setState(() {
          _hoveredInsertionIndex = null;
          _debugGhostCenterY = null;
        });
      },
      onAcceptWithDetails: (DragTargetDetails<PlannedMeal> details) {
        final int targetIndex = _insertionIndexForOffset(
          meals,
          details.offset,
        );
        if (_isSourceNoOpIndex(meals, targetIndex)) {
          widget.onDragEnded();
          setState(() {
            _hoveredInsertionIndex = null;
            _debugGhostCenterY = null;
          });
          return;
        }
        widget.onMealMoved(details.data, dayKey, targetIndex);
        setState(() {
          _hoveredInsertionIndex = null;
          _debugGhostCenterY = null;
        });
      },
      builder: (
        BuildContext context,
        List<PlannedMeal?> candidateData,
        List<dynamic> rejectedData,
      ) {
        return SizedBox(
          key: _mealsKey,
          width: double.infinity,
          child: Stack(
            children: <Widget>[
              if (isDragging)
                _buildDraggingMealsColumn(visibleMeals, sourceNoOpIndex)
              else
                _buildRestingMealsColumn(meals),
              if (isDragging)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _DropDebugPainter(
                        thresholdYs: _debugThresholdYs,
                        ghostCenterY: _debugGhostCenterY,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<double> _thresholdYsForMeals(List<PlannedMeal> meals) {
    return _frozenMealCenters(meals)
        .where((_MealCenter center) => center.mealId != widget.draggingMealId)
        .map((_MealCenter center) => center.centerY)
        .toList(growable: false);
  }

  double? _ghostCenterLocalY(Offset globalFeedbackOrigin) {
    final BuildContext? context = _mealsKey.currentContext;
    if (context == null) {
      return null;
    }
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }
    final RenderBox box = renderObject;
    final double feedbackTopY = box.globalToLocal(globalFeedbackOrigin).dy;
    final double draggedHeight = widget.draggingMealHeight ??
        widget.tokens.dishThumbHeight + widget.tokens.dishRowInset.vertical;
    return feedbackTopY + draggedHeight / 2;
  }

  void _updateDebugOverlay(
    List<PlannedMeal> meals,
    Offset globalFeedbackOrigin,
  ) {
    final List<double> nextThresholdYs = _thresholdYsForMeals(meals);
    final double? nextGhostCenterY = _ghostCenterLocalY(globalFeedbackOrigin);
    final bool sameThresholds =
        _sameThresholds(_debugThresholdYs, nextThresholdYs);
    if (sameThresholds && _debugGhostCenterY == nextGhostCenterY) {
      return;
    }
    setState(() {
      _debugThresholdYs = nextThresholdYs;
      _debugGhostCenterY = nextGhostCenterY;
    });
  }

  int _insertionIndexForOffset(
    List<PlannedMeal> meals,
    Offset globalFeedbackOrigin,
  ) {
    final BuildContext? context = _mealsKey.currentContext;
    if (context == null) {
      return _hoveredInsertionIndex ?? 0;
    }
    final RenderBox box = context.findRenderObject()! as RenderBox;
    final double feedbackTopY = box.globalToLocal(globalFeedbackOrigin).dy;
    final double comparisonY = feedbackTopY + _draggedMealHalfHeight();

    int insertionIndex = 0;
    for (final _MealCenter center in _frozenMealCenters(meals)) {
      if (center.mealId == widget.draggingMealId) {
        continue;
      }
      if (comparisonY > center.centerY) {
        insertionIndex += 1;
      }
    }

    return insertionIndex;
  }

  List<_MealCenter> _frozenMealCenters(List<PlannedMeal> meals) {
    final double dividerHeight = widget.tokens.dayDividerPadding.vertical + 1;
    double cursor = 0;
    final List<_MealCenter> centers = <_MealCenter>[];

    for (int index = 0; index < meals.length; index++) {
      final PlannedMeal meal = meals[index];
      final double rowHeight = _measuredRowHeightFor(meal.id);
      centers.add(_MealCenter(meal.id, cursor + rowHeight / 2));
      cursor += rowHeight;
      if (index != meals.length - 1) {
        cursor += dividerHeight;
      }
    }

    return centers;
  }

  double _measuredRowHeightFor(String mealId) {
    if (mealId == widget.draggingMealId && widget.draggingMealHeight != null) {
      return widget.draggingMealHeight!;
    }

    final double? cachedHeight = _mealRowHeights[mealId];
    if (cachedHeight != null) {
      return cachedHeight;
    }

    return widget.tokens.dishThumbHeight + widget.tokens.dishRowInset.vertical;
  }

  double _draggedMealHalfHeight() {
    return (widget.draggingMealHeight ??
            widget.tokens.dishThumbHeight +
                widget.tokens.dishRowInset.vertical) /
        2;
  }

  void _cacheRowHeight(String mealId, double height) {
    final double? previousHeight = _mealRowHeights[mealId];
    if (previousHeight == height) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final double? currentHeight = _mealRowHeights[mealId];
      if (currentHeight == height) {
        return;
      }
      setState(() {
        _mealRowHeights[mealId] = height;
      });
    });
  }

  bool _sameThresholds(List<double> a, List<double> b) {
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
