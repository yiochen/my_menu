import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/core/network/network_status_monitor.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_correction.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/capture/captured_media.dart';
import 'package:mymenu/domain/capture/captured_photo.dart';
import 'package:mymenu/domain/capture/review_item.dart';
import 'package:mymenu/domain/capture/seeded_review_items.dart';
import 'package:mymenu/domain/covers/generated_cover.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/menu/app_repositories.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/planning/planned_meal.dart';
import 'package:mymenu/domain/planning/seeded_plan.dart';
import 'package:mymenu/domain/processing/processing_consent_prompt.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/processing/processing_privacy_notice.dart';
import 'package:uuid/uuid.dart';

part '../processing/my_menu_state_processing_consent.dart';
part '../processing/my_menu_state_processing_resume.dart';
part 'my_menu_state_capture.dart';
part 'my_menu_state_capture_corrections.dart';
part 'my_menu_state_capture_deletion.dart';
part 'my_menu_state_capture_persistence.dart';
part 'my_menu_state_covers.dart';
part 'my_menu_state_dish_deletion.dart';
part 'my_menu_state_dishes.dart';
part 'my_menu_state_photos.dart';
part 'my_menu_state_planning.dart';

class MyMenuState extends ChangeNotifier with WidgetsBindingObserver {
  MyMenuState({
    AppRepositories? repositories,
    NetworkStatusMonitor? networkStatusMonitor,
  })  : _dishes =
            repositories == null ? List<Dish>.of(seededDishes) : const <Dish>[],
        _plan =
            repositories == null ? buildSeededPlan() : const <PlannedMeal>[],
        _captureBatches = const <CaptureBatch>[],
        _captureItems = const <CaptureItem>[],
        _captureCorrections = const <CaptureCorrection>[],
        _generatedCovers = const <GeneratedCover>[],
        _processingRequests = const <ProcessingOutboxRequest>[],
        _reviewItems = repositories == null
            ? List<ReviewItem>.of(seededReviewItems)
            : const <ReviewItem>[],
        _processingConsentDecision = ProcessingConsentDecision.notDecided,
        _extraPlanDays = 0,
        _repositories = repositories,
        _networkStatusMonitor = networkStatusMonitor {
    if (_repositories != null) {
      WidgetsBinding.instance.addObserver(this);
      _networkStatusSubscription = _networkStatusMonitor?.changes.listen((_) {
        _handleNetworkStatusChange();
      });
      _repositoryBootstrap = _bootstrapRepositories();
      unawaited(_repositoryBootstrap);
    }
  }

  @visibleForTesting
  MyMenuState.forTesting({
    List<Dish> dishes = const <Dish>[],
    List<PlannedMeal> plan = const <PlannedMeal>[],
    List<CaptureBatch> captureBatches = const <CaptureBatch>[],
    List<CaptureItem> captureItems = const <CaptureItem>[],
    List<CaptureCorrection> captureCorrections = const <CaptureCorrection>[],
    List<GeneratedCover> generatedCovers = const <GeneratedCover>[],
    List<ProcessingOutboxRequest> processingRequests =
        const <ProcessingOutboxRequest>[],
    List<ReviewItem> reviewItems = const <ReviewItem>[],
    ProcessingConsentDecision processingConsentDecision =
        ProcessingConsentDecision.notDecided,
  })  : _dishes = List<Dish>.of(dishes),
        _plan = List<PlannedMeal>.of(plan),
        _captureBatches = List<CaptureBatch>.of(captureBatches),
        _captureItems = List<CaptureItem>.of(captureItems),
        _captureCorrections = List<CaptureCorrection>.of(captureCorrections),
        _generatedCovers = List<GeneratedCover>.of(generatedCovers),
        _processingRequests = List<ProcessingOutboxRequest>.of(
          processingRequests,
        ),
        _reviewItems = List<ReviewItem>.of(reviewItems),
        _processingConsentDecision = processingConsentDecision,
        _extraPlanDays = 0,
        _repositories = null,
        _networkStatusMonitor = null;

  List<Dish> _dishes;
  List<PlannedMeal> _plan;
  List<CaptureBatch> _captureBatches;
  List<CaptureItem> _captureItems;
  List<CaptureCorrection> _captureCorrections;
  List<GeneratedCover> _generatedCovers;
  List<ProcessingOutboxRequest> _processingRequests;
  List<ReviewItem> _reviewItems;
  int? _extraPlanDays;
  final AppRepositories? _repositories;
  final NetworkStatusMonitor? _networkStatusMonitor;
  final Map<String, _PendingDishDeletion> _pendingDishDeletions =
      <String, _PendingDishDeletion>{};
  final Map<String, _PendingCaptureDeletion> _pendingCaptureDeletions =
      <String, _PendingCaptureDeletion>{};
  final Map<String, _PendingCaptureBatchDeletion>
      _pendingCaptureBatchDeletions = <String, _PendingCaptureBatchDeletion>{};
  StreamSubscription<void>? _networkStatusSubscription;
  Future<void>? _activeProcessingResume;
  Timer? _processingResumeTimer;
  DateTime? _processingResumeDeadline;
  Future<void>? _repositoryBootstrap;
  ProcessingConsentDecision _processingConsentDecision;
  ProcessingConsentRequest? _pendingProcessingConsentRequest;
  Completer<ProcessingConsentDecision>? _processingConsentCompleter;
  int _nextProcessingConsentRequestId = 1;
  static const Duration _processingResumeInterval = Duration(seconds: 5);
  static const Duration _processingResumeWindow = Duration(minutes: 2);
  List<Dish> get dishes => List<Dish>.unmodifiable(
        _dishes.where(
          (Dish dish) => !_pendingCaptureResultDishIds.contains(dish.id),
        ),
      );
  List<PlannedMeal> get plan => _validPlannedMeals;
  List<CaptureBatch> get captureBatches {
    final Set<String> hiddenCaptureIds = _hiddenCaptureIds;
    return List<CaptureBatch>.unmodifiable(
      _captureBatches
          .where(
            (CaptureBatch batch) => !_pendingCaptureBatchIds.contains(batch.id),
          )
          .map(
            (CaptureBatch batch) => CaptureBatch(
              id: batch.id,
              status: batch.status,
              createdAt: batch.createdAt,
              updatedAt: batch.updatedAt,
              items: batch.items
                  .where(
                    (CaptureItem item) => !hiddenCaptureIds.contains(item.id),
                  )
                  .toList(growable: false),
              failureReason: batch.failureReason,
            ),
          )
          .where((CaptureBatch batch) => batch.items.isNotEmpty),
    );
  }

