import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/app/home_shell.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/processing/processing_consent_prompt.dart';
import 'package:mymenu/shared/theme/app_theme.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('launches and captures an idea', (WidgetTester tester) async {
    final MyMenuState state = MyMenuState();
    addTearDown(state.dispose);
    await tester.pumpWidget(
      MyMenuScope(
        notifier: state,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.data,
          home: const ProcessingConsentPromptHost(child: HomeShell()),
        ),
      ),
    );
    await _pumpUntilFound(
      tester,
      find.byKey(const ValueKey<String>('plan_screen')),
    );

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
    await tester.pumpAndSettle();

    expect(find.text('Add an idea'), findsNothing);
    expect(find.byKey(const ValueKey<String>('plan_screen')), findsOneWidget);
    expect(state.dishes.first.title, 'Black Bean Tacos');
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
