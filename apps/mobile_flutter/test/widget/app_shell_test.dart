import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/core/database/app_database.dart';

import '../support/network_image_test_helper.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('MyMenu app shell', () {
    testWidgets('shows plan screen content on launch', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey<String>('plan_screen')),
          findsOneWidget,
        );

        await tester.scrollUntilVisible(
          find.text('Cook Tonight?'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
      });

      expect(find.text('Cook Tonight?'), findsOneWidget);
      expect(find.byKey(const ValueKey('capture_fab')), findsOneWidget);
    });

    testWidgets('can add a dish idea from the capture flow', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('capture_fab')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add Idea'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextFormField),
          'crispy tofu bowls',
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));

        await tester.scrollUntilVisible(
          find.text('1 capture in feed'),
          200,
          scrollable: find.byType(Scrollable).first,
        );

        expect(find.text('1 capture in feed'), findsOneWidget);
        expect(
          find.text('Track upload and fake API classification.'),
          findsOneWidget,
        );
      });
    });

    testWidgets('can add a dish detail note without widget teardown errors', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Lemon Garlic Linguine').first);
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Add Note'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add Note'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          'Smoky garlic next time.',
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Smoky garlic'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('shows the trash target while dragging a planned dish', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();

        final Finder firstPlannedMeal = find.byKey(
          const ValueKey<String>('planned_meal_plan_today_0'),
        );
        expect(firstPlannedMeal, findsOneWidget);

        final TestGesture gesture = await tester.startGesture(
          tester.getCenter(firstPlannedMeal),
        );
        await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
        expect(find.byKey(const ValueKey('plan_trash_target')), findsOneWidget);

        await gesture.up();
        await tester.pumpAndSettle();
      });
    });
  });
}

Widget _testApp() {
  return MyMenuApp(
    database: AppDatabase.forTesting(NativeDatabase.memory()),
  );
}