  List<CaptureItem> get captureItems => List<CaptureItem>.unmodifiable(
        _captureItems.where(
          (CaptureItem item) => !_hiddenCaptureIds.contains(item.id),
        ),
      );
  List<CaptureCorrection> get captureCorrections =>
      List<CaptureCorrection>.unmodifiable(_captureCorrections);
  List<ReviewItem> get reviewItems => List<ReviewItem>.unmodifiable(
        _reviewItems.where(
          (ReviewItem item) => !_hiddenCaptureIds.contains(item.captureId),
        ),
      );
  List<ProcessingOutboxRequest> get processingRequests =>
      List<ProcessingOutboxRequest>.unmodifiable(_processingRequests);
  List<CapturedPhoto> get photos => List<CapturedPhoto>.unmodifiable(
        buildCapturedPhotos(
          items: captureItems,
          dishes: dishes,
          reviewItems: reviewItems,
          processingRequests: processingRequests,
        ),
      );
  int get unorganizedPhotoCount =>
      photos.where((CapturedPhoto photo) => !photo.isOrganized).length;
  int get organizedPhotoCount =>
      photos.where((CapturedPhoto photo) => photo.isOrganized).length;
  bool get isOrganizingPhotos => photos.any(
        (CapturedPhoto photo) => photo.state == CapturedPhotoState.organizing,
      );
  ProcessingConsentDecision get processingConsentDecision =>
      _processingConsentDecision;
  ProcessingConsentRequest? get pendingProcessingConsentRequest =>
      _pendingProcessingConsentRequest;
  @visibleForTesting
  Future<void> get initialized => _repositoryBootstrap ?? Future<void>.value();

  @override
  void dispose() {
    if (_repositories != null) {
      WidgetsBinding.instance.removeObserver(this);
    }
    unawaited(_networkStatusSubscription?.cancel());
    _processingResumeTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _repositories != null) {
      unawaited(_resumeLegacyMediaContraction());
      if (_hasProcessingWorkToResume()) {
        _startProcessingResumeWindow();
      }
      unawaited(resumeProcessing());
    }
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
    return plan
        .where((PlannedMeal meal) => meal.dayKey == dayKey)
        .toList(growable: false);
  }

  Dish dishById(String id) => _dishes.firstWhere((Dish dish) => dish.id == id);

  List<Dish> filterDishes(String query) {
    final String normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return dishes;
    }

    return dishes.where((Dish dish) {
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

  Future<void> toggleFavorite(String dishId) async {
    final Dish current = dishById(dishId);
    final bool isFavorite = !current.isFavorite;
    final List<Dish> nextDishes = _dishes.map((Dish dish) {
      return dish.id == dishId ? dish.copyWith(isFavorite: isFavorite) : dish;
    }).toList(growable: false);
    final AppRepositories? repositories = _repositories;
    if (repositories != null) {
      await repositories.dishRepository.setFavorite(
        dishId,
        isFavorite: isFavorite,
      );
      await _reloadFromRepositories();
      return;
    }
    _dishes = nextDishes;
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

    final Dish nextDish = Dish(
      id: 'dish_capture_${_dishes.length}',
      title: 'Captured Dish',
      description: 'Created from a mocked photo capture.',
      heroImageUrl: '',
      category: 'Captured',
      prepMinutes: 0,
      difficulty: 'Draft',
      madeCount: 1,
      lastMadeLabel: 'Today',
      ingredients: const <String>[],
      recipeSteps: const <String>[],
      notes: _notesFor('dish_capture_${_dishes.length}', <String>[
        'Created from capture: $summary',
      ]),
      sourcePhotos: const <SourcePhoto>[],
      createdAt: DateTime.now(),
    );

    _dishes = <Dish>[nextDish, ..._dishes];
    notifyListeners();
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
        notes: <DishNote>[
          ...dish.notes,
          DishNote(
            id: '${dish.id}_note_${DateTime.now().microsecondsSinceEpoch}',
            dishId: dish.id,
            body: note,
            position: dish.notes.length,
          ),
        ],
        sourcePhotos: <SourcePhoto>[
          SourcePhoto(
            url: imageRef ??
                (dish.sourcePhotos.isEmpty
                    ? dish.heroImageUrl
                    : dish.sourcePhotos.first.url),
            capturedLabel: 'Today',
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
}
