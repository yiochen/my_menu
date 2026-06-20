import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mymenu/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MyMenu Android smoke test', () {
    testWidgets('launches, captures an idea, and finds it in menu search', (
      WidgetTester tester,
    ) async {
      app.main();
      await _pumpUntilFound(
        tester,
        find.byKey(const ValueKey<String>('plan_screen')),
      );

      expect(find.byKey(const ValueKey<String>('plan_screen')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('capture_fab')));
      await tester.pump(const Duration(milliseconds: 500));

      final Finder addDishIdea = find.text('Add Idea');
      await _scrollIntoView(
        tester,
        addDishIdea,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(addDishIdea);
      await _pumpUntilFound(tester, find.byType(TextFormField));

      await tester.enterText(
        find.byType(TextFormField),
        'black bean tacos',
      );
      await tester.tap(find.text('Save'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('Menu'));
      await _pumpUntilFound(
        tester,
        find.byKey(const ValueKey('menu_search_field')),
      );

      await tester.enterText(
        find.byKey(const ValueKey('menu_search_field')),
        'black bean',
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tester.scrollUntilVisible(
        find.text('Black Bean Tacos'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Black Bean Tacos'), findsOneWidget);
    });
  });
}

Future<void> _scrollIntoView(
  WidgetTester tester,
  Finder target, {
  required Finder scrollable,
  double delta = 200,
}) async {
  if (target.evaluate().isNotEmpty) {
    await tester.ensureVisible(target);
    await tester.pump(const Duration(milliseconds: 250));
    return;
  }

  await tester.scrollUntilVisible(
    target,
    delta,
    scrollable: scrollable,
  );
  await tester.pump(const Duration(milliseconds: 250));
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 250),
  int maxPumps = 40,
}) async {
  for (int index = 0; index < maxPumps; index += 1) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  throw TestFailure(
      'Timed out waiting for ${finder.describeMatch(Plurality.one)}.');
}
