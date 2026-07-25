import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mymenu/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('launches and captures an idea', (WidgetTester tester) async {
    await app.main();
    await _pumpUntilFound(
      tester,
      find.byKey(const ValueKey<String>('plan_screen')),
    );

    await tester.tap(find.byKey(const ValueKey('capture_fab')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Add Idea'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Add Idea'));
    await _pumpUntilFound(
      tester,
      find.byKey(const ValueKey<String>('idea_title_field')),
    );

    await tester.enterText(
      find.byKey(const ValueKey<String>('idea_title_field')),
      'black bean tacos',
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
    'Timed out waiting for ${finder.describeMatch(Plurality.one)}.',
  );
}
