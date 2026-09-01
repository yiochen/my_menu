import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/features/dish_detail/dish_history_content.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

void main() {
  testWidgets('empty Journal message sits directly on the page background', (
    WidgetTester tester,
  ) async {
    final Dish dish = Dish(
      id: 'empty-dish',
      title: 'Rice',
      description: '',
      heroImageUrl: '',
      category: 'Ideas',
      prepMinutes: 0,
      difficulty: 'Draft',
      lastMadeLabel: '',
      ingredients: const <String>[],
      recipeSteps: const <String>[],
      notes: const <DishNote>[],
      sourcePhotos: const <SourcePhoto>[],
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DishHistoryContent(dish: dish))),
    );

    expect(find.text('No journal entries yet'), findsOneWidget);
    expect(find.byType(WarmCard), findsNothing);
  });

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

  testWidgets('Journal interleaves entries by added time, not capture time', (
    WidgetTester tester,
  ) async {
    final Dish dish = Dish(
      id: 'dish-1',
      title: 'Ramen',
      description: '',
      heroImageUrl: '',
      category: 'Dinner',
      prepMinutes: 0,
      difficulty: 'Easy',
      lastMadeLabel: 'Today',
      ingredients: const <String>[],
      recipeSteps: const <String>[],
      notes: <DishNote>[
        DishNote(
          id: 'middle-note',
          dishId: 'dish-1',
          body: 'Added between the photos.',
          position: 0,
          createdAt: DateTime.utc(2026, 8, 20),
        ),
      ],
      sourcePhotos: <SourcePhoto>[
        SourcePhoto(
          id: 'older-add',
          url: '',
          capturedLabel: 'Aug 29',
          capturedAt: DateTime.utc(2026, 8, 29),
          addedAt: DateTime.utc(2026, 8, 19),
        ),
        SourcePhoto(
          id: 'newer-add',
          url: '',
          capturedLabel: 'Aug 1',
          capturedAt: DateTime.utc(2026, 8),
          addedAt: DateTime.utc(2026, 8, 21),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: DishHistoryContent(dish: dish)),
        ),
      ),
    );

    final Finder newerPhoto = find.byKey(
      const ValueKey<String>('journal_photo_newer-add'),
    );
    final Finder note = find.byKey(
      const ValueKey<String>('dish_note_middle-note'),
    );
    final Finder olderPhoto = find.byKey(
      const ValueKey<String>('journal_photo_older-add'),
    );
    expect(
        tester.getTopLeft(newerPhoto).dy, lessThan(tester.getTopLeft(note).dy));
    expect(
        tester.getTopLeft(note).dy, lessThan(tester.getTopLeft(olderPhoto).dy));
  });

  testWidgets('Journal groups photos only when they share an ingest id', (
    WidgetTester tester,
  ) async {
    final Dish dish = Dish(
      id: 'dish-1',
      title: 'Ramen',
      description: '',
      heroImageUrl: '',
      category: 'Dinner',
      prepMinutes: 0,
      difficulty: 'Easy',
      lastMadeLabel: '',
      ingredients: const <String>[],
      recipeSteps: const <String>[],
      notes: const <DishNote>[],
      sourcePhotos: const <SourcePhoto>[
        SourcePhoto(
          id: 'ingest-a-first',
          ingestId: 'ingest-a',
          url: '',
          capturedLabel: 'Today',
        ),
        SourcePhoto(
          id: 'ingest-a-second',
          ingestId: 'ingest-a',
          url: '',
          capturedLabel: 'Today',
        ),
        SourcePhoto(
          id: 'ungrouped-first',
          url: '',
          capturedLabel: 'Today',
        ),
        SourcePhoto(
          id: 'ungrouped-second',
          url: '',
          capturedLabel: 'Today',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: DishHistoryContent(dish: dish)),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('journal_photo_ingest-a-first')),
      findsOne,
    );
    expect(
      find.byKey(const ValueKey<String>('journal_photo_ingest-a-second')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('journal_photo_ungrouped-first')),
      findsOne,
    );
    expect(
      find.byKey(const ValueKey<String>('journal_photo_ungrouped-second')),
      findsOne,
    );
  });
}
