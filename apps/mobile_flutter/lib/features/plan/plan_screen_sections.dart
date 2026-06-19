part of 'plan_screen.dart';

String _rangeLabel(List<DateTime> dates) {
  if (dates.isEmpty) {
    return '';
  }

  final DateTime first = dates.first;
  final DateTime last = dates.last;
  return '${weekdayShort(first)}, ${monthShort(first)} ${first.day} - '
      '${weekdayShort(last)}, ${monthShort(last)} ${last.day}';
}

class _CookTonightBlurb extends StatelessWidget {
  const _CookTonightBlurb();

  @override
  Widget build(BuildContext context) {
    final PlanThemeTokens tokens = context.planTheme;

    return Padding(
      padding: EdgeInsets.only(left: tokens.cookTonightBlurbLeftInset),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            width: constraints.maxWidth * 0.5,
            child: Text(
              "Based on your preferences and what you've cooked recently.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5E615E),
                  ),
            ),
          );
        },
      ),
    );
  }
}

class _CookTonightCard extends StatelessWidget {
  const _CookTonightCard({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final PlanThemeTokens tokens = context.planTheme;

    return Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFFF8F2E8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.cookTonightCardRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.cookTonightCardRadius),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                DishDetailScreen(dishId: dish.id),
          ),
        ),
        child: Padding(
          padding: tokens.cookTonightCardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _CookTonightHeader(),
              SizedBox(height: tokens.cookTonightBlurbTopSpacing),
              const _CookTonightBlurb(),
              SizedBox(height: tokens.cookTonightSuggestionTopSpacing),
              _CookTonightSuggestion(dish: dish),
            ],
          ),
        ),
      ),
    );
  }
}

class _CookTonightHeader extends StatelessWidget {
  const _CookTonightHeader();

  @override
  Widget build(BuildContext context) {
    final PlanThemeTokens tokens = context.planTheme;

    return Row(
      children: <Widget>[
        Icon(
          Icons.auto_awesome_outlined,
          size: tokens.cookTonightHeaderIconSize,
          color: const Color(0xFFB06D00),
        ),
        SizedBox(width: tokens.cookTonightHeaderSpacing),
        Text(
          'Cook Tonight?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: tokens.cookTonightTitleFontSize,
              ),
        ),
      ],
    );
  }
}

class _CookTonightSuggestion extends StatelessWidget {
  const _CookTonightSuggestion({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final PlanThemeTokens tokens = context.planTheme;

    return Container(
      padding: tokens.cookTonightSuggestionPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(tokens.cookTonightSuggestionRadius),
        border: Border.all(color: const Color(0xFFE8DFD2)),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(
              tokens.cookTonightSuggestionThumbRadius,
            ),
            child: Image.network(
              dish.heroImageUrl,
              width: tokens.cookTonightSuggestionThumbWidth,
              height: tokens.cookTonightSuggestionThumbHeight,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: tokens.cookTonightSuggestionGap),
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
                SizedBox(height: tokens.cookTonightSuggestionMetaSpacing),
                Text(
                  '${dish.prepMinutes} min  •  Last made ${dish.lastMadeLabel}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontSize: tokens.cookTonightSuggestionMetaFontSize,
                        color: const Color(0xFF5E615E),
                      ),
                ),
              ],
            ),
          ),
          Icon(
            dish.isFavorite ? Icons.bookmark : Icons.bookmark_border_outlined,
            size: tokens.cookTonightBookmarkSize,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final PlanThemeTokens tokens = context.planTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(tokens.headerButtonRadius),
        border: Border.all(color: const Color(0xFFE8DFD2)),
      ),
      child: SizedBox(
        width: tokens.headerButtonSize,
        height: tokens.headerButtonSize,
        child: IconButton(
          onPressed: onPressed,
          icon: Badge(
            isLabelVisible: badgeCount > 0,
            label: Text('$badgeCount'),
            child: Icon(
              icon,
              size: tokens.headerButtonIconSize,
              color: const Color(0xFF174B2A),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({
    required this.onOpenReview,
    required this.reviewCount,
    required this.dates,
  });

  final VoidCallback onOpenReview;
  final int reviewCount;
  final List<DateTime> dates;

  @override
  Widget build(BuildContext context) {
    final PlanThemeTokens tokens = context.planTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Plan',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              SizedBox(height: tokens.headerTitleSpacing),
              Text(
                _rangeLabel(dates),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF5E615E),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const _HeaderIconButton(
              icon: Icons.calendar_month_outlined,
              onPressed: null,
            ),
            SizedBox(width: tokens.headerActionSpacing),
            _HeaderIconButton(
              icon: Icons.fact_check_outlined,
              badgeCount: reviewCount,
              onPressed: onOpenReview,
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PlanThemeTokens tokens = context.planTheme;

    return Card(
      color: const Color(0xFFFFF0D9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.reviewCardRadius),
      ),
      child: ListTile(
        title: Text('$count capture needs review'),
        subtitle: const Text('Help the app confirm a dish match.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SectionShade extends StatelessWidget {
  const _SectionShade({
    required this.isDimmed,
    required this.shadeColor,
    required this.child,
  });

  final bool isDimmed;
  final Color shadeColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        IgnorePointer(
          ignoring: isDimmed,
          child: child,
        ),
        if (isDimmed)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(color: shadeColor),
              ),
            ),
          ),
      ],
    );
  }
}
