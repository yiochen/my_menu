import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';

import '../support/network_image_test_helper.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('user can capture and retain an idea', (
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
        'gochujang noodles',
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
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _testApp() {
  return MyMenuApp(
    database: AppDatabase.forTesting(NativeDatabase.memory()),
    networkStatusMonitor: const InertNetworkStatusMonitor(),
  );
}
