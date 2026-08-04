import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/processing/processing_consent_prompt.dart';
import 'package:mymenu/domain/processing/processing_privacy_notice.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/menu/menu_grid_card.dart';
import 'package:mymenu/features/plan/plan_screen.dart';
import 'package:mymenu/shared/theme/app_theme.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

import '../support/network_image_test_helper.dart';
import '../support/tolerant_golden_file_comparator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  setUpAll(_loadGoldenFonts);

  group('MyMenu app shell', () {
    testWidgets('processing consent popup responds to application events', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();
        final BuildContext appContext = tester.element(
          find.byKey(const ValueKey<String>('plan_screen')),
        );
        final MyMenuState state = MyMenuScope.read(appContext);

        final Future<ProcessingConsentDecision> decision =
            state.requestProcessingConsent(
          trigger: ProcessingConsentTrigger.improveCover,
        );
        await tester.pumpAndSettle();

        expect(find.text('Let MyMenu use AI?'), findsOneWidget);
        expect(find.text('Capture'), findsNothing);
        await tester.tap(find.text('Allow AI processing'));
        await tester.pumpAndSettle();

        expect(await decision, ProcessingConsentDecision.accepted);
        expect(find.text('Let MyMenu use AI?'), findsNothing);
      });
    });

    testWidgets('capture choices open before AI consent is requested', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey<String>('capture_fab')));
        await tester.pumpAndSettle();
        expect(find.text('Let MyMenu use AI?'), findsNothing);
        expect(find.text('Capture'), findsOneWidget);
        expect(find.text('Add Idea'), findsOneWidget);
      });
    });

    testWidgets('debug control resets consent so capture asks again', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_debugTestApp());
        await tester.pumpAndSettle();
        final MyMenuState state = MyMenuScope.read(
          tester.element(find.byKey(const ValueKey<String>('plan_screen'))),
        );
        final Future<ProcessingConsentDecision> consent =
            state.requestProcessingConsent(
          trigger: ProcessingConsentTrigger.improveCover,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Allow AI processing'));
        await tester.pumpAndSettle();
        await consent;

        await tester.tap(
          find.byKey(const ValueKey<String>('debug_controls_open')),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(
            const ValueKey<String>('debug_reset_processing_consent'),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey<String>('capture_fab')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Take Photo'));
        await tester.pumpAndSettle();
        expect(find.text('Let MyMenu use AI?'), findsOneWidget);
      });
    });

    testWidgets('debug controls stay above sheets and gate camera access', (
      WidgetTester tester,
    ) async {
      addTearDown(() => timeDilation = 1);
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_debugTestApp());
        await tester.pumpAndSettle();

        final Finder debugLauncher = find.byKey(
          const ValueKey<String>('debug_controls_open'),
        );
        final Offset initialLauncherPosition = tester.getCenter(debugLauncher);
        await tester.drag(debugLauncher, const Offset(-120, 180));
        await tester.pumpAndSettle();
        final Offset movedLauncherPosition = tester.getCenter(debugLauncher);
        expect(
          movedLauncherPosition.dx,
          lessThan(initialLauncherPosition.dx),
        );
        expect(
          movedLauncherPosition.dy,
          greaterThan(initialLauncherPosition.dy),
        );

        await tester.tap(
          debugLauncher,
        );
        await tester.pumpAndSettle();

        expect(find.text('Debug controls'), findsOneWidget);
        expect(find.text('Network'), findsOneWidget);
        expect(find.text('Slow animation'), findsOneWidget);
        expect(find.text('Camera access'), findsOneWidget);

        await tester.tap(
          find.descendant(
            of: find.byKey(
              const ValueKey<String>('debug_slow_animation_toggle'),
            ),
            matching: find.byType(Switch),
          ),
        );
        await tester.pump();
        expect(timeDilation, 5);
        await tester.tap(
          find.descendant(
            of: find.byKey(
              const ValueKey<String>('debug_slow_animation_toggle'),
            ),
            matching: find.byType(Switch),
          ),
        );
        await tester.pumpAndSettle();
        expect(timeDilation, 1);

        await tester.tap(
          find.descendant(
            of: find.byKey(const ValueKey<String>('debug_camera_toggle')),
            matching: find.byType(Switch),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey<String>('debug_controls_close')),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey<String>('capture_fab')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Take Photo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Not now'));
        await tester.pumpAndSettle();
        expect(find.text('Let MyMenu use AI?'), findsNothing);
        expect(find.text('Camera access is off'), findsOneWidget);
        expect(
          find.byKey(const ValueKey<String>('debug_controls_open')),
          findsOneWidget,
        );
        expect(
          tester.getCenter(debugLauncher),
          movedLauncherPosition,
        );

        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('shows the redesigned plan screen on launch', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();

        final Finder plan = find.byKey(
          const ValueKey<String>('plan_screen'),
        );
        expect(plan, findsOneWidget);
        expect(find.byKey(const ValueKey('plan_month_picker')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('plan_week_page_view')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('plan_today_button')), findsOneWidget);
        expect(
          tester.getSize(
            find.byKey(
              const ValueKey<String>('plan_day_count_2026-07-22'),
            ),
          ),
          const Size.square(14),
        );
        expect(find.text('Wednesday, July 22'), findsOneWidget);
        expect(find.text('2 dishes planned'), findsOneWidget);
        expect(find.text('What are we cooking?'), findsNothing);
        expect(find.text('Suggestion · not planned'), findsNothing);
        expect(find.text('2 captures need a quick look'), findsNothing);
        expect(find.byKey(const ValueKey('capture_fab')), findsOneWidget);
        final Finder reviewBadge = find.byKey(
          const ValueKey<String>('menu_review_badge'),
        );
        expect(reviewBadge, findsNothing);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('empty menu does not build a broken plan suggestion', (
      WidgetTester tester,
    ) async {
      final MyMenuState state = MyMenuState.forTesting();
      addTearDown(state.dispose);

      await tester.pumpWidget(
        MyMenuScope(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.data,
            home: Scaffold(
              body: PlanScreen(
                onOpenReview: () {},
                onOpenPhotos: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nothing planned yet'), findsOneWidget);
      expect(find.text('Add a dish'), findsOneWidget);
      expect(find.text('Suggestion · not planned'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('can save a dish idea from the capture-first flow', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('capture_fab')));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Add Idea'),
          120,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.tap(find.text('Add Idea'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey<String>('idea_title_field')),
          'crispy tofu bowls',
        );
        await tester.enterText(
          find.byKey(const ValueKey<String>('idea_note_field')),
          'Use the sesame glaze.',
        );
        await tester.scrollUntilVisible(
          find.text('Save idea'),
          120,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.tap(find.text('Save idea'));
        await tester.pumpAndSettle();

        expect(find.text('Let MyMenu use AI?'), findsOneWidget);
        await tester.tap(find.text('Not now'));
        await tester.pumpAndSettle();

        expect(find.text('Add an idea'), findsNothing);
        expect(find.byKey(const ValueKey('capture_fab')), findsOneWidget);
        await tester.tap(find.text('Menu'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('new dishes use a finite wobbling text label', (
      WidgetTester tester,
    ) async {
      final dish = seededDishes.first.copyWith(createdAt: DateTime(2026, 8));
      final MyMenuState state = MyMenuState.forTesting(dishes: <Dish>[dish]);
      addTearDown(state.dispose);

      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(
          MyMenuScope(
            notifier: state,
            child: MaterialApp(
              theme: AppTheme.data,
              home: Scaffold(
                body: SizedBox(
                  width: 180,
                  height: 300,
                  child: MenuGridCard(dish: dish),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(
          find.byKey(
            const ValueKey<String>('menu_new_label_dish_salmon'),
          ),
          findsOneWidget,
        );
        expect(find.text('New'), findsOneWidget);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('dish detail pages swipe and the selector tracks tab taps', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();
        final Finder salmonCard = find.byKey(
          const ValueKey<String>('menu_dish_dish_salmon'),
        );
        await tester.scrollUntilVisible(
          salmonCard,
          220,
          scrollable: find
              .descendant(
                of: find.byKey(const ValueKey<String>('menu_screen')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.ensureVisible(salmonCard);
        await tester.pumpAndSettle();
        await tester.tap(salmonCard);
        await tester.pumpAndSettle();

        final Finder tabBarFinder = find.byKey(
          const ValueKey<String>('dish_detail_tab_bar'),
        );
        expect(
          find.byKey(const ValueKey<String>('dish_detail_page_view')),
          findsOneWidget,
        );
        final TabBar tabBar = tester.widget<TabBar>(tabBarFinder);
        await tester.tap(find.text('Recipe'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tabBar.controller!.animation!.value, greaterThan(0));
        expect(tabBar.controller!.animation!.value, lessThan(1));
        await tester.pumpAndSettle();
        expect(find.text('Ingredients'), findsOneWidget);

        await tester.fling(
          find.byKey(const ValueKey<String>('dish_detail_page_view')),
          const Offset(500, 0),
          1000,
        );
        await tester.pumpAndSettle();
        expect(tabBar.controller!.index, 0);
        expect(
          find.byKey(const ValueKey<String>('journal_add_note')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('can add a dish detail note without teardown errors', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();
        final Finder linguineCard = find.byKey(
          const ValueKey<String>('menu_dish_dish_linguine'),
        );
        await tester.scrollUntilVisible(
          linguineCard,
          220,
          scrollable: find
              .descendant(
                of: find.byKey(const ValueKey<String>('menu_screen')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.ensureVisible(linguineCard);
        await tester.pumpAndSettle();
        await tester.tap(linguineCard);
        await tester.pumpAndSettle();

        expect(find.text('Cook again'), findsOneWidget);
        expect(find.text('Journal'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey<String>('journal_add_note')),
          220,
          scrollable: find
              .descendant(
                of: find.byKey(
                  const ValueKey<String>('dish_detail_scroll_view'),
                ),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester
            .tap(find.byKey(const ValueKey<String>('journal_add_note')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey<String>('dish_note_input')),
          'Smoky garlic next time.',
        );
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Smoky garlic'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets(
        'menu top chrome is edge-to-edge, scrollable, and overflow-free',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 47);
      tester.platformDispatcher.textScaleFactorTestValue = 1.15;
      addTearDown(tester.view.reset);
      addTearDown(
        tester.platformDispatcher.clearTextScaleFactorTestValue,
      );

      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();
        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();

        final Finder menu = find.byKey(
          const ValueKey<String>('menu_screen'),
        );
        final Finder fixedChrome = find.byKey(
          const ValueKey<String>('menu_fixed_chrome'),
        );
        expect(tester.getTopLeft(fixedChrome).dy, 0);
        expect(tester.getBottomRight(menu).dy, 844);
        final CustomScrollView menuScrollView = tester.widget(menu);
        final SliverPadding menuContent =
            menuScrollView.slivers.first as SliverPadding;
        final EdgeInsets menuPadding =
            menuContent.padding.resolve(TextDirection.ltr);
        expect(menuPadding.left, MyMenuUnits.pageGutter);
        expect(menuPadding.right, MyMenuUnits.pageGutter);
        final SliverMainAxisGroup menuSlivers =
            menuContent.child! as SliverMainAxisGroup;
        final SliverToBoxAdapter bottomClearance =
            menuSlivers.children.last as SliverToBoxAdapter;
        expect(
          (bottomClearance.child! as SizedBox).height,
          MyMenuUnits.pageBottom,
        );
        final Container menuCard = tester.widget(
          find.byKey(const ValueKey<String>('menu_dish_dish_salmon')),
        );
        final BoxDecoration cardDecoration =
            menuCard.decoration! as BoxDecoration;
        final BoxDecoration cardForeground =
            menuCard.foregroundDecoration! as BoxDecoration;
        expect(cardForeground.border, isNotNull);
        expect(cardDecoration.boxShadow, isNotEmpty);
        final Finder compactSearch = find.byKey(
          const ValueKey<String>('menu_compact_search_header'),
        );
        final double initialHeaderTop = tester.getTopLeft(compactSearch).dy;
        expect(initialHeaderTop, greaterThanOrEqualTo(47));
        expect(find.text('Your personal restaurant'), findsNothing);
        expect(find.text('My Menu'), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.drag(menu, const Offset(0, -260));
        await tester.pumpAndSettle();

        expect(tester.getTopLeft(compactSearch).dy, initialHeaderTop);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('long press replaces menu chrome and bottom navigation', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();
        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey<String>('bottom_shell_golden')),
          findsOneWidget,
        );
        final Finder salmonCard = find.byKey(
          const ValueKey<String>('menu_dish_dish_salmon'),
        );
        await tester.scrollUntilVisible(
          salmonCard,
          180,
          scrollable: find
              .descendant(
                of: find.byKey(const ValueKey<String>('menu_screen')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.ensureVisible(salmonCard);
        await tester.pumpAndSettle();
        await tester.longPress(salmonCard);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey<String>('menu_selection_header')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('menu_compact_search_header')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey<String>('bottom_shell_golden')),
          findsNothing,
        );

        await tester.tap(
          find.byKey(const ValueKey<String>('menu_selection_close')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey<String>('menu_compact_search_header')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('bottom_shell_golden')),
          findsOneWidget,
        );
      });
    });

    testWidgets('menu chrome matches its screenshot goldens', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 47);
      tester.platformDispatcher.textScaleFactorTestValue = 1.15;
      addTearDown(tester.view.reset);
      addTearDown(
        tester.platformDispatcher.clearTextScaleFactorTestValue,
      );

      await runWithMockNetworkImages(() async {
        final GoldenFileComparator previousComparator = goldenFileComparator;
        goldenFileComparator = TolerantGoldenFileComparator(
          Uri.parse('test/widget/app_shell_test.dart'),
          precisionTolerance: 0.12,
        );
        addTearDown(() => goldenFileComparator = previousComparator);

        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();
        await tester.tap(find.text('Menu'));
        await tester.pumpAndSettle();

        final Finder heading = find.byKey(
          const ValueKey<String>('menu_compact_search_header'),
        );
        expect(tester.getSize(heading), const Size(354, 46));
        await expectLater(
          heading,
          matchesGoldenFile(
            'goldens/menu_heading_390x844_text_scale_1_15.png',
          ),
        );

        final Finder bottomShell = find.byKey(
          const ValueKey<String>('bottom_shell_golden'),
        );
        expect(tester.getSize(bottomShell), const Size(358, 111));
        await expectLater(
          bottomShell,
          matchesGoldenFile(
            'goldens/bottom_shell_390x844_text_scale_1_15.png',
          ),
        );
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('removes and restores a planned dish with Undo', (
      WidgetTester tester,
    ) async {
      await runWithMockNetworkImages(() async {
        await tester.pumpWidget(_testApp());
        await tester.pumpAndSettle();

        final Finder meal = find.byKey(
          const ValueKey<String>('planned_meal_plan_today_0'),
        );
        final Finder more = find.descendant(
          of: meal,
          matching: find.byIcon(Icons.more_horiz_rounded),
        );
        await tester.tap(more);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Remove from plan'));
        await tester.pumpAndSettle();

        expect(meal, findsNothing);
        expect(find.text('Undo'), findsOneWidget);
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();
        expect(
          find.text('Miso Salmon Bowl'),
          findsAtLeastNWidgets(1),
        );
      });
    });
  });
}

Widget _testApp() {
  return MyMenuApp(
    database: AppDatabase.forTesting(NativeDatabase.memory()),
    networkStatusMonitor: const InertNetworkStatusMonitor(),
    showDebugPanel: false,
    seedSampleData: true,
  );
}

Widget _debugTestApp() {
  return MyMenuApp(
    database: AppDatabase.forTesting(NativeDatabase.memory()),
    networkStatusMonitor: const InertNetworkStatusMonitor(),
    showDebugPanel: true,
    seedSampleData: true,
  );
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
