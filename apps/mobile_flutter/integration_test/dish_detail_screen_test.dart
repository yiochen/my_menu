import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/core/database/app_database.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('renders detail, notes, and cooking history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyMenuApp(database: AppDatabase.forTesting(NativeDatabase.memory())),
    );
    await _pumpUntilFound(tester, find.text('Menu'));

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    final Finder salmonCard = find.byKey(
      const ValueKey<String>('menu_dish_dish_salmon'),
    );
    await tester.scrollUntilVisible(
      salmonCard,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(salmonCard);
    await tester.tap(salmonCard);
    await _pumpUntilFound(tester, find.text('Cook again'));

    expect(find.text('Improve cover'), findsOneWidget);
    expect(find.text('Recipe'), findsOneWidget);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Notes · 3'));
    await tester.pumpAndSettle();
    expect(find.text('Add Note'), findsOneWidget);

    await tester.tap(find.text('History · 8'));
    await tester.pumpAndSettle();
    expect(find.text('8 times made'), findsOneWidget);
    expect(find.textContaining('12 source photos'), findsOneWidget);
    expect(find.text('July 18, 2026'), findsOneWidget);

    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('dish-detail-history-redesign');
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 250),
  int maxPumps = 80,
}) async {
  for (int index = 0; index < maxPumps; index += 1) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure(
    'Timed out waiting for ${finder.describeMatch(Plurality.one)}.',
  );
}
