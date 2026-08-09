part of 'plan_timeline.dart';

class _PlannedDishRow extends StatefulWidget {
  const _PlannedDishRow({
    required this.meal,
    super.key,
  });

  static const Color _planRowColor = Color(0xFFFFFEFB);

  final PlannedMeal meal;

  @override
  State<_PlannedDishRow> createState() => _PlannedDishRowState();
}

class _PlannedDishRowState extends State<_PlannedDishRow> {
  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final Dish dish = state.dishById(widget.meal.dishId);

    return _DishRowSurface(
      dish: dish,
      meal: widget.meal,
      backgroundColor: _PlannedDishRow._planRowColor,
      onTap: () => _openEditor(context, state),
    );
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

class _PlannedDishFeedback extends StatelessWidget {
  const _PlannedDishFeedback({required this.meal});

  final PlannedMeal meal;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final Dish dish = state.dishById(meal.dishId);
    final PlanThemeTokens tokens = context.planTheme;
    final AppShellThemeTokens shellTokens = context.appShellTheme;
    final double feedbackWidth = MediaQuery.sizeOf(context).width -
        shellTokens.screenHorizontalPadding * 2 -
        tokens.dayColumnWidth -
        tokens.dayColumnGap;

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: feedbackWidth,
        child: Opacity(
          opacity: 0.96,
          child: _DishRowSurface(
            dish: dish,
            meal: meal,
            backgroundColor: _PlannedDishRow._planRowColor,
            elevation: 10,
          ),
        ),
      ),
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
                child: SizedBox(
                  width: tokens.dishThumbWidth,
                  height: tokens.dishThumbHeight,
                  child: DishArtwork(dish: dish, resizeForDisplay: true),
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
