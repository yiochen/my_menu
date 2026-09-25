import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';

void main() {
  group('MyMenuState.filterDishes', () {
    test('returns all dishes when query is empty', () {
      final MyMenuState state = MyMenuState();
      final dishes = state.filterDishes('');

      expect(dishes.length, state.dishes.length);
    });

    test('returns all dishes when query is whitespace', () {
      final MyMenuState state = MyMenuState();

      expect(state.filterDishes('   ').length, state.dishes.length);
    });

    test('matches by title', () {
      final MyMenuState state = MyMenuState();
      final dishes = state.filterDishes('linguine');

      expect(dishes.length, 1);
      expect(dishes.single.id, 'dish_linguine');
    });

    test('matches by description', () {
      final MyMenuState state = MyMenuState();
      final dishes = state.filterDishes('garlicky');

      expect(dishes.length, 1);
      expect(dishes.single.id, 'dish_linguine');
    });

    test('matches by category', () {
      final MyMenuState state = MyMenuState();
      final dishes = state.filterDishes('Soups');

      expect(dishes.length, 1);
      expect(dishes.single.id, 'dish_pho');
    });

    test('is case-insensitive', () {
      final MyMenuState state = MyMenuState();
      final dishes = state.filterDishes('PHO');

      expect(dishes.any((d) => d.id == 'dish_pho'), isTrue);
    });

    test('returns empty when nothing matches', () {
      final MyMenuState state = MyMenuState();

      expect(state.filterDishes('zzzznotfound'), isEmpty);
    });
  });

  group('MyMenuState.recommendedDish', () {
    test('returns the dish with the lowest madeCount', () {
      final MyMenuState state = MyMenuState();
      final dish = state.recommendedDish();

      final int minMadeCount = state.dishes
          .map((d) => d.madeCount)
          .reduce((a, b) => a < b ? a : b);

      expect(dish.madeCount, minMadeCount);
    });
  });

  group('MyMenuState.toggleFavorite', () {
    test('toggles a dish from non-favorite to favorite', () {
      final MyMenuState state = MyMenuState();
      final dish = state.dishes.firstWhere((d) => !d.isFavorite);
      final bool before = dish.isFavorite;

      state.toggleFavorite(dish.id);

      final updated = state.dishes.firstWhere((d) => d.id == dish.id);
      expect(updated.isFavorite, !before);
    });

    test('toggles a dish from favorite back to non-favorite', () {
      final MyMenuState state = MyMenuState();
      final dish = state.dishes.firstWhere((d) => d.isFavorite);

      state.toggleFavorite(dish.id);
      expect(
        state.dishes.firstWhere((d) => d.id == dish.id).isFavorite,
        isFalse,
      );

      state.toggleFavorite(dish.id);
      expect(
        state.dishes.firstWhere((d) => d.id == dish.id).isFavorite,
        isTrue,
      );
    });

    test('notifies listeners', () {
      final MyMenuState state = MyMenuState();
      int notifyCount = 0;
      state
        ..addListener(() => notifyCount++)
        ..toggleFavorite(state.dishes.first.id);

      expect(notifyCount, 1);
    });
  });

  group('MyMenuState.improveCover', () {
    test('changes hero image based on prompt', () {
      final MyMenuState state = MyMenuState();
      final dish = state.dishes.firstWhere(
        (d) => d.sourcePhotos.length > 1,
      );

      state.improveCover(dish.id, 'a long enough prompt to differ');

      final updated = state.dishes.firstWhere((d) => d.id == dish.id);
      expect(updated.heroImageUrl, isNotEmpty);
      expect(
        dish.sourcePhotos.map((sp) => sp.url),
        contains(updated.heroImageUrl),
      );
    });

    test('uses first source photo when prompt is empty', () {
      final MyMenuState state = MyMenuState();
      final dish = state.dishes.firstWhere(
        (d) => d.sourcePhotos.isNotEmpty,
      );

      state.improveCover(dish.id, '');

      final updated = state.dishes.firstWhere((d) => d.id == dish.id);
      expect(updated.heroImageUrl, dish.sourcePhotos.first.url);
    });

    test('does nothing for a dish with no source photos', () {
      final MyMenuState state = MyMenuState()..addIdea('no photos dish');
      final dish = state.dishes.firstWhere(
        (d) => d.sourcePhotos.isEmpty,
      );
      final String heroBeforeImprove = dish.heroImageUrl;

      state.improveCover(dish.id, 'improve this');

      final updated = state.dishes.firstWhere((d) => d.id == dish.id);
      expect(updated.heroImageUrl, heroBeforeImprove);
    });
  });

  group('MyMenuState.addIdea', () {
    test('does not add a dish for an empty string', () {
      final MyMenuState state = MyMenuState();
      final int before = state.dishes.length;

      state
        ..addIdea('')
        ..addIdea('   ');

      expect(state.dishes.length, before);
    });

    test('title-cases the dish title', () {
      final MyMenuState state = MyMenuState()..addIdea('spicy miso ramen');

      expect(state.dishes.first.title, 'Spicy Miso Ramen');
    });

    test('sets madeCount to 0 and lastMadeLabel to not cooked', () {
      final MyMenuState state = MyMenuState()..addIdea('test dish idea');

      expect(state.dishes.first.madeCount, 0);
      expect(state.dishes.first.lastMadeLabel, 'Not cooked yet');
    });
  });

  group('MyMenuState.addMockCapture', () {
    test('adds a pho review item when summary mentions pho', () {
      final MyMenuState state = MyMenuState();
      final int before = state.reviewItems.length;

      state.addMockCapture('pho from dinner');

      expect(state.reviewItems.length, before + 1);
      expect(state.reviewItems.first.summary, contains('pho'));
    });

    test('attaches a cook to salmon when summary mentions salmon', () {
      final MyMenuState state = MyMenuState();
      final dish = state.dishes.firstWhere((d) => d.id == 'dish_salmon');
      final int madeCountBefore = dish.madeCount;

      state.addMockCapture('grilled salmon bowl');

      final updated = state.dishes.firstWhere((d) => d.id == 'dish_salmon');
      expect(updated.madeCount, madeCountBefore + 1);
      expect(updated.lastMadeLabel, 'Today');
    });

    test('attaches a cook to linguine when summary mentions pasta', () {
      final MyMenuState state = MyMenuState();
      final dish = state.dishes.firstWhere((d) => d.id == 'dish_linguine');
      final int madeCountBefore = dish.madeCount;

      state.addMockCapture('quick pasta dinner');

      final updated = state.dishes.firstWhere((d) => d.id == 'dish_linguine');
      expect(updated.madeCount, madeCountBefore + 1);
    });

    test('creates a new dish for an unrecognized summary', () {
      final MyMenuState state = MyMenuState();
      final int before = state.dishes.length;

      state.addMockCapture('completely new meal');

      expect(state.dishes.length, before + 1);
      expect(state.dishes.first.title, startsWith('Captured'));
      expect(state.dishes.first.madeCount, 1);
    });
  });

  group('MyMenuState.discardCapture', () {
    test('marks a capture item as discarded in the in-memory list', () {
      final MyMenuState state = MyMenuState()
        ..addPhotoCaptures(<String>['/tmp/photo.jpg']);

      final capture = state.captureItems.isNotEmpty
          ? state.captureItems.first
          : null;

      if (capture != null) {
        state.discardCapture(capture.id);
        final updated = state.captureItems.firstWhere(
          (c) => c.id == capture.id,
        );
        expect(updated.status.name, 'discarded');
      }
    });
  });

  group('MyMenuState planning extensions', () {
    test('updatePlannedMeal changes dish and label', () {
      final MyMenuState state = MyMenuState();
      final meal = state.plan.first;

      state.updatePlannedMeal(meal.id, 'dish_pho', label: 'Brunch');

      final updated = state.plan.firstWhere((m) => m.id == meal.id);
      expect(updated.dishId, 'dish_pho');
      expect(updated.label, 'Brunch');
    });

    test('removePlannedMeal removes the meal from the plan', () {
      final MyMenuState state = MyMenuState();
      final meal = state.plan.first;
      final int before = state.plan.length;

      state.removePlannedMeal(meal.id);

      expect(state.plan.length, before - 1);
      expect(state.plan.where((m) => m.id == meal.id), isEmpty);
    });

    test('movePlannedMeal to a different day updates the dayKey', () {
      final MyMenuState state = MyMenuState();
      final dates = state.remainingPlanDates();
      if (dates.length < 2) {
        return;
      }
      final meal = state.plan.first;
      final String targetDayKey =
          '${dates.last.year}-${dates.last.month.toString().padLeft(2, '0')}-${dates.last.day.toString().padLeft(2, '0')}';

      state.movePlannedMeal(
        meal.id,
        targetDayKey: targetDayKey,
        targetIndex: 0,
      );

      final moved = state.plan.firstWhere((m) => m.id == meal.id);
      expect(moved.dayKey, targetDayKey);
    });

    test('movePlannedMeal with invalid id does nothing', () {
      final MyMenuState state = MyMenuState();
      final int before = state.plan.length;

      state.movePlannedMeal(
        'nonexistent_plan_id',
        targetDayKey: '2026-06-20',
        targetIndex: 0,
      );

      expect(state.plan.length, before);
    });
  });

  group('MyMenuState.resolveReviewToDish', () {
    test('removes the review item and attaches cook to the dish', () {
      final MyMenuState state = MyMenuState();
      final review = state.reviewItems.first;
      final String dishId = review.suggestedDishIds.first;
      final dish = state.dishes.firstWhere((d) => d.id == dishId);
      final int madeCountBefore = dish.madeCount;

      state.resolveReviewToDish(review.id, dishId);

      expect(
        state.reviewItems.where((r) => r.id == review.id),
        isEmpty,
      );
      final updated = state.dishes.firstWhere((d) => d.id == dishId);
      expect(updated.madeCount, madeCountBefore + 1);
    });
  });

  group('MyMenuState.createDishFromReview', () {
    test('removes the review and creates a dish idea', () {
      final MyMenuState state = MyMenuState();
      final review = state.reviewItems.first;
      final int dishesBefore = state.dishes.length;

      state.createDishFromReview(review.id);

      expect(
        state.reviewItems.where((r) => r.id == review.id),
        isEmpty,
      );
      expect(state.dishes.length, dishesBefore + 1);
    });
  });

  group('MyMenuState.dishById', () {
    test('returns the correct dish', () {
      final MyMenuState state = MyMenuState();
      final dish = state.dishById('dish_pho');

      expect(dish.id, 'dish_pho');
      expect(dish.title, 'Pho');
    });

    test('throws when dish is not found', () {
      final MyMenuState state = MyMenuState();

      expect(
        () => state.dishById('nonexistent'),
        throwsStateError,
      );
    });
  });
}
