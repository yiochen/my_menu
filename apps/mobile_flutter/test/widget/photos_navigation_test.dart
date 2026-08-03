import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/app/home_shell.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';
import 'package:mymenu/domain/capture/captured_media.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/domain/sync/repositories.dart';
import 'package:mymenu/features/capture/capture_media_service.dart';
import 'package:mymenu/shared/theme/app_theme.dart';

void main() {
  testWidgets('menu photo icon opens the gallery and back restores dishes',
      (WidgetTester tester) async {
    final MyMenuState state = MyMenuState.forTesting();
    addTearDown(state.dispose);
    await tester.pumpWidget(
      MyMenuScope(
        notifier: state,
        child: MaterialApp(
          theme: AppTheme.data,
          home: const HomeShell(),
        ),
      ),
    );

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('menu_photos_button')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('menu_photos_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Photos'), findsOneWidget);
    expect(find.text('Your photos will live here'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('photos_back')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('menu_search_field')),
      findsOneWidget,
    );
  });

  testWidgets(
      'capture is immediately usable, can be assigned, filtered, and undone',
      (WidgetTester tester) async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.processingConsentRepository.declineCurrentNotice();
    await repositories.dishRepository.upsertDish(_dish());
    final MyMenuState state = MyMenuState(
      repositories: repositories,
      networkStatusMonitor: const InertNetworkStatusMonitor(),
    );
    addTearDown(state.dispose);
    await state.initialized;
    await tester.pumpWidget(
      MyMenuScope(
        notifier: state,
        child: MaterialApp(
          theme: AppTheme.data,
          home: HomeShell(captureMediaService: _ImportMediaService()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('capture_fab')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import Photos'));
    await tester.pumpAndSettle();
    expect(state.photos, hasLength(1));
    expect(state.unorganizedPhotoCount, 1);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('menu_photos_button')),
    );
    await tester.pumpAndSettle();
    final String captureId = state.photos.single.id;
    final ValueKey<String> tileKey = ValueKey<String>('photo_tile_$captureId');
    expect(find.byKey(tileKey), findsOneWidget);

    await tester.tap(find.byKey(tileKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to a dish'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('photo_dish_dish_test')),
    );
    await tester.pumpAndSettle();
    expect(state.organizedPhotoCount, 1);
    expect(find.byKey(tileKey), findsNothing);

    await tester.tap(find.text('Organized 1'));
    await tester.pumpAndSettle();
    expect(find.byKey(tileKey), findsOneWidget);
    await tester.tap(find.widgetWithText(SnackBarAction, 'Undo'));
    await tester.pumpAndSettle();
    expect(state.unorganizedPhotoCount, 1);
    expect(state.organizedPhotoCount, 0);
  });
}

class _ImportMediaService implements CaptureMediaService {
  @override
  Future<List<CapturedMedia>> importPhotos() async => <CapturedMedia>[
        CapturedMedia(
          path: '/tmp/immediately-usable.jpg',
          capturedAt: DateTime.utc(2026, 8, 2, 18),
          capturedLocalDate: '2026-08-02',
          dateSource: CaptureDateSource.exifOriginal,
        ),
      ];

  @override
  Future<CapturedMedia?> takePhoto() async => null;
}

Dish _dish() {
  return Dish(
    id: 'dish_test',
    title: 'Miso salmon',
    description: '',
    heroImageUrl: '',
    category: '',
    prepMinutes: 0,
    difficulty: '',
    madeCount: 0,
    lastMadeLabel: 'Not cooked yet',
    ingredients: <String>[],
    recipeSteps: <String>[],
    notes: <DishNote>[],
    sourcePhotos: <SourcePhoto>[],
  );
}
