import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/core/database/app_database.dart';

import '../support/network_image_test_helper.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('MyMenu app shell', () {
    testWidgets('shows the redesigned plan screen on launch', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey<String>('plan_screen')),
          findsOneWidget,
        );
        expect(find.text('Wednesday, July 22'), findsOneWidget);
        expect(find.text('2 dishes planned'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('2 captures need a quick look'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('2 captures need a quick look'), findsOneWidget);
        expect(find.byKey(const ValueKey('capture_fab')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('can save a dish idea from the capture-first flow', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('capture_fab')));
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
          'crispy tofu bowls',
        );
        await tester.enterText(
          find.byKey(const ValueKey<String>('idea_note_field')),
          'Use the sesame glaze.',
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
        expect(find.byKey(const ValueKey('capture_fab')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('can add a dish detail note without teardown errors', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();
        final Finder linguineCard = find.byKey(
          const ValueKey<String>('menu_dish_dish_linguine'),
        );
        await tester.scrollUntilVisible(
          linguineCard,
          220,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(linguineCard);
        await tester.pumpAndSettle();
        await tester.tap(linguineCard);
        await tester.pumpAndSettle();

        expect(find.text('Cook again'), findsOneWidget);
        await tester.drag(find.byType(ListView).first, const Offset(0, -360));
        await tester.pumpAndSettle();
        final Finder notesTab = find.textContaining('Notes ·');
        expect(notesTab, findsOneWidget);
        await tester.tap(notesTab);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add Note'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey<String>('dish_note_input')),
          'Smoky garlic next time.',
        );
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Smoky garlic'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('removes and restores a planned dish with Undo', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();

        final Finder meal = find.byKey(
          const ValueKey<String>('planned_meal_plan_today_0'),
        );
        final Finder more = find.descendant(
          of: meal,
          matching: find.byIcon(Icons.more_horiz_rounded),
        );
        await tester.tap(more);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Remove from plan'));
        await tester.pumpAndSettle();

        expect(meal, findsNothing);
        expect(find.text('Undo'), findsOneWidget);
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();
        expect(
          find.text('Miso Salmon Bowl'),
          findsAtLeastNWidgets(1),
        );
      });
    });
  });
}

Widget _testApp() {
  return MyMenuApp(
    database: AppDatabase.forTesting(NativeDatabase.memory()),
  );
}
