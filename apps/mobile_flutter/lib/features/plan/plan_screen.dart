import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/app/app_shell_theme.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';
import 'package:mymenu/features/plan/plan_menu_strip.dart';
import 'package:mymenu/features/plan/plan_theme.dart';
import 'package:mymenu/features/plan/plan_timeline.dart';
import 'package:mymenu/shared/widgets/app_image.dart';

part 'plan_screen_sections.dart';
part 'plan_screen_drag_targets.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({
    required this.onOpenReview,
    required this.onOpenCaptureFeed,
    this.onDragStateChanged,
    super.key,
  });

  final VoidCallback onOpenReview;
  final VoidCallback onOpenCaptureFeed;
  final ValueChanged<bool>? onDragStateChanged;

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final ScrollController _scrollController = ScrollController();
  PlanDragDropSession? _dragSession;
  bool _isAddAnotherDayHighlighted = false;
  bool _isTrashHighlighted = false;

  bool get _isDragging => _dragSession != null;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleDragSessionChanged(PlanDragDropSession? session) {
    final bool wasDragging = _isDragging;
    final bool isDragging = session != null;

    setState(() {
      _dragSession = session;
      if (!isDragging) {
        _isAddAnotherDayHighlighted = false;
        _isTrashHighlighted = false;
      }
    });
    if (wasDragging != isDragging) {
      widget.onDragStateChanged?.call(isDragging);
    }
  }

  void _handleDragPointerMove(PointerMoveEvent event) {
    final PlanDragDropSession? session = _dragSession;
    if (session == null) {
      return;
    }
    _handleDragSessionChanged(session.copyWith(globalPosition: event.position));
  }

  void _handleMealMoved(MyMenuState state, PlanDragDropMove move) {
    state.movePlannedMeal(
      move.itemId,
      targetDayKey: move.toGroupId,
      targetIndex: move.toIndex,
    );
  }

  Future<void> _handleDropOnAddAnotherDay(
    BuildContext context,
    MyMenuState state,
    PlanDragDropPayload payload,
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
      return;
    }

    state.ensurePlanDateVisible(selectedDate);
    final String targetDayKey = dayKeyForDate(selectedDate);
    state.movePlannedMeal(
      payload.itemId,
      targetDayKey: targetDayKey,
      targetIndex: state.plannedMealsForDay(targetDayKey).length,
    );
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
      onPointerMove: _isDragging ? _handleDragPointerMove : null,
      child: DecoratedBox(
        key: const ValueKey<String>('plan_screen'),
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
                onMealAccepted: (PlanDragDropPayload payload) {
                  state.removePlannedMeal(payload.itemId);
                  setState(() {
                    _isTrashHighlighted = false;
                  });
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
        if (state.captureItems.isNotEmpty) ...<Widget>[
          SizedBox(height: tokens.reviewSpacing),
          Padding(
            padding: screenPadding,
            child: _SectionShade(
              isDimmed: _isDragging,
              shadeColor: tokens.dragShadeColor,
              child: _CaptureFeedCard(
                count: state.captureItems.length,
                onTap: widget.onOpenCaptureFeed,
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
          scrollController: _scrollController,
          dragSession: _dragSession,
          onDragSessionChanged: _handleDragSessionChanged,
          onMealMoved: (PlanDragDropMove move) => _handleMealMoved(state, move),
        ),
        DragTarget<PlanDragDropPayload>(
          onWillAcceptWithDetails:
              (DragTargetDetails<PlanDragDropPayload> details) {
            setState(() {
              _isAddAnotherDayHighlighted = true;
            });
            return true;
          },
          onLeave: (PlanDragDropPayload? data) {
            if (!_isDragging) {
              return;
            }

            setState(() {
              _isAddAnotherDayHighlighted = false;
            });
          },
          onAcceptWithDetails:
              (DragTargetDetails<PlanDragDropPayload> details) {
            _handleDropOnAddAnotherDay(context, state, details.data, dates);
          },
          builder: (
            BuildContext context,
            List<PlanDragDropPayload?> candidateData,
            List<dynamic> rejectedData,
          ) {
            final bool isActive =
                _isAddAnotherDayHighlighted || candidateData.isNotEmpty;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFF8EAC1) : Colors.transparent,
                borderRadius: BorderRadius.circular(tokens.addButtonRadius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: TextButton.icon(
                  onPressed: _isDragging ? null : state.addNextPlanDay,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB06D00),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add another day'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
