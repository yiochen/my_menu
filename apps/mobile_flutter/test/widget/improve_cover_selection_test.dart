import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/covers/generated_cover.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/features/improve_cover/improve_cover_dialog.dart';
import 'package:mymenu/features/improve_cover/improve_cover_selection.dart';
import 'package:mymenu/shared/theme/app_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

void main() {
  testWidgets('Cover image opens full screen under the safe-area header',
      (WidgetTester tester) async {
    final MyMenuState state = MyMenuState();
    addTearDown(state.dispose);
    tester.view.padding = const FakeViewPadding(top: 47);
    await _pumpViewport(
      tester,
      Builder(
        builder: (BuildContext context) => ElevatedButton(
          onPressed: () => showImproveCoverDialog(
            context,
            state,
            'dish_salmon',
          ),
          child: const Text('Open'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(tester.getTopLeft(find.byType(WarmPage)).dy, 0);
    final Finder header = find.byKey(
      const ValueKey<String>('improve_cover_sticky_header'),
    );
    final double initialHeaderTop = tester.getTopLeft(header).dy;
    expect(initialHeaderTop, greaterThanOrEqualTo(47));
    expect(find.text('AI generation'), findsOneWidget);
    expect(find.text('Use existing'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey<String>('improve_cover_scroll_view')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(header).dy, initialHeaderTop);
    expect(find.text('Cover image'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('treatments use photo rows, inset content, and remembered scroll',
      (WidgetTester tester) async {
    const CoverTreatment remembered = CoverTreatment(
      look: CoverLook.darkRefined,
      view: CoverView.closeUp,
      finish: CoverFinish.editorial,
    );
    await _pumpViewport(
      tester,
      ImproveCoverSelection(
        dish: seededDishes.first,
        selectedSourceIds: seededDishes.first.sourcePhotos
            .map((source) => source.id)
            .whereType<String>()
            .take(3)
            .toSet(),
        treatment: remembered,
        autoScrollToTreatment: true,
        onToggleSource: (_) {},
        onTreatmentChanged: (_) {},
        onGenerate: () {},
        coverAllowanceRemaining: 8,
        horizontalPadding: 18,
      ),
    );

    for (final String label in <String>['look', 'view', 'finish']) {
      final Finder picker = find.byKey(
        ValueKey<String>('treatment_picker_$label'),
      );
      await tester.scrollUntilVisible(
        picker,
        260,
        scrollable: find
            .descendant(
              of: find.byKey(
                const ValueKey<String>('improve_cover_scroll_view'),
              ),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(
        find.descendant(of: picker, matching: find.byType(Image)),
        findsWidgets,
      );
      expect(
        find.descendant(of: picker, matching: find.byType(Scrollable)),
        findsOneWidget,
      );
    }

    final Finder finishPicker = find.byKey(
      const ValueKey<String>('treatment_picker_finish'),
    );
    final ScrollableState finishScroll = tester.state<ScrollableState>(
      find.descendant(of: finishPicker, matching: find.byType(Scrollable)),
    );
    expect(finishScroll.position.pixels, greaterThan(0));
    expect(tester.getTopLeft(finishPicker).dx, 0);
    expect(tester.getSize(finishPicker).width, 390);

    final Finder check = find.descendant(
      of: finishPicker,
      matching: find.byIcon(Icons.check),
    );
    final Finder label = find.descendant(
      of: finishPicker,
      matching: find.text('Editorial'),
    );
    expect(check, findsOneWidget);
    expect(tester.getTopLeft(check).dy, lessThan(tester.getTopLeft(label).dy));
    expect(find.byType(ChoiceChip), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Use existing tab shows generated and source cover choices',
      (WidgetTester tester) async {
    final MyMenuState state = MyMenuState();
    addTearDown(state.dispose);
    await _pumpViewport(
      tester,
      Builder(
        builder: (BuildContext context) => ElevatedButton(
          onPressed: () => showImproveCoverDialog(
            context,
            state,
            'dish_salmon',
          ),
          child: const Text('Open'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use existing'));
    await tester.pumpAndSettle();

    expect(find.text('Generated covers'), findsOneWidget);
    expect(find.text('Choose from Sources'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('existing_cover_scroll_view')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpViewport(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.data, home: home));
  await tester.pumpAndSettle();
}
