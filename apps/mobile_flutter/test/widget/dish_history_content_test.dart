import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/features/dish_detail/dish_history_content.dart';

void main() {
  testWidgets('Dish Notes render as standalone Journal entries', (
    WidgetTester tester,
  ) async {
    const String noteId = 'note-standalone';
    final Dish dish = Dish(
      id: 'dish-1',
      title: 'Ramen',
      description: '',
      heroImageUrl: '',
      category: 'Ideas',
      prepMinutes: 0,
      difficulty: 'Draft',
      madeCount: 1,
      lastMadeLabel: 'Today',
      ingredients: const <String>[],
      recipeSteps: const <String>[],
      notes: const <DishNote>[
        DishNote(
          id: noteId,
          dishId: 'dish-1',
          body: 'Serve with lime.',
          position: 0,
        ),
      ],
      sourcePhotos: const <SourcePhoto>[
        SourcePhoto(url: '', capturedLabel: 'Today'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: DishHistoryContent(dish: dish)),
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('dish_note_$noteId')), findsOne);
    expect(find.text('Serve with lime.'), findsOne);
  });
}
