import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';

void main() {
  testWidgets('dish titles never override their stored cover', (
    WidgetTester tester,
  ) async {
    const String capturedPhoto = '/captures/clam-noodle.jpg';
    final Dish dish = Dish(
      id: 'user-dish',
      title: 'Clam Noodle Dish',
      description: '',
      heroImageUrl: capturedPhoto,
      category: 'Pasta',
      prepMinutes: 0,
      difficulty: 'Not set',
      madeCount: 0,
      lastMadeLabel: 'Not cooked yet',
      ingredients: const <String>[],
      recipeSteps: const <String>[],
      notes: const <DishNote>[],
      sourcePhotos: const <SourcePhoto>[],
    );

    await tester.pumpWidget(
      MaterialApp(home: DishArtwork(dish: dish)),
    );

    expect(
        tester.widget<AppImage>(find.byType(AppImage)).imageRef, capturedPhoto);
  });

  test('explicit asset references resolve to bundled artwork', () {
    final ImageProvider provider = AppImageResolver.providerFor(
      'asset://assets/dish_art/linguine.png',
    );

    expect(provider, isA<AssetImage>());
    expect((provider as AssetImage).assetName, 'assets/dish_art/linguine.png');
  });
}
