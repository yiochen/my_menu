import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/capture/review_item.dart';
import 'package:mymenu/domain/capture/seeded_review_items.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/domain/planning/seeded_plan.dart';
import 'package:mymenu/domain/sync/repositories.dart';

part 'my_menu_state_capture.dart';
part 'my_menu_state_dishes.dart';
part 'my_menu_state_planning.dart';
part 'my_menu_state_sync.dart';

class MyMenuState extends ChangeNotifier {
  MyMenuState({AppRepositories? repositories})
      : _dishes = List<Dish>.of(seededDishes),
        _plan = buildSeededPlan(),
        _captureItems = const <CaptureItem>[],
        _reviewItems = List<ReviewItem>.of(seededReviewItems),
        _extraPlanDays = 0,
        _repositories = repositories {
    if (_repositories != null) {
      unawaited(_bootstrapRepositories());
    }
  }

  List<Dish> _dishes;
  List<PlannedMeal> _plan;
  List<CaptureItem> _captureItems;
  List<ReviewItem> _reviewItems;
  int? _extraPlanDays;
  final AppRepositories? _repositories;
  bool _isSyncingCaptures = false;
  Timer? _captureSyncTimer;
  DateTime? _captureSyncPollingDeadline;

  static const Duration _captureSyncPollInterval = Duration(seconds: 5);
  static const Duration _captureSyncPollWindow = Duration(minutes: 2);

  List<Dish> get dishes => List<Dish>.unmodifiable(_dishes);
  List<PlannedMeal> get plan => List<PlannedMeal>.unmodifiable(_plan);
  List<CaptureItem> get captureItems =>
      List<CaptureItem>.unmodifiable(_captureItems);
  List<ReviewItem> get reviewItems =>
      List<ReviewItem>.unmodifiable(_reviewItems);

  @override
  void dispose() {
    _captureSyncTimer?.cancel();
    super.dispose();
  }

  void _notifyChanged() {
    notifyListeners();
  }

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
    if (_repositories != null) {
      unawaited(_createIdeaCapture(trimmed));
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
      notes: _notesFor('dish_$idBase${_dishes.length}', const <String>[
        'Captured as an idea.',
        'Add real source photos after the next cook.',
      ]),
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
      notes: _notesFor('dish_capture_${_dishes.length}', <String>[
        'Created from capture: $summary',
      ]),
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

  void addPhotoCaptures(List<String> imageRefs) {
    unawaited(_createPhotoCaptures(imageRefs));
  }

  void discardCapture(String captureId) {
    final AppRepositories? repositories = _repositories;
    _captureItems = _captureItems.map((CaptureItem item) {
      if (item.id != captureId) {
        return item;
      }
      return CaptureItem(
        id: item.id,
        kind: item.kind,
        status: CaptureItemStatus.discarded,
        createdAt: item.createdAt,
        localMediaRef: item.localMediaRef,
        remoteMediaRef: item.remoteMediaRef,
        text: item.text,
        appliedDishId: item.appliedDishId,
      );
    }).toList(growable: false);
    notifyListeners();
    _updateCaptureSyncPolling();
    if (repositories != null) {
      unawaited(repositories.captureRepository.discardCapture(captureId));
    }
  }

  Future<void> _bootstrapRepositories() async {
    final AppRepositories repositories = _repositories!;
    await repositories.seedIfNeeded();
    await _reloadFromRepositories();
    _updateCaptureSyncPolling();
  }

  Future<void> _createPhotoCaptures(List<String> imageRefs) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      final List<ReviewItem> nextReviewItems = _reviewItemsWithPhotoCaptures(
        imageRefs,
        _reviewItems,
      );
      if (!identical(nextReviewItems, _reviewItems)) {
        _reviewItems = nextReviewItems;
        notifyListeners();
      }
      return;
    }

    await repositories.captureRepository.createPhotoCaptures(imageRefs);
    _startCaptureSyncPollingWindow();
    await _reloadFromRepositories();
    await _syncCaptures();
  }

  Future<void> _createIdeaCapture(String text) async {
    final AppRepositories? repositories = _repositories;
    if (repositories == null) {
      return;
    }
    await repositories.captureRepository.createIdeaCapture(text);
    _startCaptureSyncPollingWindow();
    await _reloadFromRepositories();
    await _syncCaptures();
  }

  Future<void> _reloadFromRepositories() async {
    final AppRepositories repositories = _repositories!;
    _dishes = await repositories.dishRepository.listDishes();
    _captureItems = await repositories.captureRepository.listFeedItems();
    notifyListeners();
  }

  void resolveReviewToDish(String reviewId, String dishId) {
    final ReviewItem item =
        _reviewItems.firstWhere((ReviewItem review) => review.id == reviewId);
    _reviewItems = _reviewItems
        .where((ReviewItem review) => review.id != reviewId)
        .toList(growable: false);
    _attachCook(
      dishId,
      item.summary,
      imageRef: item.imageRef,
      notify: false,
    );
    notifyListeners();
  }

  void createDishFromReview(String reviewId) {
    final ReviewItem item =
        _reviewItems.firstWhere((ReviewItem review) => review.id == reviewId);
    _reviewItems = _reviewItems
        .where((ReviewItem review) => review.id != reviewId)
        .toList(growable: false);
    if (item.imageRef != null) {
      _dishes = <Dish>[
        _dishFromPhotoReview(item, _dishes.length, _templateFor(item.summary)),
        ..._dishes,
      ];
      notifyListeners();
      return;
    }
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

  void _attachCook(
    String dishId,
    String note, {
    String? imageRef,
    bool notify = true,
  }) {
    _dishes = _dishes.map((Dish dish) {
      if (dish.id != dishId) {
        return dish;
      }

      return dish.copyWith(
        madeCount: dish.madeCount + 1,
        lastMadeLabel: 'Today',
        sourcePhotos: <SourcePhoto>[
          SourcePhoto(
            url: imageRef ??
                (dish.sourcePhotos.isEmpty
                    ? dish.heroImageUrl
                    : dish.sourcePhotos.first.url),
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
}
