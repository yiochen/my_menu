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

  testWidgets('renders detail journal and recipe', (
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
    expect(find.text('Journal'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView).first, const Offset(0, -520));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('journal_add_note')), findsOneWidget);
    expect(find.text('July 18, 2026'), findsAtLeastNWidgets(1));
    expect(find.textContaining('crispy edges'), findsAtLeastNWidgets(1));

    await tester.drag(
      find.byKey(const ValueKey<String>('dish_detail_page_view')),
      const Offset(-320, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ingredients'), findsOneWidget);

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
