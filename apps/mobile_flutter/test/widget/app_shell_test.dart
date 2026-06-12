import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';

import '../support/network_image_test_helper.dart';

void main() {
  group('MyMenu app shell', () {
    testWidgets('shows plan screen content on launch', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(const MyMenuApp());
        await tester.pumpAndSettle();

        expect(find.text('What are we cooking this week?'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Cook Tonight'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
      });

      expect(find.text('Cook Tonight'), findsOneWidget);
      expect(
          find.widgetWithText(FloatingActionButton, 'Capture'), findsOneWidget);
    });

    testWidgets('can add a dish idea from the capture flow', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(const MyMenuApp());
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FloatingActionButton, 'Capture'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add dish idea'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextFormField),
          'crispy tofu bowls',
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'crispy tofu');
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('Crispy Tofu Bowls'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
      });

      expect(find.text('Crispy Tofu Bowls'), findsOneWidget);
    });
  });
}
