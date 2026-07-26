import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

import '../support/network_image_test_helper.dart';
import '../support/tolerant_golden_file_comparator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  setUpAll(_loadGoldenFonts);

  group('MyMenu app shell', () {
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
        expect(tester.getTopLeft(plan).dx, 0);
        expect(
          tester.getBottomRight(plan).dy,
          tester.view.physicalSize.height / tester.view.devicePixelRatio,
        );
        expect(
          tester.getBottomRight(plan).dx,
          tester.view.physicalSize.width / tester.view.devicePixelRatio,
        );
        final ListView planScrollView = tester.widget(plan);
        final EdgeInsets planPadding =
            planScrollView.padding!.resolve(TextDirection.ltr);
        expect(planPadding.left, MyMenuUnits.pageGutter);
        expect(planPadding.right, MyMenuUnits.pageGutter);
        final SliverChildListDelegate planChildren =
            planScrollView.childrenDelegate as SliverChildListDelegate;
        expect(
          (planChildren.children.last as SizedBox).height,
          MyMenuUnits.pageBottom,
        );
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
        await tester.scrollUntilVisible(
          find.text('2 captures need a quick look'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('2 captures need a quick look'), findsOneWidget);
        expect(find.byKey(const ValueKey('capture_fab')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
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
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(find.text('Add an idea'), findsNothing);
        expect(find.byKey(const ValueKey('capture_fab')), findsOneWidget);
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
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(linguineCard);
        await tester.pumpAndSettle();
        await tester.tap(linguineCard);
        await tester.pumpAndSettle();

        expect(find.text('Cook again'), findsOneWidget);
        await tester.drag(find.byType(ListView).first, const Offset(0, -360));
        await tester.pumpAndSettle();
        final Finder notesTab = find.textContaining('Notes ·');
        expect(notesTab, findsOneWidget);
        await tester.tap(notesTab);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add Note'));
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
        expect(tester.getTopLeft(menu).dy, 0);
        expect(tester.getBottomRight(menu).dy, 844);
        final CustomScrollView menuScrollView = tester.widget(menu);
        final SliverPadding menuContent =
            menuScrollView.slivers.single as SliverPadding;
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
        expect(
          tester.getTopLeft(find.text('Your personal restaurant')).dy,
          greaterThan(47),
        );
        expect(tester.takeException(), isNull);

        await tester.drag(menu, const Offset(0, -32));
        await tester.pumpAndSettle();

        expect(
          tester.getTopLeft(find.text('Your personal restaurant')).dy,
          lessThan(47),
        );
        expect(tester.takeException(), isNull);
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
          const ValueKey<String>('menu_heading_golden'),
        );
        expect(tester.getSize(heading), const Size(354, 55));
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
