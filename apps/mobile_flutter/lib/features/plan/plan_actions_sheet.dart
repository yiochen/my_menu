part of 'plan_sheets.dart';

Future<void> showPlanActionsSheet(
  BuildContext context,
  MyMenuState state, {
  required PlannedMeal meal,
  required DateTime currentDate,
}) async {
  final _PlanActionIntent? intent =
      await showModalBottomSheet<_PlanActionIntent>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => _PlanActionsSheet(
      state: state,
      meal: meal,
      currentDate: currentDate,
    ),
  );
  if (intent == null || !context.mounted) {
    return;
  }
  switch (intent.type) {
    case _PlanActionType.move:
      await runLocalWriteWithFeedback(
        context,
        () => state.movePlannedMeal(
          meal.id,
          targetDayKey: intent.targetDayKey!,
          targetIndex: 0,
        ),
      );
    case _PlanActionType.open:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DishDetailScreen(dishId: meal.dishId),
        ),
      );
    case _PlanActionType.remove:
      final Dish dish = state.dishById(meal.dishId);
      final bool removed = await runLocalWriteWithFeedback(
        context,
        () => state.removePlannedMeal(meal.id),
      );
      if (!removed || !context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 98),
          backgroundColor: Colors.white,
          content: Text(
            '${dish.title} removed',
            style: const TextStyle(color: MyMenuColors.ink),
          ),
          action: SnackBarAction(
            label: 'Undo',
            textColor: MyMenuColors.orangeDark,
            onPressed: () => runLocalWriteWithFeedback(
              context,
              () => state.addPlannedMeal(
                meal.dayKey,
                meal.dishId,
                label: meal.label,
              ),
            ),
          ),
        ),
      );
  }
}

enum _PlanActionType { move, open, remove }

class _PlanActionIntent {
  const _PlanActionIntent(this.type, {this.targetDayKey});

  final _PlanActionType type;
  final String? targetDayKey;
}

class _PlanActionsSheet extends StatelessWidget {
  const _PlanActionsSheet({
    required this.state,
    required this.meal,
    required this.currentDate,
  });

  final MyMenuState state;
  final PlannedMeal meal;
  final DateTime currentDate;

  @override
  Widget build(BuildContext context) {
    final Dish dish = state.dishById(meal.dishId);
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: WarmPage(
        includeBottomChromeSpace: false,
        topPadding: 10,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SheetTopBar(
              title: 'Planned dish',
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            WarmCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: SizedBox(
                      width: 54,
                      height: 54,
                      child: DishArtwork(dish: dish),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(dish.title,
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          '${_weekdays[currentDate.weekday - 1]}, '
                          '${_months[currentDate.month - 1]} ${currentDate.day} '
                          '· ${meal.label ?? 'Dinner'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            WarmCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  PlanSheetActionRow(
                    icon: Icons.redo_rounded,
                    title: 'Move to another day',
                    subtitle: 'Keep it planned, change the date',
                    onTap: () => _move(context),
                  ),
                  PlanSheetActionRow(
                    icon: Icons.open_in_new_rounded,
                    title: 'Open dish',
                    subtitle: 'Recipe, notes, and history',
                    onTap: () => Navigator.pop(
                      context,
                      const _PlanActionIntent(_PlanActionType.open),
                    ),
                  ),
                  const Divider(height: 1),
                  PlanSheetActionRow(
                    icon: Icons.remove_circle_outline,
                    title: 'Remove from plan',
                    subtitle: 'The dish stays in your menu',
                    destructive: true,
                    showChevron: false,
                    onTap: () => Navigator.pop(
                      context,
                      const _PlanActionIntent(_PlanActionType.remove),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const StatusStrip(
              icon: Icons.info_outline,
              text: 'Removing a plan never deletes the dish or its history.',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _move(BuildContext context) async {
    final DateTime? target = await showDatePicker(
      context: context,
      initialDate: currentDate.add(const Duration(days: 1)),
      firstDate: DateTime(2026, 7, 20),
      lastDate: DateTime(2026, 8, 31),
    );
    if (target == null || !context.mounted) {
      return;
    }
    Navigator.pop(
      context,
      _PlanActionIntent(
        _PlanActionType.move,
        targetDayKey: dayKeyForDate(target),
      ),
    );
  }
}
