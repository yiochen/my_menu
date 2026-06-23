import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/core/database/app_database.dart';

import '../support/network_image_test_helper.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('user can add a dish idea and see it classifying', (
    WidgetTester tester,
  ) async {
    await runWithMockNetworkImages(() async {
      await tester.pumpWidget(_testApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('plan_screen')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('capture_fab')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Idea'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'gochujang noodles',
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
}

Widget _testApp() {
  return MyMenuApp(
    database: AppDatabase.forTesting(NativeDatabase.memory()),
  );
}
