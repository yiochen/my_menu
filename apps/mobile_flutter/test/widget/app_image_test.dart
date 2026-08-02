import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/food_cover_placeholder.dart';

void main() {
  testWidgets('empty image references use the food cover placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: AppImage(imageRef: '')),
    );

    expect(find.byType(FoodCoverPlaceholder), findsOneWidget);
  });

  testWidgets('unreadable real media uses the food cover placeholder', (
    WidgetTester tester,
  ) async {
    final Directory directory = Directory.systemTemp.createTempSync(
      'mymenu-unreadable-media-',
    );
    addTearDown(() => directory.deleteSync(recursive: true));
    final File unreadable = File('${directory.path}/missing-capture.jpg');

    await tester.pumpWidget(
      MaterialApp(home: AppImage(imageRef: unreadable.uri.toString())),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();

    expect(find.byType(FoodCoverPlaceholder), findsOneWidget);
  });
}
