part of 'plan_timeline.dart';

class _PlanLabelChip extends StatelessWidget {
  const _PlanLabelChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final PlanThemeTokens tokens = context.planTheme;
    final Color background = switch (label) {
      'Lunch' => const Color(0xFFF8EAC1),
      'Dinner' => const Color(0xFFDDEAD8),
      _ => const Color(0xFFE7E1F6),
    };

    return Container(
      padding: tokens.labelChipPadding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(tokens.labelChipRadius),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: tokens.labelFontSize,
              color: const Color(0xFF4F4B45),
            ),
      ),
    );
  }
}
