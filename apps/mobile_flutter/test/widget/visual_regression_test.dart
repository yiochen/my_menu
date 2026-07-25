import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/app/home_shell.dart';
import 'package:mymenu/domain/capture/seeded_review_items.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/planning/seeded_plan.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
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

        expect(find.text('My Menu'), findsOneWidget);
        await _expectFullAppGolden(tester, 'ui_menu_home');
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
        expect(find.text('My Menu'), findsOneWidget);
        expect(
          tester.getTopLeft(find.text('My Menu')).dy,
          inInclusiveRange(47, 160),
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
        final Finder reviewCard = find.byKey(
          const ValueKey<String>('plan_review_card'),
        );
        await tester.scrollUntilVisible(
          reviewCard,
          180,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.drag(
          find.byKey(const ValueKey<String>('plan_screen')),
          const Offset(0, -140),
        );
        await tester.pumpAndSettle();
        await tester.tap(reviewCard);
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
  await _precacheDishArtwork(tester);
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
    dishes: seededDishes,
    plan: buildSeededPlan(_goldenPlanDate),
    reviewItems: seededReviewItems,
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
            ),
          ),
        ),
      ),
    ),
  );
  await _precacheDishArtwork(tester);
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

Future<void> _precacheDishArtwork(WidgetTester tester) async {
  final BuildContext context = tester.element(
    find.byKey(_fullAppGoldenKey),
  );
  await tester.runAsync(() async {
    await Future.wait(<Future<void>>[
      precacheImage(
        const AssetImage('assets/dish_art/miso-salmon.png'),
        context,
      ),
      precacheImage(
        const AssetImage('assets/dish_art/linguine.png'),
        context,
      ),
      precacheImage(
        const AssetImage('assets/dish_art/katsu.png'),
        context,
      ),
      precacheImage(
        const AssetImage('assets/dish_art/pho.png'),
        context,
      ),
    ]);
  });
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
