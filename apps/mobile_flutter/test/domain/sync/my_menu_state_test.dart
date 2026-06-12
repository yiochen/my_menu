import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';

void main() {
  group('MyMenuState', () {
    test('adds a dish idea to the front of the dish list', () {
      final MyMenuState state = MyMenuState();

      final int before = state.dishes.length;
      state.addIdea('crispy tofu bowls');

      expect(state.dishes.length, before + 1);
      expect(state.dishes.first.title, 'Crispy Tofu Bowls');
      expect(state.dishes.first.lastMadeLabel, 'Not cooked yet');
    });

    test('planning a dish updates the targeted day', () {
      final MyMenuState state = MyMenuState()..planDish('fri', 'dish_katsu');

      final plannedFriday =
          state.plan.firstWhere((meal) => meal.dayKey == 'fri');
      expect(plannedFriday.dishId, 'dish_katsu');
    });
  });
}
