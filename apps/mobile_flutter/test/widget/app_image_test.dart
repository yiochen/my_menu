import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/food_cover_placeholder.dart';

void main() {
  test('local paths resolve without requiring a synchronous existence check',
      () {
    final ImageProvider provider = AppImageResolver.providerFor(
      '/captures/not-downloaded-yet.jpg',
    );

    expect(provider, isA<FileImage>());
  });

  testWidgets('empty image references use the food cover placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: AppImage(imageRef: '')),
    );

    expect(find.byType(FoodCoverPlaceholder), findsOneWidget);
  });

  testWidgets('bounded images decode near their physical display width', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(devicePixelRatio: 2),
          child: Center(
            child: SizedBox(
              width: 100,
              height: 80,
              child: AppImage(
                imageRef: '/captures/dish.jpg',
                resizeForDisplay: true,
              ),
            ),
          ),
        ),
      ),
    );

    final Image image = tester.widget<Image>(
      find.byWidgetPredicate(
        (Widget widget) => widget is Image && widget.image is ResizeImage,
      ),
    );
    final ResizeImage provider = image.image as ResizeImage;
    expect(provider.width, 250);
    expect(provider.height, isNull);
  });

  testWidgets('full-resolution surfaces keep the original image provider', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 100,
          height: 80,
          child: AppImage(imageRef: '/captures/dish-detail.jpg'),
        ),
      ),
    );

    final Image image = tester.widget<Image>(
      find.byWidgetPredicate(
        (Widget widget) => widget is Image && widget.image is FileImage,
      ),
    );
    expect(image.image, isA<FileImage>());
  });

  testWidgets('shows a food placeholder until the first image frame', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 100,
          height: 80,
          child: AppImage(imageRef: '/captures/loading-dish.jpg'),
        ),
      ),
    );

    expect(find.byType(FoodCoverPlaceholder), findsOneWidget);
  });

  testWidgets('shows a pixelated tiny image while the card image loads', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 100,
          height: 80,
          child: AppImage(
            imageRef: '/thumbnails/dish.jpg',
            placeholderImageRef: '/placeholders/dish.jpg',
          ),
        ),
      ),
    );

    final Image placeholder = tester.widget<Image>(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Image &&
            widget.image is FileImage &&
            (widget.image as FileImage).file.path.contains('/placeholders/'),
      ),
    );
    expect(placeholder.filterQuality, FilterQuality.none);
    expect(find.byType(FoodCoverPlaceholder), findsNothing);
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
