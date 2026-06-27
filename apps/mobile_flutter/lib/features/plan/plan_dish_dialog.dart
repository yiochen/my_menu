import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';

const List<String> planLabels = <String>['Lunch', 'Dinner', 'Brunch'];

Future<void> showPlanDishDialog(
  BuildContext context,
  MyMenuState state, {
  required String initialDayKey,
  String? initialDishId,
  String? initialLabel,
  PlannedMeal? meal,
}) {
  return showDialog<void>(
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

  @override
  void initState() {
    super.initState();
    _selectedDayKey = widget.initialDayKey;
    _selectedDishId = widget.initialDishId ?? widget.state.dishes.first.id;
    _selectedLabel = widget.initialLabel;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit plan' : 'Add dish'),
      content: _PlanDishForm(
        dates: widget.state.remainingPlanDates(),
        dishes: widget.state.dishes,
        selectedDayKey: _selectedDayKey,
        selectedDishId: _selectedDishId,
        selectedLabel: _selectedLabel,
        onDayChanged: (String value) => setState(() => _selectedDayKey = value),
        onDishChanged: (String value) =>
            setState(() => _selectedDishId = value),
        onLabelChanged: (String? value) =>
            setState(() => _selectedLabel = value),
      ),
      actions: <Widget>[
        if (_isEditing)
          TextButton(
            onPressed: () {
              widget.state.removePlannedMeal(widget.meal!.id);
              Navigator.of(context).pop();
            },
            child: const Text('Remove'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_isEditing) {
              if (widget.meal!.dayKey == _selectedDayKey) {
                widget.state.updatePlannedMeal(
                  widget.meal!.id,
                  _selectedDishId,
                  label: _selectedLabel,
                );
              } else {
                widget.state.removePlannedMeal(widget.meal!.id);
                widget.state.addPlannedMeal(
                  _selectedDayKey,
                  _selectedDishId,
                  label: _selectedLabel,
                );
              }
            } else {
              widget.state.addPlannedMeal(
                _selectedDayKey,
                _selectedDishId,
                label: _selectedLabel,
              );
            }

            Navigator.of(context).pop();
          },
          child: Text(_isEditing ? 'Save' : 'Plan'),
        ),
      ],
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
    return SizedBox(
      width: double.maxFinite,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButtonFormField<String>(
              initialValue: selectedDayKey,
              decoration: const InputDecoration(labelText: 'Day'),
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedDishId,
              decoration: const InputDecoration(labelText: 'Dish'),
              items: dishes.map((Dish dish) {
                return DropdownMenuItem<String>(
                  value: dish.id,
                  child: Text(dish.title),
                );
              }).toList(growable: false),
              onChanged: (String? value) {
                if (value != null) {
                  onDishChanged(value);
                }
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Planning label',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ChoiceChip(
                  label: const Text('None'),
                  selected: selectedLabel == null,
                  onSelected: (_) => onLabelChanged(null),
                ),
                for (final String label in planLabels)
                  ChoiceChip(
                    label: Text(label),
                    selected: selectedLabel == label,
                    onSelected: (_) => onLabelChanged(label),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _dateLabel(DateTime date) {
  return '${weekdayShort(date)}, ${date.month}/${date.day}';
}
