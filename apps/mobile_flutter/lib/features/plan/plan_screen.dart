import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/app/app_shell_theme.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';
import 'package:mymenu/features/plan/plan_menu_strip.dart';
import 'package:mymenu/features/plan/plan_theme.dart';
import 'package:mymenu/features/plan/plan_timeline.dart';

part 'plan_screen_sections.dart';
part 'plan_screen_drag_targets.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({
    required this.onOpenReview,
    this.onDragStateChanged,
    super.key,
  });

  final VoidCallback onOpenReview;
  final ValueChanged<bool>? onDragStateChanged;

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  Ticker? _dragAutoScrollTicker;
  Duration? _lastDragAutoScrollTick;
  PlannedMeal? _draggingMeal;
  double? _draggingMealHeight;
  double? _draggingTouchOffsetY;
  Offset? _draggingGlobalPosition;
  bool _isAddAnotherDayHighlighted = false;
  bool _isTrashHighlighted = false;

  bool get _isDragging => _draggingMeal != null;

  @override
  void dispose() {
    _dragAutoScrollTicker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleDragStarted(
    PlannedMeal meal,
    double rowHeight,
    double touchOffsetY,
  ) {
    setState(() {
      _draggingMeal = meal;
      _draggingMealHeight = rowHeight;
      _draggingTouchOffsetY = touchOffsetY;
      _draggingGlobalPosition = null;
      _isAddAnotherDayHighlighted = false;
      _isTrashHighlighted = false;
    });
    _startDragAutoScroll();
    widget.onDragStateChanged?.call(true);
  }

  void _handleDragEnded() {
    if (!mounted) {
      return;
    }

    setState(() {
      _draggingMeal = null;
      _draggingMealHeight = null;
      _draggingTouchOffsetY = null;
      _draggingGlobalPosition = null;
      _isAddAnotherDayHighlighted = false;
      _isTrashHighlighted = false;
    });
    _stopDragAutoScroll();
    widget.onDragStateChanged?.call(false);
  }

  void _handleDragMoved(Offset globalPosition) {
    if (mounted) {
      setState(() {
        _draggingGlobalPosition = globalPosition;
      });
    }
  }

  void _startDragAutoScroll() {
    _lastDragAutoScrollTick = null;
    _dragAutoScrollTicker ??= createTicker(_handleDragAutoScrollTick);
    if (!_dragAutoScrollTicker!.isActive) {
      _dragAutoScrollTicker!.start();
    }
  }

  void _stopDragAutoScroll() {
    _dragAutoScrollTicker?.stop();
    _lastDragAutoScrollTick = null;
  }

  void _handleDragAutoScrollTick(Duration elapsed) {
    final Duration? previousElapsed = _lastDragAutoScrollTick;
    _lastDragAutoScrollTick = elapsed;
    if (!_isDragging ||
        previousElapsed == null ||
        !_scrollController.hasClients ||
        !mounted) {
      return;
    }

    final Offset? dragPosition = _draggingGlobalPosition;
    if (dragPosition == null) {
      return;
    }

    final RenderObject? renderObject = context.findRenderObject();
    final RenderBox? screenBox =
        renderObject is RenderBox && renderObject.hasSize ? renderObject : null;
    final double topEdge = screenBox?.localToGlobal(Offset.zero).dy ?? 0;
    final double bottomEdge = screenBox == null
        ? MediaQuery.sizeOf(context).height
        : topEdge + screenBox.size.height;
    final double trigger = context.planTheme.dragAutoScrollTrigger;
    final double maxStep = context.planTheme.dragAutoScrollStep;
    final double elapsedSeconds =
        (elapsed - previousElapsed).inMicroseconds.clamp(0, 50000).toDouble() /
            Duration.microsecondsPerSecond;
    final double frameScale = elapsedSeconds * 60;
    double direction = 0;
    double progress = 0;

    if (dragPosition.dy < topEdge + trigger) {
      direction = -1;
      progress =
          ((topEdge + trigger - dragPosition.dy) / trigger).clamp(0.0, 1.0);
    } else if (dragPosition.dy > bottomEdge - trigger) {
      direction = 1;
      progress = ((dragPosition.dy - (bottomEdge - trigger)) / trigger)
          .clamp(0.0, 1.0);
    }

    if (direction == 0 || progress == 0) {
      return;
    }

    _jumpByDragAutoScrollDelta(direction * maxStep * progress * frameScale);
  }

  void _handleMealMoved(
    MyMenuState state,
    PlannedMeal meal,
    String targetDayKey,
    int targetIndex,
  ) {
    state.movePlannedMeal(
      meal.id,
      targetDayKey: targetDayKey,
      targetIndex: targetIndex,
    );
    _handleDragEnded();
  }

  Future<void> _handleDropOnAddAnotherDay(
    BuildContext context,
    MyMenuState state,
    PlannedMeal meal,
    List<DateTime> dates,
  ) async {
    setState(() {
      _isAddAnotherDayHighlighted = false;
    });

    final DateTime initialDate = dates.isEmpty
        ? startOfDay(DateTime.now()).add(const Duration(days: 1))
        : startOfDay(dates.last).add(const Duration(days: 1));
    final DateTime firstDate =
        dates.isEmpty ? startOfDay(DateTime.now()) : startOfDay(dates.first);
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365)),
    );
    if (!mounted) {
      return;
    }
    if (selectedDate == null) {
      _handleDragEnded();
      return;
    }

    state.ensurePlanDateVisible(selectedDate);
    final String targetDayKey = dayKeyForDate(selectedDate);
    state.movePlannedMeal(
      meal.id,
      targetDayKey: targetDayKey,
      targetIndex: state.plannedMealsForDay(targetDayKey).length,
    );
    _handleDragEnded();
  }

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final Dish recommendedDish = state.recommendedDish();
    final List<DateTime> dates = state.remainingPlanDates();
    final AppShellThemeTokens shellTokens = context.appShellTheme;
    final PlanThemeTokens tokens = context.planTheme;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: _isDragging ? _handlePointerMove : null,
      onPointerUp: _isDragging ? _handlePointerEnded : null,
      onPointerCancel: _isDragging ? _handlePointerEnded : null,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFFFFFCF7)),
        child: Stack(
          children: <Widget>[
            _buildPlanList(
              state: state,
              recommendedDish: recommendedDish,
              dates: dates,
              shellTokens: shellTokens,
              tokens: tokens,
            ),
            if (_isDragging)
              _PlanTrashTarget(
                tokens: tokens,
                isDragging: _isDragging,
                isHighlighted: _isTrashHighlighted,
                onHighlightChanged: (bool isHighlighted) {
                  setState(() {
                    _isTrashHighlighted = isHighlighted;
                  });
                },
                onMealAccepted: (PlannedMeal meal) {
                  state.removePlannedMeal(meal.id);
                  setState(() {
                    _isTrashHighlighted = false;
                  });
                  _handleDragEnded();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanList({
    required MyMenuState state,
    required Dish recommendedDish,
    required List<DateTime> dates,
    required AppShellThemeTokens shellTokens,
    required PlanThemeTokens tokens,
  }) {
    final EdgeInsets screenPadding = EdgeInsets.symmetric(
      horizontal: shellTokens.screenHorizontalPadding,
    );

    return ListView(
      controller: _scrollController,
      physics: _isDragging ? const NeverScrollableScrollPhysics() : null,
      padding: EdgeInsets.only(
        top: tokens.screenTopPadding,
        bottom: tokens.screenBottomPadding,
      ),
      children: <Widget>[
        Padding(
          padding: screenPadding,
          child: _SectionShade(
            isDimmed: _isDragging,
            shadeColor: tokens.dragShadeColor,
            child: _PlanHeader(
              onOpenReview: widget.onOpenReview,
              reviewCount: state.reviewItems.length,
              dates: dates,
            ),
          ),
        ),
        SizedBox(height: tokens.sectionSpacing),
        Padding(
          padding: screenPadding,
          child:
              _buildTimelineSection(state: state, dates: dates, tokens: tokens),
        ),
        SizedBox(height: tokens.sectionSpacing),
        Padding(
          padding: screenPadding,
          child: _SectionShade(
            isDimmed: _isDragging,
            shadeColor: tokens.dragShadeColor,
            child: _CookTonightCard(dish: recommendedDish),
          ),
        ),
        SizedBox(height: tokens.subsectionSpacing),
        _SectionShade(
          isDimmed: _isDragging,
          shadeColor: tokens.dragShadeColor,
          child: PlanMenuStrip(
            horizontalPadding: shellTokens.screenHorizontalPadding,
          ),
        ),
        if (state.reviewItems.isNotEmpty) ...<Widget>[
          SizedBox(height: tokens.reviewSpacing),
          Padding(
            padding: screenPadding,
            child: _SectionShade(
              isDimmed: _isDragging,
              shadeColor: tokens.dragShadeColor,
              child: _ReviewCard(
                count: state.reviewItems.length,
                onTap: widget.onOpenReview,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimelineSection({
    required MyMenuState state,
    required List<DateTime> dates,
    required PlanThemeTokens tokens,
  }) {
    return Column(
      children: <Widget>[
        PlanTimeline(
          dates: dates,
          draggingMealId: _draggingMeal?.id,
          draggingMealHeight: _draggingMealHeight,
          draggingTouchOffsetY: _draggingTouchOffsetY,
          draggingGlobalPosition: _draggingGlobalPosition,
          onDragStarted: _handleDragStarted,
          onDragMoved: _handleDragMoved,
          onDragEnded: _handleDragEnded,
          onMealMoved: (PlannedMeal meal, String targetDayKey, int index) {
            _handleMealMoved(state, meal, targetDayKey, index);
          },
        ),
        Center(
          child: DragTarget<PlannedMeal>(
            onWillAcceptWithDetails: (DragTargetDetails<PlannedMeal> details) {
              setState(() {
                _isAddAnotherDayHighlighted = true;
              });
              return true;
            },
            onLeave: (PlannedMeal? data) {
              if (!_isDragging) {
                return;
              }

              setState(() {
                _isAddAnotherDayHighlighted = false;
              });
            },
            onAcceptWithDetails: (DragTargetDetails<PlannedMeal> details) {
              _handleDropOnAddAnotherDay(context, state, details.data, dates);
            },
            builder: (
              BuildContext context,
              List<PlannedMeal?> candidateData,
              List<dynamic> rejectedData,
            ) {
              final bool isActive =
                  _isAddAnotherDayHighlighted || candidateData.isNotEmpty;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                decoration: BoxDecoration(
                  color:
                      isActive ? const Color(0xFFF8EAC1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(tokens.addButtonRadius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextButton.icon(
                  onPressed: _isDragging ? null : state.addNextPlanDay,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB06D00),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add another day'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
