import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/app/home_shell.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/capture/seeded_review_items.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/planning/seeded_plan.dart';
import 'package:mymenu/domain/processing/processing_privacy_notice.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/menu/menu_grid_card.dart';
import 'package:mymenu/features/menu/menu_screen.dart';
import 'package:mymenu/shared/theme/app_theme.dart';

import '../support/network_image_test_helper.dart';
import '../support/tolerant_golden_file_comparator.dart';

const ValueKey<String> _fullAppGoldenKey = ValueKey<String>('full_app_golden');
final DateTime _goldenPlanDate = DateTime(2026, 7, 22);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GoldenFileComparator previousComparator;
  late MyMenuState appState;

  setUpAll(() async {
    await _loadGoldenFonts();
    previousComparator = goldenFileComparator;
    goldenFileComparator = TolerantGoldenFileComparator(
      Uri.parse('test/widget/visual_regression_test.dart'),
      precisionTolerance: 0.12,
    );
  });

  tearDownAll(() {
    goldenFileComparator = previousComparator;
  });

  setUp(() {
    appState = _buildGoldenState();
  });

  tearDown(() {
    appState.dispose();
  });

  group('representative UI goldens at 390×844 logical pixels', () {
    testWidgets('plan home', (WidgetTester tester) async {
      await runWithMockNetworkImages(() async {
        await _pumpGoldenApp(tester, appState);

        expect(find.text('Wednesday, July 22'), findsOneWidget);
        await _expectFullAppGolden(tester, 'ui_plan_home');
      });
    });

    testWidgets('menu home', (WidgetTester tester) async {
      await runWithMockNetworkImages(() async {
        await _pumpGoldenApp(tester, appState);
        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey<String>('menu_compact_search_header')),
          findsOneWidget,
        );
        await _expectFullAppGolden(tester, 'ui_menu_home');
      });
    });

    testWidgets('menu with unorganized photo badge',
        (WidgetTester tester) async {
      final MyMenuState state = _buildPhotoGoldenState();
      addTearDown(state.dispose);
      await runWithMockNetworkImages(() async {
        await _pumpGoldenApp(tester, state);
        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();

        final Finder badge = find.byKey(
          const ValueKey<String>('menu_photos_badge'),
        );
        expect(tester.getSize(badge), const Size.square(18));
        await _expectFullAppGolden(tester, 'ui_menu_unorganized_photos');
      });
    });

    testWidgets('photo gallery', (WidgetTester tester) async {
      final MyMenuState state = _buildPhotoGoldenState();
      addTearDown(state.dispose);
      await runWithMockNetworkImages(() async {
        await _pumpGoldenApp(tester, state);
        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey<String>('menu_photos_button')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('All 3'));
        await tester.pumpAndSettle();

        expect(find.text('Photos'), findsOneWidget);
        expect(find.text('Unorganized 2'), findsOneWidget);
        await _expectFullAppGolden(tester, 'ui_photo_gallery');
      });
    });

    testWidgets('photo detail', (WidgetTester tester) async {
      final MyMenuState state = _buildPhotoGoldenState();
      addTearDown(state.dispose);
      await runWithMockNetworkImages(() async {
        await _pumpGoldenApp(tester, state);
        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey<String>('menu_photos_button')),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey<String>('photo_tile_golden_unorganized')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Add to a dish'), findsOneWidget);
        await _expectFullAppGolden(tester, 'ui_photo_detail');
      });
    });

    testWidgets('empty photo gallery', (WidgetTester tester) async {
      final MyMenuState state = MyMenuState.forTesting(dishes: seededDishes);
      addTearDown(state.dispose);
      await runWithMockNetworkImages(() async {
        await _pumpGoldenApp(tester, state);
        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey<String>('menu_photos_button')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Your photos will live here'), findsOneWidget);
        await _expectFullAppGolden(tester, 'ui_photo_gallery_empty');
      });
    });

    testWidgets('dense photo gallery', (WidgetTester tester) async {
      final MyMenuState state = _buildDensePhotoGoldenState();
      addTearDown(state.dispose);
      await runWithMockNetworkImages(() async {
        await _pumpGoldenApp(tester, state);
        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey<String>('menu_photos_button')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Unorganized 18'), findsOneWidget);
        await _expectFullAppGolden(tester, 'ui_photo_gallery_dense');
      });
    });

    testWidgets('menu multi-select and delete confirmation', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await _pumpGoldenApp(tester, appState);
        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();

        await tester.longPress(find.byType(MenuGridCard).first);
        await tester.pumpAndSettle();
        expect(find.text('1 selected'), findsOneWidget);
        expect(find.text('Delete 1'), findsOneWidget);
        await _expectFullAppGolden(tester, 'ui_menu_multi_select');

        await tester.tap(
          find.byKey(const ValueKey<String>('menu_delete_selected')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Delete this dish?'), findsOneWidget);
        expect(find.textContaining('phone’s library'), findsOneWidget);
        await _expectFullAppGolden(tester, 'ui_menu_delete_confirm');
      });
    });

    testWidgets('two-line dish card has an unclipped title', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await _pumpGoldenApp(tester, appState);
        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();

        final Finder card = find.byKey(
          const ValueKey<String>('menu_dish_dish_katsu'),
        );
        await tester.scrollUntilVisible(
          card,
          180,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(card);
        await tester.pumpAndSettle();

        final Finder title = find.byKey(
          const ValueKey<String>('menu_dish_title_dish_katsu'),
        );
        final Finder metadata = find.text('3 cooks · 5 photos');
        final Rect titleRect = tester.getRect(title);
        final Rect metadataRect = tester.getRect(metadata);

        expect(titleRect.height, greaterThanOrEqualTo(43));
        expect(titleRect.bottom, lessThanOrEqualTo(metadataRect.top));
        expect(tester.takeException(), isNull);
        await _settleGoldenFrame(tester);
        await expectLater(
          card,
          matchesGoldenFile(
            'goldens/ui_menu_dish_card_katsu_'
            '390x844_text_scale_1_15.png',
          ),
        );
      });
    });

    testWidgets('dish grid handles long and empty text across multiple items', (
      WidgetTester tester,
    ) async {
      final List<Dish> edgeDishes = <Dish>[
        seededDishes[0].copyWith(
          title: 'Miso Maple Salmon With Charred Scallions and Crispy Rice',
          description:
              'A deliberately long description that should remain contained.',
        ),
        seededDishes[2].copyWith(
          title: '',
          description: '',
          lastMadeLabel: '',
          sourcePhotos: const <SourcePhoto>[],
        ),
        seededDishes[3],
      ];
      final MyMenuState state = MyMenuState.forTesting(dishes: edgeDishes);
      addTearDown(state.dispose);

      await runWithMockNetworkImages(() async {
        await _pumpGoldenMenu(tester, state);

        expect(
          find.text(
            'Miso Maple Salmon With Charred Scallions and Crispy Rice',
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('menu_dish_dish_salmon')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('menu_dish_dish_katsu')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('menu_dish_dish_pho')),
          findsOneWidget,
        );
        final Text emptyTitle = tester.widget<Text>(
          find.byKey(
            const ValueKey<String>('menu_dish_title_dish_katsu'),
          ),
        );
        expect(emptyTitle.data, isEmpty);
        expect(find.textContaining('0 photos'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await _expectFullAppGolden(tester, 'ui_menu_edge_case_grid');
      });
    });

    testWidgets('menu renders a true no-items state', (
      WidgetTester tester,
    ) async {
      final MyMenuState state = MyMenuState.forTesting();
      addTearDown(state.dispose);

      await runWithMockNetworkImages(() async {
        await _pumpGoldenMenu(tester, state);

        expect(
          find.text('Capture your first cooking moment'),
          findsOneWidget,
        );
        expect(find.text('My Menu'), findsNothing);
        expect(
          find.byKey(const ValueKey<String>('menu_compact_search_header')),
          findsOneWidget,
        );
        expect(find.text('24 dishes'), findsNothing);
        expect(
          find.byKey(const ValueKey<String>('menu_dish_dish_salmon')),
          findsNothing,
        );
        await _expectFullAppGolden(tester, 'ui_menu_no_items');
      });
    });

    testWidgets('menu renders no search results', (
      WidgetTester tester,
    ) async {
      final MyMenuState state = MyMenuState.forTesting(
        dishes: seededDishes,
      );
      addTearDown(state.dispose);

      await runWithMockNetworkImages(() async {
        await _pumpGoldenMenu(
          tester,
          state,
          query: 'a dish that cannot possibly exist',
        );

        expect(find.text('No dish named that—yet'), findsOneWidget);
        expect(find.text('Clear search'), findsOneWidget);
        await _expectFullAppGolden(tester, 'ui_menu_no_search_results');
      });
    });

    testWidgets('dish detail', (WidgetTester tester) async {
      await runWithMockNetworkImages(() async {
        await _pumpGoldenApp(tester, appState);
        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey<String>('menu_dish_dish_salmon')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Cook again'), findsOneWidget);
        expect(find.text('Cover image'), findsNothing);
        final Finder detailScroll = find.byKey(
          const ValueKey<String>('dish_detail_scroll_view'),
        );
        expect(tester.getTopLeft(detailScroll), Offset.zero);
        expect(tester.getBottomRight(detailScroll), const Offset(390, 844));
        expect(tester.widget(detailScroll), isA<NestedScrollView>());
        final SliverPadding headerPadding = tester.widget<SliverPadding>(
          find
              .descendant(
                of: detailScroll,
                matching: find.byType(SliverPadding),
              )
              .first,
        );
        expect(
          headerPadding.padding.resolve(TextDirection.ltr),
          const EdgeInsets.fromLTRB(18, 61, 18, 0),
        );
        expect(
          find.byKey(const ValueKey<String>('dish_detail_page_view')),
          findsOneWidget,
        );
        await _expectFullAppGolden(tester, 'ui_dish_detail');
      });
    });

    testWidgets('capture sheet', (WidgetTester tester) async {
      await runWithMockNetworkImages(() async {
        await _pumpGoldenApp(tester, appState);
        await tester.tap(
          find.byKey(const ValueKey<String>('capture_fab')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Save it while it’s fresh'), findsOneWidget);
        _expectRoundedModalSheetClip(tester);
        await _expectFullAppGolden(tester, 'ui_capture_sheet');
      });
    });

    testWidgets('add-idea sheet', (WidgetTester tester) async {
      await runWithMockNetworkImages(() async {
        await _pumpGoldenApp(tester, appState);
        await tester.tap(
          find.byKey(const ValueKey<String>('capture_fab')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add Idea'));
        await tester.pumpAndSettle();

        expect(find.text('What do you wanna cook?'), findsOneWidget);
        _expectRoundedModalSheetClip(tester);
        await _expectFullAppGolden(tester, 'ui_add_idea_sheet');
      });
    });

    testWidgets('review sheet', (WidgetTester tester) async {
      await runWithMockNetworkImages(() async {
        await _pumpGoldenApp(tester, appState);
        final Finder reviewBadge = find.byKey(
          const ValueKey<String>('menu_review_badge'),
        );
        expect(reviewBadge, findsOneWidget);
        await tester.tap(reviewBadge);
        await tester.pumpAndSettle();

        expect(find.text('Where should this go?'), findsOneWidget);
        _expectRoundedModalSheetClip(tester);
        await _expectFullAppGolden(tester, 'ui_review_sheet');
      });
    });
  });
}

Future<void> _pumpGoldenApp(
  WidgetTester tester,
  MyMenuState state,
) async {
  _configureGoldenViewport(tester);

  await tester.pumpWidget(
    RepaintBoundary(
      key: _fullAppGoldenKey,
      child: MyMenuScope(
        notifier: state,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.data,
          home: const HomeShell(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _expectRoundedModalSheetClip(WidgetTester tester) {
  final BuildContext sheetContext = tester.element(
    find.byType(BottomSheet).last,
  );
  expect(
    Theme.of(sheetContext).bottomSheetTheme.clipBehavior,
    Clip.antiAlias,
  );
}

MyMenuState _buildGoldenState() {
  // Keep every variable fixture independent of the wall clock. If a future
  // golden exposes a date, it should continue to render July 22, 2026.
  return MyMenuState.forTesting(
    dishes: <Dish>[
      seededDishes.first.copyWith(createdAt: DateTime(2026, 7, 22)),
      ...seededDishes.skip(1),
    ],
    plan: buildSeededPlan(_goldenPlanDate),
    reviewItems: seededReviewItems,
    processingConsentDecision: ProcessingConsentDecision.accepted,
  );
}

MyMenuState _buildPhotoGoldenState() {
  final DateTime capturedAt = DateTime(2026, 7, 22, 18, 30);
  return MyMenuState.forTesting(
    dishes: seededDishes,
    captureItems: <CaptureItem>[
      CaptureItem(
        id: 'golden_unorganized',
        batchId: 'golden_batch',
        kind: CaptureItemKind.photo,
        status: CaptureItemStatus.localOnly,
        createdAt: capturedAt,
        capturedAt: capturedAt,
        capturedLocalDate: '2026-07-22',
        localMediaRef: seededDishes[0].heroImageUrl,
      ),
      CaptureItem(
        id: 'golden_review',
        batchId: 'golden_review_batch',
        kind: CaptureItemKind.photo,
        status: CaptureItemStatus.needsReview,
        createdAt: capturedAt.subtract(const Duration(minutes: 8)),
        capturedAt: capturedAt.subtract(const Duration(minutes: 8)),
        capturedLocalDate: '2026-07-22',
        localMediaRef: seededDishes[1].heroImageUrl,
      ),
      CaptureItem(
        id: 'golden_organized',
        batchId: 'golden_organized_batch',
        kind: CaptureItemKind.photo,
        status: CaptureItemStatus.applied,
        createdAt: capturedAt.subtract(const Duration(days: 1)),
        capturedAt: capturedAt.subtract(const Duration(days: 1)),
        capturedLocalDate: '2026-07-21',
        localMediaRef: seededDishes[2].heroImageUrl,
        appliedDishId: seededDishes[2].id,
      ),
    ],
  );
}

MyMenuState _buildDensePhotoGoldenState() {
  final DateTime capturedAt = DateTime(2026, 7, 22, 18, 30);
  return MyMenuState.forTesting(
    dishes: seededDishes,
    captureItems: List<CaptureItem>.generate(18, (int index) {
      final DateTime itemTime = capturedAt.subtract(Duration(minutes: index));
      return CaptureItem(
        id: 'golden_dense_$index',
        batchId: 'golden_dense_batch_${index ~/ 3}',
        ordinal: index % 3,
        kind: CaptureItemKind.photo,
        status: CaptureItemStatus.localOnly,
        createdAt: itemTime,
        capturedAt: itemTime,
        capturedLocalDate: '2026-07-22',
        localMediaRef: seededDishes[index % seededDishes.length].heroImageUrl,
      );
    }),
  );
}

Future<void> _pumpGoldenMenu(
  WidgetTester tester,
  MyMenuState state, {
  String query = '',
}) async {
  _configureGoldenViewport(tester);

  await tester.pumpWidget(
    RepaintBoundary(
      key: _fullAppGoldenKey,
      child: MyMenuScope(
        notifier: state,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.data,
          home: Scaffold(
            body: MenuScreen(
              query: query,
              onQueryChanged: (_) {},
              onOpenPhotos: () {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _configureGoldenViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
  tester.platformDispatcher.textScaleFactorTestValue = 1.15;
  addTearDown(tester.view.reset);
  addTearDown(
    tester.platformDispatcher.clearTextScaleFactorTestValue,
  );
}

Future<void> _expectFullAppGolden(
  WidgetTester tester,
  String name,
) async {
  await _settleGoldenFrame(tester);
  expect(tester.takeException(), isNull);
  await expectLater(
    find.byType(Overlay).first,
    matchesGoldenFile(
      'goldens/${name}_390x844_text_scale_1_15.png',
    ),
  );
}

Future<void> _settleGoldenFrame(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

Future<void> _loadGoldenFonts() async {
  final FontLoader textLoader = FontLoader('.SF Pro Rounded')
    ..addFont(_fontData('test/support/fonts/Roboto-Regular.ttf'))
    ..addFont(_fontData('test/support/fonts/Roboto-Bold.ttf'));
  final FontLoader iconLoader = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await Future.wait(<Future<void>>[
    textLoader.load(),
    iconLoader.load(),
  ]);
}

Future<ByteData> _fontData(String path) async {
  final Uint8List bytes = await File(path).readAsBytes();
  return ByteData.sublistView(bytes);
}
