part of 'plan_timeline.dart';

class _AddDishRow extends StatelessWidget {
  const _AddDishRow({
    required this.dayKey,
    required this.tokens,
    required this.enabled,
  });

  final String dayKey;
  final PlanThemeTokens tokens;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);

    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: OutlinedButton.icon(
          onPressed: () => showPlanDishDialog(
            context,
            state,
            initialDayKey: dayKey,
          ),
          icon: const Icon(Icons.add),
          label: const Text('Add dish'),
          style: OutlinedButton.styleFrom(
            minimumSize: Size.fromHeight(tokens.addButtonHeight),
            foregroundColor: const Color(0xFFB06D00),
            side: const BorderSide(color: Color(0xFFE8DCCB)),
            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFFB06D00),
                ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.addButtonRadius),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanDateColumn extends StatelessWidget {
  const _PlanDateColumn({required this.date});

  final DateTime date;
  static const Color _planAccentColor = Color(0xFFB06D00);

  @override
  Widget build(BuildContext context) {
    final bool isToday =
        date.difference(startOfDay(DateTime.now())).inDays == 0;
    final PlanThemeTokens tokens = context.planTheme;
    final Color dotColor = isToday ? _planAccentColor : const Color(0xFF174B2A);
    final Color headerColor = isToday ? dotColor : const Color(0xFF174B2A);
    final Color dayColor = isToday ? dotColor : Colors.black;
    final Color weekdayColor = isToday ? dotColor : const Color(0xFF737373);

    return Column(
      children: <Widget>[
        Text(
          isToday ? 'TODAY' : weekdayShort(date).toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: headerColor,
                fontWeight: FontWeight.w700,
              ),
        ),
        SizedBox(height: tokens.dateHeaderSpacing),
        Text(
          '${date.day}',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: tokens.dateDayFontSize,
                fontWeight: FontWeight.w700,
                color: dayColor,
              ),
        ),
        Text(
          weekdayShort(date).toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: tokens.dateWeekdayFontSize,
                color: weekdayColor,
              ),
        ),
        SizedBox(height: tokens.dateDotSpacing),
        Container(
          width: tokens.dateDotSize,
          height: tokens.dateDotSize,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
