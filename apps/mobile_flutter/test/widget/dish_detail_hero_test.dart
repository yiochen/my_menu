import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/dish_detail/dish_detail_hero.dart';
import 'package:mymenu/shared/theme/app_theme.dart';

void main() {
  testWidgets('dish title and description can be edited, saved, and canceled',
      (WidgetTester tester) async {
    final Dish dish = seededDishes.first.copyWith(
      heroImageUrl: '',
      title: 'Original title',
      description: 'Original description',
    );
    final MyMenuState state = MyMenuState.forTesting(dishes: <Dish>[dish]);
    addTearDown(state.dispose);
    await _pumpHero(tester, state, dish.id);

    expect(
      find.byKey(const ValueKey<String>('dish_edit_button')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.more_horiz), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('dish_edit_button')));
    await tester.pump();
    final Finder titleField =
        find.byKey(const ValueKey<String>('dish_title_field'));
    final Finder descriptionField =
        find.byKey(const ValueKey<String>('dish_description_field'));
    expect(
      tester.widget<TextField>(titleField).controller?.text,
      'Original title',
    );
    expect(
      tester.widget<TextField>(descriptionField).controller?.text,
      'Original description',
    );

    await tester.enterText(titleField, 'Canceled title');
    await tester.tap(find.byKey(const ValueKey<String>('dish_edit_cancel')));
    await tester.pump();
    expect(find.text('Original title'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('dish_edit_button')));
    await tester.pump();
    await tester.enterText(titleField, '  Human title  ');
    await tester.enterText(descriptionField, '  Human description  ');
    await tester.tap(find.byKey(const ValueKey<String>('dish_edit_save')));
    await tester.pumpAndSettle();

    final Dish saved = state.dishById(dish.id);
    expect(saved.title, 'Human title');
    expect(saved.description, 'Human description');
    expect(
        find.byKey(const ValueKey<String>('dish_title_field')), findsNothing);
    expect(find.text('Human title'), findsOneWidget);
    expect(find.text('Human description'), findsOneWidget);
  });

  testWidgets('one Cover image pill opens AI and existing-cover tabs',
      (WidgetTester tester) async {
    final Dish dish = seededDishes.first.copyWith(heroImageUrl: '');
    final MyMenuState state = MyMenuState.forTesting(dishes: <Dish>[dish]);
    addTearDown(state.dispose);
    await _pumpHero(tester, state, dish.id);

    expect(
      find.byKey(const ValueKey<String>('cover_image_button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('change_cover_button')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('improve_cover_button')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('cover_image_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('AI generation'), findsOneWidget);
    expect(find.text('Use existing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpHero(
  WidgetTester tester,
  MyMenuState state,
  String dishId,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MyMenuScope(
      notifier: state,
      child: MaterialApp(
        theme: AppTheme.data,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: DishDetailHero(
              dish: MyMenuScope.of(context).dishById(dishId),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
