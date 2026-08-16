import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/plan/plan_sheets.dart';
import 'package:mymenu/shared/theme/app_theme.dart';

void main() {
  testWidgets('picker preselects existing meals and saves multiple dishes', (
    WidgetTester tester,
  ) async {
    final DateTime date = DateTime(2026, 8, 11);
    final String dayKey = dayKeyForDate(date);
    final MyMenuState state = MyMenuState.forTesting(
      dishes: <Dish>[seededDishes.first, seededDishes[1]],
      plan: <PlannedMeal>[
        PlannedMeal(
          id: 'existing',
          dayKey: dayKey,
          dishId: seededDishes.first.id,
          label: 'Dinner',
        ),
      ],
    );
    addTearDown(state.dispose);
    await _pumpLauncher(tester, state, date);

    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);
    await tester.tap(find.text(seededDishes[1].title));
    await tester.pump();
    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('plan_save_dishes')));
    await tester.pumpAndSettle();

    expect(
      state
          .plannedMealsForDay(dayKey)
          .map((PlannedMeal meal) => meal.dishId)
          .toSet(),
      <String>{seededDishes.first.id, seededDishes[1].id},
    );
  });

  testWidgets('Clear all can save an empty day', (WidgetTester tester) async {
    final DateTime date = DateTime(2026, 8, 11);
    final String dayKey = dayKeyForDate(date);
    final MyMenuState state = MyMenuState.forTesting(
      dishes: <Dish>[seededDishes.first],
      plan: <PlannedMeal>[
        PlannedMeal(
          id: 'existing',
          dayKey: dayKey,
          dishId: seededDishes.first.id,
        ),
      ],
    );
    addTearDown(state.dispose);
    await _pumpLauncher(tester, state, date);

    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('plan_clear_all_dishes')),
    );
    await tester.pump();
    expect(find.text('0 selected'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('plan_save_dishes')));
    await tester.pumpAndSettle();

    expect(state.plannedMealsForDay(dayKey), isEmpty);
  });
}

Future<void> _pumpLauncher(
  WidgetTester tester,
  MyMenuState state,
  DateTime date,
) async {
  await tester.pumpWidget(
    MyMenuScope(
      notifier: state,
      child: MaterialApp(
        theme: AppTheme.data,
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () => showPlanPickerSheet(context, state, date: date),
              child: const Text('Open picker'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}
