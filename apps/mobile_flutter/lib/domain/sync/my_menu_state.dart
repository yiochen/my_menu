import 'package:flutter/foundation.dart';

import 'package:mymenu/domain/capture/review_item.dart';
import 'package:mymenu/domain/capture/seeded_review_items.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/domain/planning/seeded_plan.dart';

class MyMenuState extends ChangeNotifier {
  MyMenuState()
      : _dishes = List<Dish>.of(seededDishes),
        _plan = buildSeededPlan(),
        _reviewItems = List<ReviewItem>.of(seededReviewItems),
        _extraPlanDays = 0;

  List<Dish> _dishes;
  List<PlannedMeal> _plan;
  List<ReviewItem> _reviewItems;
  int? _extraPlanDays;

  List<Dish> get dishes => List<Dish>.unmodifiable(_dishes);
  List<PlannedMeal> get plan => List<PlannedMeal>.unmodifiable(_plan);
  List<ReviewItem> get reviewItems =>
      List<ReviewItem>.unmodifiable(_reviewItems);

  List<DateTime> remainingPlanDates({DateTime? from}) {
    final List<DateTime> baseDates = remainingDaysInWeek(from);
    final int extraPlanDays = _extraPlanDays ?? 0;
    if (extraPlanDays == 0 || baseDates.isEmpty) {
      return baseDates;
    }

    final DateTime lastDate = baseDates.last;
    return <DateTime>[
      ...baseDates,
      ...List<DateTime>.generate(
        extraPlanDays,
        (int index) => lastDate.add(Duration(days: index + 1)),
        growable: false,
      ),
    ];
  }

  List<PlannedMeal> plannedMealsForDay(String dayKey) {
    return _plan
        .where((PlannedMeal meal) => meal.dayKey == dayKey)
        .toList(growable: false);
  }

  Dish dishById(String id) => _dishes.firstWhere((Dish dish) => dish.id == id);

  List<Dish> filterDishes(String query) {
    final String normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return dishes;
    }

