import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/domain/sync/repositories.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';
import 'package:mymenu/features/menu/menu_screen.dart';
import 'package:mymenu/features/plan/plan_dish_dialog.dart';
import 'package:mymenu/shared/theme/app_theme.dart';

import '../support/network_image_test_helper.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('user can capture and retain an idea', (
    WidgetTester tester,
  ) async {
    await runWithMockNetworkImages(() async {
      final AppDatabase database =
          AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await tester.pumpWidget(_testApp(database));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('capture_fab')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Add Idea'),
        120,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Add Idea'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey<String>('idea_title_field')),
        'gochujang noodles',
      );
      await tester.enterText(
        find.byKey(const ValueKey<String>('idea_note_field')),
        'Try sesame and scallions.',
      );
      await tester.scrollUntilVisible(
        find.text('Save idea'),
        120,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Save idea'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Add an idea'), findsNothing);
      expect(find.byKey(const ValueKey<String>('plan_screen')), findsOneWidget);
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );
      final Dish saved = (await repositories.dishRepository.listDishes())
          .singleWhere((Dish dish) => dish.title == 'Gochujang Noodles');
      expect(saved.notes.single.body, 'Try sesame and scallions.');
      expect(await database.select(database.syncOperations).get(), isEmpty);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('user can edit a recipe locally', (WidgetTester tester) async {
    await runWithMockNetworkImages(() async {
      final AppDatabase database =
          AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );
      await repositories.seedIfNeeded();
      final MyMenuState state = MyMenuState(
        repositories: repositories,
        networkStatusMonitor: const InertNetworkStatusMonitor(),
      );
      addTearDown(state.dispose);
      await tester.pumpWidget(
        MyMenuScope(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.data,
            home: const DishDetailScreen(dishId: 'dish_salmon'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Recipe'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey<String>('recipe_section_input')),
        'Salmon|2 fillets\nWhite miso|2 tbsp',
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('save_recipe_section')),
      );
      await tester.pumpAndSettle();

      final Dish saved = (await repositories.dishRepository.listDishes())
          .singleWhere((Dish dish) => dish.id == 'dish_salmon');
      expect(
          saved.ingredients, <String>['Salmon|2 fillets', 'White miso|2 tbsp']);
      expect(await database.select(database.syncOperations).get(), isEmpty);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('user can add a note and favorite a dish locally', (
    WidgetTester tester,
  ) async {
    await runWithMockNetworkImages(() async {
      final AppDatabase database =
          AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: FakeMyMenuApiClient(),
      );
      await repositories.seedIfNeeded();
      final MyMenuState state = MyMenuState(
        repositories: repositories,
        networkStatusMonitor: const InertNetworkStatusMonitor(),
      );
      addTearDown(state.dispose);
      await tester.pumpWidget(
        MyMenuScope(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.data,
            home: const DishDetailScreen(dishId: 'dish_katsu'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Favorite'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('journal_add_note')),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey<String>('dish_note_input')),
        'Use the wide skillet.',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final Dish saved = (await repositories.dishRepository.listDishes())
          .singleWhere((Dish dish) => dish.id == 'dish_katsu');
      expect(saved.isFavorite, isTrue);
      expect(saved.notes.last.body, 'Use the wide skillet.');
      expect(await database.select(database.syncOperations).get(), isEmpty);
    });
  });

  testWidgets('user can add a dish to the local plan', (
    WidgetTester tester,
  ) async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.seedIfNeeded();
    final MyMenuState state = MyMenuState(
      repositories: repositories,
      networkStatusMonitor: const InertNetworkStatusMonitor(),
    );
    addTearDown(state.dispose);
    final int before =
        (await database.select(database.plannedMeals).get()).length;
    final String dayKey = dayKeyForDate(state.remainingPlanDates().first);
    await tester.pumpWidget(
      MyMenuScope(
        notifier: state,
        child: MaterialApp(
          theme: AppTheme.data,
          home: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () => showPlanDishDialog(
                context,
                state,
                initialDayKey: dayKey,
              ),
              child: const Text('Open planner'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open planner'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();

    final List<PlannedMealRow> saved =
        await database.select(database.plannedMeals).get();
    expect(saved, hasLength(before + 1));
    expect(saved.last.dayKey, dayKey);
    expect(await database.select(database.syncOperations).get(), isEmpty);
  });

  testWidgets('user can commit a local dish deletion', (
    WidgetTester tester,
  ) async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.seedIfNeeded();
    final MyMenuState state = MyMenuState(
      repositories: repositories,
      networkStatusMonitor: const InertNetworkStatusMonitor(),
    );
    addTearDown(state.dispose);
    await tester.pumpWidget(
      MyMenuScope(
        notifier: state,
        child: MaterialApp(
          theme: AppTheme.data,
          home: Scaffold(
            body: MenuScreen(
              query: '',
              onQueryChanged: (_) {},
              onOpenPhotos: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(
      find.byKey(const ValueKey<String>('menu_dish_dish_katsu')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('menu_delete_selected')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('menu_confirm_delete')),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    await tester.pump();

    expect(
      await (database.select(database.dishes)
            ..where((Dishes table) => table.id.equals('dish_katsu')))
          .getSingleOrNull(),
      isNull,
    );
    expect(await database.select(database.syncOperations).get(), isEmpty);
  });
}

Widget _testApp(AppDatabase database) {
  return MyMenuApp(
    database: database,
    networkStatusMonitor: const InertNetworkStatusMonitor(),
    showDebugPanel: false,
  );
}
