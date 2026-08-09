import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/menu/menu_grid_card.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/cover_generation_effect.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/food_cover_placeholder.dart';

void main() {
  testWidgets('dish titles never override their stored cover', (
    WidgetTester tester,
  ) async {
    const String capturedPhoto = '/captures/clam-noodle.jpg';
    const String preview = '/previews/clam-noodle.jpg';
    final Dish dish = Dish(
      id: 'user-dish',
      title: 'Clam Noodle Dish',
      description: '',
      heroImageUrl: capturedPhoto,
      heroPreviewUrl: preview,
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

  testWidgets('ideas without a cover render an explicit placeholder', (
    WidgetTester tester,
  ) async {
    final Dish dish = Dish(
      id: 'idea',
      title: 'Soup idea',
      description: '',
      heroImageUrl: '',
      category: 'Ideas',
      prepMinutes: 0,
      difficulty: 'Draft',
      madeCount: 0,
      lastMadeLabel: 'Not cooked yet',
      ingredients: const <String>[],
      recipeSteps: const <String>[],
      notes: const <DishNote>[],
      sourcePhotos: const <SourcePhoto>[],
    );

    await tester.pumpWidget(MaterialApp(home: DishArtwork(dish: dish)));

    expect(
      find.byKey(const ValueKey<String>('dish_artwork_placeholder')),
      findsOneWidget,
    );
    expect(find.byType(FoodCoverPlaceholder), findsOneWidget);
    final Image placeholder = tester.widget<Image>(find.byType(Image));
    expect(
      (placeholder.image as AssetImage).assetName,
      FoodCoverPlaceholder.assetPath,
    );
  });

  testWidgets('menu cards request display-sized artwork decoding', (
    WidgetTester tester,
  ) async {
    final Dish dish = Dish(
      id: 'menu-dish',
      title: 'Menu Dish',
      description: '',
      heroImageUrl: '/captures/menu-dish.jpg',
      heroPreviewUrl: '/previews/menu-dish.jpg',
      heroThumbnailUrl: '/thumbnails/menu-dish.jpg',
      heroPlaceholderUrl: '/placeholders/menu-dish.jpg',
      category: 'Dinner',
      prepMinutes: 20,
      difficulty: 'Easy',
      madeCount: 1,
      lastMadeLabel: 'Today',
      ingredients: const <String>[],
      recipeSteps: const <String>[],
      notes: const <DishNote>[],
      sourcePhotos: const <SourcePhoto>[],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 180,
            height: 260,
            child: MenuGridCard(dish: dish, onTap: () {}),
          ),
        ),
      ),
    );

    expect(
      tester.widget<AppImage>(find.byType(AppImage)).resizeForDisplay,
      isTrue,
    );
    expect(
      tester.widget<AppImage>(find.byType(AppImage)).imageRef,
      '/thumbnails/menu-dish.jpg',
    );
    expect(
      tester.widget<AppImage>(find.byType(AppImage)).placeholderImageRef,
      '/placeholders/menu-dish.jpg',
    );
    expect(find.byType(CoverGenerationEffect), findsNothing);
  });

  testWidgets('active cover generation applies the contained effect', (
    WidgetTester tester,
  ) async {
    final Dish dish = Dish(
      id: 'generating-dish',
      title: 'Generating Dish',
      description: '',
      heroImageUrl: '/captures/generating.jpg',
      category: 'Dinner',
      prepMinutes: 20,
      difficulty: 'Easy',
      madeCount: 1,
      lastMadeLabel: 'Today',
      ingredients: const <String>[],
      recipeSteps: const <String>[],
      notes: const <DishNote>[],
      sourcePhotos: const <SourcePhoto>[],
    );
    final MyMenuState state = MyMenuState.forTesting(
      dishes: <Dish>[dish],
      processingRequests: <ProcessingOutboxRequest>[
        ProcessingOutboxRequest(
          id: 'cover-request',
          kind: ProcessingRequestKind.coverGeneration,
          subjectId: dish.id,
          payload: const <String, Object?>{},
          deliveryState: ProcessingDeliveryState.submitted,
          adoptionState: ProcessingAdoptionState.awaitingProposal,
          createdAt: DateTime.utc(2026, 8, 9),
          updatedAt: DateTime.utc(2026, 8, 9),
        ),
      ],
    );
    addTearDown(state.dispose);

    await tester.pumpWidget(
      MyMenuScope(
        notifier: state,
        child: MaterialApp(home: DishArtwork(dish: dish)),
      ),
    );

    expect(find.byType(CoverGenerationEffect), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(ImageFiltered),
        matching: find.byType(ClipRect),
      ),
      findsOneWidget,
    );
  });
}
