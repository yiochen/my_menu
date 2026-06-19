part of 'plan_timeline.dart';

class _PlannedDishRow extends StatefulWidget {
  const _PlannedDishRow({
    required this.meal,
    required this.onDragStarted,
    required this.onDragMoved,
    required this.onDragEnded,
  });

  final PlannedMeal meal;
  final PlanMealDragStartedCallback onDragStarted;
  final ValueChanged<Offset> onDragMoved;
  final VoidCallback onDragEnded;

  @override
  State<_PlannedDishRow> createState() => _PlannedDishRowState();
}

class _PlannedDishRowState extends State<_PlannedDishRow> {
  static const Color _planRowColor = Color(0xFFFFFEFB);
  final GlobalKey _rowKey = GlobalKey();
  double _lastTouchOffsetY = 0;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final Dish dish = state.dishById(widget.meal.dishId);
    final PlanThemeTokens tokens = context.planTheme;
    final AppShellThemeTokens shellTokens = context.appShellTheme;
    final double feedbackWidth = MediaQuery.sizeOf(context).width -
        shellTokens.screenHorizontalPadding * 2 -
        tokens.dayColumnWidth -
        tokens.dayColumnGap;

    return Listener(
      onPointerDown: (PointerDownEvent event) {
        final BuildContext? rowContext = _rowKey.currentContext;
        if (rowContext == null) {
          return;
        }
        final RenderBox rowBox = rowContext.findRenderObject()! as RenderBox;
        _lastTouchOffsetY = rowBox.globalToLocal(event.position).dy;
      },
      child: LongPressDraggable<PlannedMeal>(
        data: widget.meal,
        maxSimultaneousDrags: 1,
        onDragStarted: () {
          final double rowHeight = _rowKey.currentContext?.size?.height ??
              tokens.dishThumbHeight + tokens.dishRowInset.vertical;
          widget.onDragStarted(widget.meal, rowHeight, _lastTouchOffsetY);
        },
        onDragUpdate: (DragUpdateDetails details) {
          widget.onDragMoved(details.globalPosition);
        },
        onDraggableCanceled: (_, __) => _handleDragEnded(),
        onDragCompleted: _handleDragEnded,
        onDragEnd: (_) => _handleDragEnded(),
        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: feedbackWidth,
            child: Opacity(
              opacity: 0.96,
              child: _DishRowSurface(
                dish: dish,
                meal: widget.meal,
                backgroundColor: _planRowColor,
                elevation: 10,
              ),
            ),
          ),
        ),
        childWhenDragging: const SizedBox.shrink(),
        child: KeyedSubtree(
          key: _rowKey,
          child: _DishRowSurface(
            dish: dish,
            meal: widget.meal,
            backgroundColor: _planRowColor,
            onTap: () => _openEditor(context, state),
          ),
        ),
      ),
    );
  }

  void _handleDragEnded() {
    widget.onDragEnded();
  }

  Future<void> _openEditor(BuildContext context, MyMenuState state) {
    return showPlanDishDialog(
      context,
      state,
      initialDayKey: widget.meal.dayKey,
      initialDishId: widget.meal.dishId,
      initialLabel: widget.meal.label,
      meal: widget.meal,
    );
  }
}

class _DishRowSurface extends StatelessWidget {
  const _DishRowSurface({
    required this.dish,
    required this.meal,
    required this.backgroundColor,
    this.elevation = 0,
    this.onTap,
  });

  final Dish dish;
  final PlannedMeal meal;
  final Color backgroundColor;
  final double elevation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final PlanThemeTokens tokens = context.planTheme;

    return Material(
      color: backgroundColor,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.dishRowRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.dishRowRadius),
        onTap: onTap,
        child: Padding(
          padding: tokens.dishRowInset,
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(tokens.dishThumbRadius),
                child: Image.network(
                  dish.heroImageUrl,
                  width: tokens.dishThumbWidth,
                  height: tokens.dishThumbHeight,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: tokens.dishContentGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      dish.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: tokens.dishMetaSpacing),
                    Text(
                      '${dish.prepMinutes} min',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF6A6A6A),
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: tokens.dishLabelGap),
              if (meal.label != null) _PlanLabelChip(label: meal.label!),
            ],
          ),
        ),
      ),
    );
  }
}
