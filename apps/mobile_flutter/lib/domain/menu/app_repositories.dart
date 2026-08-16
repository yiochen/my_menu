import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/core/files/dish_image_cache.dart';
import 'package:mymenu/core/files/image_derivative_store.dart';
import 'package:mymenu/core/network/processing_api_client.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_correction.dart';
import 'package:mymenu/domain/capture/capture_item.dart' as capture_domain;
import 'package:mymenu/domain/capture/capture_mappers.dart';
import 'package:mymenu/domain/capture/captured_media.dart';
import 'package:mymenu/domain/capture/review_item.dart';
import 'package:mymenu/domain/covers/cover_repository.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/dish_mappers.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/planning/planned_meal.dart' as planning_domain;
import 'package:mymenu/domain/planning/seeded_plan.dart';
import 'package:mymenu/domain/processing/processing_consent_repository.dart';
import 'package:mymenu/domain/processing/processing_coordinator.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/processing/processing_outbox_repository.dart';
import 'package:mymenu/domain/processing/processing_privacy_notice.dart';
import 'package:uuid/uuid.dart';

export 'package:mymenu/domain/processing/processing_coordinator.dart';

part 'repositories_dishes.dart';
part 'repositories_dish_inserts.dart';
part 'repositories_dish_deletion.dart';
part 'repositories_planning.dart';
part 'repositories_capture.dart';
part 'repositories_capture_processing.dart';
part 'repositories_capture_fallback.dart';
part 'repositories_capture_deletion.dart';
part 'repositories_capture_corrections.dart';
part 'repositories_capture_adoption.dart';
part 'repositories_capture_bulk_corrections.dart';
part 'repositories_capture_correction_support.dart';
part 'repositories_dish_notes_query.dart';
part 'repositories_media_previews.dart';

const Set<String> _bundledMockImageRefs = <String>{
  'asset://assets/dish_art/miso-salmon.png',
  'asset://assets/dish_art/miso-salmon-improved.png',
  'asset://assets/dish_art/linguine.png',
  'asset://assets/dish_art/katsu.png',
  'asset://assets/dish_art/pho.png',
};

class AppRepositories {
  AppRepositories({
    required this.database,
    required this.processingApiClient,
    this.captureControlRequestTimeout = const Duration(seconds: 5),
    this.seedSampleDataOnPrepare = false,
    DishImageCache? dishImageCache,
    ImageDerivativeStore? imageDerivativeStore,
  }) {
    final DishImageCache resolvedImageCache =
        dishImageCache ?? DishImageCache();
    final ImageDerivativeStore resolvedDerivativeStore =
        imageDerivativeStore ?? ImageDerivativeStore();
    _prepareImagePreviewsOnBootstrap = imageDerivativeStore != null ||
        Platform.environment['FLUTTER_TEST'] != 'true';
    _imageDerivativeStore = resolvedDerivativeStore;
    dishRepository = DishRepository(
      database,
      resolvedImageCache,
      resolvedDerivativeStore,
    );
    coverRepository = CoverRepository(database);
    planRepository = PlanRepository(database);
    processingConsentRepository = ProcessingConsentRepository(database);
    processingOutboxRepository = ProcessingOutboxRepository(database);
    captureRepository = CaptureRepository(
      database,
      processingOutboxRepository,
      resolvedDerivativeStore,
    );
    captureCorrectionRepository = CaptureCorrectionRepository(database);
    processingCoordinator = ProcessingCoordinator(
      database,
      processingApiClient,
      controlRequestTimeout: captureControlRequestTimeout,
      imageDerivativeStore: resolvedDerivativeStore,
      captureProposalAdopter:
          captureCorrectionRepository.adoptValidatedCaptureRoutingProposal,
      captureProcessingLocalStore: LocalCaptureProcessingStore(
        captureRepository,
      ),
    );
  }

  final db.AppDatabase database;
  final ProcessingApiClient processingApiClient;
  final Duration captureControlRequestTimeout;
  @visibleForTesting
  final bool seedSampleDataOnPrepare;
  late final ImageDerivativeStore _imageDerivativeStore;
  late final bool _prepareImagePreviewsOnBootstrap;
  late final DishRepository dishRepository;
  late final CoverRepository coverRepository;
  late final PlanRepository planRepository;
  late final CaptureRepository captureRepository;
  late final ProcessingOutboxRepository processingOutboxRepository;
  late final ProcessingConsentRepository processingConsentRepository;
  late final CaptureCorrectionRepository captureCorrectionRepository;
  late final ProcessingCoordinator processingCoordinator;

  @visibleForTesting
  Future<void> seedIfNeeded() async {
    await database.transaction(() async {
      final db.LocalSettingRow? marker =
          await (database.select(database.localSettings)
                ..where(
                  (db.LocalSettings table) => table.key.equals(
                    db.localSeedDataInitializedKey,
                  ),
                ))
              .getSingleOrNull();
      if (marker != null) {
        return;
      }
      await dishRepository._seedIfEmpty();
      await planRepository._seedIfEmpty();
      await database.into(database.localSettings).insert(
            db.LocalSettingsCompanion.insert(
              key: db.localSeedDataInitializedKey,
              value: 'true',
            ),
          );
    });
  }

  Future<void> prepareLocalData() async {
    if (seedSampleDataOnPrepare) {
      await seedIfNeeded();
    }
    await _removeBundledMockImageRefs();
    if (_prepareImagePreviewsOnBootstrap) {
      await _prepareImagePreviews();
    }
    await database.into(database.localSettings).insertOnConflictUpdate(
          db.LocalSettingsCompanion.insert(
            key: db.localSeedDataInitializedKey,
            value: 'true',
          ),
        );
  }

  Future<void> _removeBundledMockImageRefs() async {
    final List<db.DishRow> affectedDishes = await (database.select(
      database.dishes,
    )..where(
            (db.Dishes table) => table.heroImageUrl.isIn(_bundledMockImageRefs),
          ))
        .get();
    await (database.delete(database.sourcePhotos)
          ..where(
            (db.SourcePhotos table) => table.url.isIn(_bundledMockImageRefs),
          ))
        .go();

    for (final db.DishRow dish in affectedDishes) {
      final db.SourcePhotoRow? replacement = await (database.select(
        database.sourcePhotos,
      )
            ..where((db.SourcePhotos table) => table.dishId.equals(dish.id))
            ..limit(1))
          .getSingleOrNull();
      await (database.update(database.dishes)
            ..where((db.Dishes table) => table.id.equals(dish.id)))
          .write(
        db.DishesCompanion(
          heroImageUrl: Value<String>(replacement?.url ?? ''),
          heroPreviewUrl: Value<String?>(replacement?.previewUrl),
          heroThumbnailUrl: Value<String?>(replacement?.thumbnailUrl),
          heroPlaceholderUrl: Value<String?>(replacement?.placeholderUrl),
        ),
      );
    }
  }
}
