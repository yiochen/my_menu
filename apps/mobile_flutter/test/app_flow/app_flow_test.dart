import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';

import '../support/network_image_test_helper.dart';

void main() {
  testWidgets('user can add and find a new dish idea', (
    WidgetTester tester,
  ) async {
    await runWithMockNetworkImages(() async {
      await tester.pumpWidget(const MyMenuApp());
      await tester.pumpAndSettle();

      expect(find.text('What are we cooking this week?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FloatingActionButton, 'Capture'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add dish idea'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'gochujang noodles',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'gochujang');
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Gochujang Noodles'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    });

    expect(find.text('Gochujang Noodles'), findsOneWidget);
  });
}
