import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/shared/widgets/app_dialog.dart';
import 'package:mymenu/shared/widgets/local_write_feedback.dart';

const List<String> planLabels = <String>['Lunch', 'Dinner', 'Brunch'];

const Color _dialogGreen = Color(0xFF174B2A);
const Color _dialogCream = Color(0xFFFFFCF7);
const Color _dialogField = Color(0xFFF8F2E8);
const Color _dialogGold = Color(0xFFB06D00);
const Color _dialogBorder = Color(0xFFE8DFD2);
const Color _dialogInk = Color(0xFF253027);

Future<void> showPlanDishDialog(
  BuildContext context,
  MyMenuState state, {
  required String initialDayKey,
  String? initialDishId,
  String? initialLabel,
  PlannedMeal? meal,
}) async {
  final _PlanDishIntent? intent = await showDialog<_PlanDishIntent>(
    context: context,
    builder: (BuildContext context) {
      return _PlanDishDialog(
        state: state,
        initialDayKey: initialDayKey,
        initialDishId: initialDishId,
        initialLabel: initialLabel,
        meal: meal,
      );
    },
  );
  if (intent == null || !context.mounted) {
    return;
  }
  if (intent.remove) {
    await runLocalWriteWithFeedback(
      context,
      () => state.removePlannedMeal(meal!.id),
    );
    return;
  }
  await runLocalWriteWithFeedback(
    context,
    () => state.savePlannedMeal(
      planId: meal?.id,
      dayKey: intent.dayKey,
      dishId: intent.dishId,
      label: intent.label,
    ),
  );
}

class _PlanDishIntent {
  const _PlanDishIntent.save({
    required this.dayKey,
    required this.dishId,
    required this.label,
  }) : remove = false;

  const _PlanDishIntent.remove()
      : dayKey = '',
        dishId = '',
        label = null,
        remove = true;

  final String dayKey;
  final String dishId;
  final String? label;
  final bool remove;
}

class _PlanDishDialog extends StatefulWidget {
  const _PlanDishDialog({
    required this.state,
    required this.initialDayKey,
    this.initialDishId,
    this.initialLabel,
    this.meal,
  });

  final MyMenuState state;
  final String initialDayKey;
  final String? initialDishId;
  final String? initialLabel;
  final PlannedMeal? meal;

  @override
  State<_PlanDishDialog> createState() => _PlanDishDialogState();
}

class _PlanDishDialogState extends State<_PlanDishDialog> {
  late String _selectedDayKey;
  late String _selectedDishId;
  String? _selectedLabel;

  bool get _isEditing => widget.meal != null;

  String get _title {
    if (_isEditing) {
      return 'Edit plan';
    }
    return widget.initialDishId == null ? 'Add to plan' : 'Plan this dish';
  }

  @override
  void initState() {
    super.initState();
    _selectedDayKey = widget.initialDayKey;
    _selectedDishId = widget.initialDishId ?? widget.state.dishes.first.id;
    _selectedLabel = widget.initialLabel;
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: _title,
      subtitle: 'Pick when this belongs on the week and how to label it.',
      icon: Icons.calendar_month_outlined,
      content: _PlanDishForm(
        dates: widget.state.remainingPlanDates(),
        dishes: widget.state.dishes,
        selectedDayKey: _selectedDayKey,
        selectedDishId: _selectedDishId,
        selectedLabel: _selectedLabel,
        onDayChanged: _selectDay,
        onDishChanged: _selectDish,
        onLabelChanged: _selectLabel,
      ),
      actions: <AppDialogAction>[
        if (_isEditing)
          AppDialogAction(
            label: 'Remove',
            icon: Icons.delete_outline,
            isDestructive: true,
            onPressed: _remove,
          ),
        AppDialogAction(
          label: 'Cancel',
          icon: Icons.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppDialogAction(
          label: _isEditing ? 'Save' : 'Plan',
          icon: _isEditing ? Icons.check : Icons.calendar_month_outlined,
          isPrimary: true,
          onPressed: _save,
        ),
      ],
    );
  }

  void _selectDay(String value) => setState(() => _selectedDayKey = value);

  void _selectDish(String value) => setState(() => _selectedDishId = value);

  void _selectLabel(String? value) => setState(() => _selectedLabel = value);

  void _remove() {
    Navigator.of(context).pop(const _PlanDishIntent.remove());
  }

  void _save() {
    Navigator.of(context).pop(
      _PlanDishIntent.save(
        dayKey: _selectedDayKey,
        dishId: _selectedDishId,
        label: _selectedLabel,
      ),
    );
  }
}

class _PlanDishForm extends StatelessWidget {
  const _PlanDishForm({
    required this.dates,
    required this.dishes,
    required this.selectedDayKey,
    required this.selectedDishId,
    required this.selectedLabel,
    required this.onDayChanged,
    required this.onDishChanged,
    required this.onLabelChanged,
  });

  final List<DateTime> dates;
  final List<Dish> dishes;
  final String selectedDayKey;
  final String selectedDishId;
  final String? selectedLabel;
  final ValueChanged<String> onDayChanged;
  final ValueChanged<String> onDishChanged;
  final ValueChanged<String?> onLabelChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButtonFormField<String>(
              initialValue: selectedDayKey,
              isExpanded: true,
              decoration: _fieldDecoration('Day'),
              items: dates.map((DateTime date) {
                final String dayKey = dayKeyForDate(date);
                return DropdownMenuItem<String>(
                  value: dayKey,
                  child: Text(_dateLabel(date)),
                );
              }).toList(growable: false),
              onChanged: (String? value) {
                if (value != null) {
                  onDayChanged(value);
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedDishId,
              isExpanded: true,
              decoration: _fieldDecoration('Dish'),
              items: dishes.map((Dish dish) {
                return DropdownMenuItem<String>(
                  value: dish.id,
                  child: Text(
                    dish.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(growable: false),
              onChanged: (String? value) {
                if (value != null) {
                  onDishChanged(value);
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Planning label',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _dialogInk,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            _PlanLabelSelector(
              selectedLabel: selectedLabel,
              onChanged: onLabelChanged,
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: _dialogField,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _dialogBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _dialogGold, width: 2),
    ),
  );
}

class _PlanLabelSelector extends StatelessWidget {
  const _PlanLabelSelector({
    required this.selectedLabel,
    required this.onChanged,
  });

  final String? selectedLabel;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<String?> labels = <String?>[null, ...planLabels];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double itemWidth = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: labels.map((String? label) {
            final bool selected = selectedLabel == label;
            return SizedBox(
              width: itemWidth,
              child: ChoiceChip(
                label: SizedBox(
                  width: double.infinity,
                  child: Text(
                    label ?? 'None',
                    textAlign: TextAlign.center,
                  ),
                ),
                selected: selected,
                selectedColor: const Color(0xFFF8EAC1),
                backgroundColor: _dialogCream,
                checkmarkColor: _dialogGreen,
                side: BorderSide(
                  color: selected ? _dialogGold : _dialogBorder,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onSelected: (_) => onChanged(label),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

String _dateLabel(DateTime date) {
  const List<String> weekdays = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  return '${weekdays[date.weekday - 1]}, ${date.month}/${date.day}';
}