    return _dishes.where((Dish dish) {
      return dish.title.toLowerCase().contains(normalized) ||
          dish.description.toLowerCase().contains(normalized) ||
          dish.category.toLowerCase().contains(normalized);
    }).toList(growable: false);
  }

  Dish recommendedDish() {
    final List<Dish> sorted = List<Dish>.of(_dishes)
      ..sort((Dish a, Dish b) => a.madeCount.compareTo(b.madeCount));
    return sorted.first;
  }

  void toggleFavorite(String dishId) {
    _dishes = _dishes.map((Dish dish) {
      return dish.id == dishId
          ? dish.copyWith(isFavorite: !dish.isFavorite)
          : dish;
    }).toList(growable: false);
    notifyListeners();
  }

  void addPlannedMeal(String dayKey, String dishId, {String? label}) {
    _plan = <PlannedMeal>[
      ..._plan,
      PlannedMeal(
        id: 'plan_${_plan.length + 1}',
        dayKey: dayKey,
        dishId: dishId,
        label: label,
      ),
    ];
    notifyListeners();
  }

  void updatePlannedMeal(String planId, String dishId, {String? label}) {
    _plan = _plan.map((PlannedMeal meal) {
      return meal.id == planId
          ? meal.copyWith(dishId: dishId, label: label)
          : meal;
    }).toList(growable: false);
    notifyListeners();
  }

  void removePlannedMeal(String planId) {
    _plan = _plan
        .where((PlannedMeal meal) => meal.id != planId)
        .toList(growable: false);
    notifyListeners();
  }

  void addNextPlanDay() {
    _extraPlanDays = (_extraPlanDays ?? 0) + 1;
    notifyListeners();
  }

  void ensurePlanDateVisible(DateTime date, {DateTime? from}) {
    final List<DateTime> baseDates = remainingDaysInWeek(from);
    if (baseDates.isEmpty) {
      return;
    }

    final DateTime normalizedDate = startOfDay(date);
    final DateTime lastBaseDate = startOfDay(baseDates.last);
    if (!normalizedDate.isAfter(lastBaseDate)) {
      return;
    }

    final int extraPlanDays = normalizedDate.difference(lastBaseDate).inDays;
    final int nextExtraPlanDays = extraPlanDays > (_extraPlanDays ?? 0)
        ? extraPlanDays
        : (_extraPlanDays ?? 0);
    if (nextExtraPlanDays == (_extraPlanDays ?? 0)) {
      return;
    }

    _extraPlanDays = nextExtraPlanDays;
    notifyListeners();
  }

  void movePlannedMeal(
    String planId, {
    required String targetDayKey,
    required int targetIndex,
  }) {
    final int sourceIndex =
        _plan.indexWhere((PlannedMeal meal) => meal.id == planId);
    if (sourceIndex == -1) {
      return;
    }

    final PlannedMeal movingMeal = _plan[sourceIndex];
    final PlannedMeal updatedMeal = movingMeal.dayKey == targetDayKey
        ? movingMeal
        : movingMeal.copyWith(dayKey: targetDayKey);

    final List<PlannedMeal> nextPlan = List<PlannedMeal>.of(_plan)
      ..removeAt(sourceIndex);

    int insertAt = _globalInsertIndexForDay(
      nextPlan,
      dayKey: targetDayKey,
      indexInDay: targetIndex,
    );
    if (insertAt < 0) {
      insertAt = 0;
    } else if (insertAt > nextPlan.length) {
      insertAt = nextPlan.length;
    }

    nextPlan.insert(insertAt, updatedMeal);
    _plan = nextPlan;
    notifyListeners();
  }

  void improveCover(String dishId, String prompt) {
    _dishes = _dishes.map((Dish dish) {
      if (dish.id != dishId || dish.sourcePhotos.isEmpty) {
        return dish;
      }

      final int index =
          prompt.trim().isEmpty ? 0 : prompt.length % dish.sourcePhotos.length;
      return dish.copyWith(heroImageUrl: dish.sourcePhotos[index].url);
    }).toList(growable: false);
    notifyListeners();
  }

  void addIdea(String text) {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final Dish template = _templateFor(trimmed);
    final String idBase =
        trimmed.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '_');
    final Dish nextDish = Dish(
      id: 'dish_$idBase${_dishes.length}',
      title: _titleCase(trimmed),
      description:
          'A saved dish idea for ${trimmed.toLowerCase()}, ready to refine the next time you cook it.',
      heroImageUrl: template.heroImageUrl,
      category: template.category,
      prepMinutes: template.prepMinutes,
      difficulty: template.difficulty,
      madeCount: 0,
      lastMadeLabel: 'Not cooked yet',
      ingredients: template.ingredients,
      recipeSteps: template.recipeSteps,
      notes: <String>[
        'Captured as an idea.',
        'Add real source photos after the next cook.',
      ],
      sourcePhotos: const <SourcePhoto>[],
    );

    _dishes = <Dish>[nextDish, ..._dishes];
    notifyListeners();
  }

  void addMockCapture(String summary) {
    final String normalized = summary.toLowerCase();
    if (normalized.contains('pho')) {
      _reviewItems = <ReviewItem>[
        ReviewItem(
          id: 'review_${_reviewItems.length + 1}',
          summary: 'Possible pho capture from: $summary',
          suggestedDishIds: const <String>['dish_pho', 'dish_katsu'],
          confidenceLabel: '58%',
        ),
        ..._reviewItems,
      ];
      notifyListeners();
      return;
    }

    if (normalized.contains('salmon')) {
      _attachCook('dish_salmon', summary);
      return;
    }

    if (normalized.contains('linguine') || normalized.contains('pasta')) {
      _attachCook('dish_linguine', summary);
      return;
    }

    final Dish template = _templateFor(summary);
    final Dish nextDish = Dish(
      id: 'dish_capture_${_dishes.length}',
      title: 'Captured ${template.title}',
      description: 'Created from a mocked photo capture.',
      heroImageUrl: template.heroImageUrl,
      category: template.category,
      prepMinutes: template.prepMinutes,
      difficulty: template.difficulty,
      madeCount: 1,
      lastMadeLabel: 'Today',
      ingredients: template.ingredients,
      recipeSteps: template.recipeSteps,
      notes: <String>['Created from capture: $summary'],
      sourcePhotos: <SourcePhoto>[
        SourcePhoto(
          url: template.heroImageUrl,
          capturedLabel: 'Today',
          note: summary,
          confidenceLabel: '73%',
        ),
      ],
    );

    _dishes = <Dish>[nextDish, ..._dishes];
    notifyListeners();
  }

  void resolveReviewToDish(String reviewId, String dishId) {
    final ReviewItem item =
        _reviewItems.firstWhere((ReviewItem review) => review.id == reviewId);
    _reviewItems = _reviewItems
        .where((ReviewItem review) => review.id != reviewId)
        .toList(growable: false);
    _attachCook(dishId, item.summary, notify: false);
    notifyListeners();
  }

  void createDishFromReview(String reviewId) {
    final ReviewItem item =
        _reviewItems.firstWhere((ReviewItem review) => review.id == reviewId);
    _reviewItems = _reviewItems
        .where((ReviewItem review) => review.id != reviewId)
        .toList(growable: false);
    addIdea(item.summary);
  }

  Dish _templateFor(String text) {
    final String normalized = text.toLowerCase();
    if (normalized.contains('pho') || normalized.contains('noodle')) {
      return dishById('dish_pho');
    }
    if (normalized.contains('salmon') || normalized.contains('bowl')) {
      return dishById('dish_salmon');
    }
    if (normalized.contains('katsu') || normalized.contains('curry')) {
      return dishById('dish_katsu');
    }
    return dishById('dish_linguine');
  }

  void _attachCook(String dishId, String note, {bool notify = true}) {
    _dishes = _dishes.map((Dish dish) {
      if (dish.id != dishId) {
        return dish;
      }

      return dish.copyWith(
        madeCount: dish.madeCount + 1,
        lastMadeLabel: 'Today',
        sourcePhotos: <SourcePhoto>[
          SourcePhoto(
            url: dish.sourcePhotos.isEmpty
                ? dish.heroImageUrl
                : dish.sourcePhotos.first.url,
            capturedLabel: 'Today',
            note: note,
            confidenceLabel: '86%',
          ),
          ...dish.sourcePhotos,
        ],
      );
    }).toList(growable: false);

    if (notify) {
      notifyListeners();
    }
  }

  String _titleCase(String input) {
    return input
        .split(' ')
        .where((String part) => part.trim().isNotEmpty)
        .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  int _globalInsertIndexForDay(
    List<PlannedMeal> plan, {
    required String dayKey,
    required int indexInDay,
  }) {
    final List<int> dayIndices = <int>[];
    for (int index = 0; index < plan.length; index++) {
      if (plan[index].dayKey == dayKey) {
        dayIndices.add(index);
      }
    }

    if (dayIndices.isEmpty) {
      for (int index = 0; index < plan.length; index++) {
        if (plan[index].dayKey.compareTo(dayKey) > 0) {
          return index;
        }
      }
      return plan.length;
    }

    if (indexInDay <= 0) {
      return dayIndices.first;
    }
    if (indexInDay >= dayIndices.length) {
      return dayIndices.last + 1;
    }
    return dayIndices[indexInDay];
  }
}
