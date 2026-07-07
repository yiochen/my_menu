import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/core/database/app_database.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Dish detail screen', () {
    testWidgets('renders editable sections without layout exceptions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MyMenuApp(database: AppDatabase.forTesting(NativeDatabase.memory())),
      );
      await _pumpUntilFound(tester, find.text('Menu'));

      await tester.tap(find.text('Menu'));
      await _pumpUntilFound(tester, find.text('Lemon Garlic Linguine'));

      await tester.tap(find.text('Lemon Garlic Linguine').first);
      await _pumpUntilFound(tester, find.text('Add Note'));

      expect(find.text('Notes'), findsWidgets);
      expect(find.text('Add Note'), findsOneWidget);
      expect(find.textContaining('More lemon'), findsOneWidget);
      expect(find.text('Recipe'), findsWidgets);
      expect(find.text('Ingredients'), findsWidgets);
      expect(find.text('Source Photos'), findsOneWidget);
      expect(find.text('Cook Again'), findsOneWidget);
      expect(find.text('Edit'), findsWidgets);
      expect(tester.takeException(), isNull);

      for (final String assetPath in <String>[
        'assets/dish_detail_notes/note_cheese_pin.png',
        'assets/dish_detail_notes/note_kid_clip.png',
        'assets/dish_detail_notes/note_lemon_pin.png',
        'assets/dish_detail_notes/note_shrimp_tape.png',
      ]) {
        await precacheImage(
          AssetImage(assetPath),
          tester.element(find.text('Add Note')),
        );
      }

      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('dish-detail-screen-current');

      await tester.tap(
        find.byKey(
            const ValueKey<String>('dish_note_card_dish_linguine_note_0')),
      );
      await _pumpUntilFound(tester, find.text('Edit Note'));

      expect(find.text('Edit Note'), findsOneWidget);
      expect(find.text('Delete Note'), findsOneWidget);
      expect(find.byTooltip('Close note'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Close note'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('See all (2)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('See all (2)'));
      await _pumpUntilFound(tester, find.text('1 of 2'));

      expect(find.text('Source Photos'), findsWidgets);
      expect(find.text('1 of 2'), findsOneWidget);
      expect(find.byTooltip('Next photo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 250),
  int maxPumps = 80,
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
