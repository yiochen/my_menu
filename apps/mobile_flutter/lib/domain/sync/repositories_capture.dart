part of 'repositories.dart';

class CaptureRepository {
  CaptureRepository(
    this._database, [
    ProcessingOutboxRepository? processingOutboxRepository,
    ImageDerivativeStore? imageDerivativeStore,
  ])  : _processingOutboxRepository =
            processingOutboxRepository ?? ProcessingOutboxRepository(_database),
        _imageDerivativeStore = imageDerivativeStore ?? ImageDerivativeStore();

  final db.AppDatabase _database;
  final ProcessingOutboxRepository _processingOutboxRepository;
  final ImageDerivativeStore _imageDerivativeStore;
  final Uuid _uuid = const Uuid();
  static const int maxBatchItems = 9;

  Future<List<ReviewItem>> listReviewItems() async {
    final List<db.ReviewItemRow> rows =
        await _database.select(_database.reviewItems).get();
    return rows.map((db.ReviewItemRow row) {
      final Object? suggested = jsonDecode(row.suggestedDishIdsJson);
      return ReviewItem(
        id: row.id,
        captureId: row.captureId,
        summary: row.summary,
        suggestedDishIds: suggested is List<dynamic>
            ? suggested.whereType<String>().toList(growable: false)
            : const <String>[],
        confidenceLabel: row.confidenceLabel,
        imageRef: row.imageRef,
      );
    }).toList(growable: false);
  }

  Future<List<capture_domain.CaptureItem>> listFeedItems() async {
    final List<db.CaptureItemRow> rows =
        await (_database.select(_database.captureItems)
              ..orderBy(<OrderingTerm Function(db.$CaptureItemsTable)>[
                (db.CaptureItems table) => OrderingTerm.desc(table.createdAt),
              ]))
            .get();
    return rows.map((db.CaptureItemRow row) => row.toDomain()).toList();
  }

  Future<List<CaptureBatch>> listBatches() async {
    final List<db.CaptureBatchRow> batchRows =
        await (_database.select(_database.captureBatches)
              ..orderBy(<OrderingTerm Function(db.$CaptureBatchesTable)>[
                (db.$CaptureBatchesTable table) =>
                    OrderingTerm.desc(table.createdAt),
              ]))
            .get();
    final List<db.CaptureItemRow> itemRows =
        await (_database.select(_database.captureItems)
              ..orderBy(<OrderingTerm Function(db.$CaptureItemsTable)>[
                (db.$CaptureItemsTable table) =>
                    OrderingTerm.asc(table.ordinal),
              ]))
            .get();
    final Map<String, List<capture_domain.CaptureItem>> itemsByBatch =
        <String, List<capture_domain.CaptureItem>>{};
    for (final db.CaptureItemRow row in itemRows) {
      final String? batchId = row.batchId;
      if (batchId == null) {
        continue;
      }
      itemsByBatch
          .putIfAbsent(batchId, () => <capture_domain.CaptureItem>[])
          .add(row.toDomain());
    }
    return batchRows.map((db.CaptureBatchRow row) {
      return CaptureBatch(
        id: row.id,
        status: captureBatchStatusFromDatabase(row.status),
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        items: List<capture_domain.CaptureItem>.unmodifiable(
          itemsByBatch[row.id] ?? const <capture_domain.CaptureItem>[],
        ),
        failureReason: row.failureReason,
      );
    }).toList(growable: false);
  }

  Future<CaptureBatch?> createPhotoBatch(
    List<Object> capturedMedia, {
    String? targetDishId,
  }) async {
    final List<CapturedMedia> media = capturedMedia
        .map(_normalizeCapturedMedia)
        .where((CapturedMedia item) => item.path.trim().isNotEmpty)
        .take(maxBatchItems)
        .toList(growable: false);
    if (media.isEmpty) {
      return null;
    }

    final String? authoritativeDishId = targetDishId?.trim();
    final db.DishRow? targetDish = authoritativeDishId == null
        ? null
        : await (_database.select(_database.dishes)
              ..where(
                (db.Dishes table) => table.id.equals(authoritativeDishId),
              ))
            .getSingleOrNull();
    if (authoritativeDishId != null && targetDish == null) {
      throw StateError('The selected dish no longer exists.');
    }

    final String batchId = _uuid.v4();
    final String jobId = _uuid.v4();
    final DateTime now = DateTime.now();
    final ProcessingConsentDecision consent =
        await ProcessingConsentRepository(_database).currentDecision();
    final bool useLocalFallback = consent == ProcessingConsentDecision.declined;
    final bool isAuthoritativelyAssigned = authoritativeDishId != null;
    final List<String> captureIds = List<String>.generate(
      media.length,
      (_) => _uuid.v4(),
    );
    final List<ImageDerivativeSet> previews = await _createCapturePreviews(
      captureIds,
      media,
    );
    try {
      await _database.transaction(() async {
        await _database.into(_database.captureBatches).insert(
              db.CaptureBatchesCompanion.insert(
                id: batchId,
                status: useLocalFallback || isAuthoritativelyAssigned
                    ? CaptureBatchStatus.applied.name
                    : CaptureBatchStatus.pendingUpload.name,
                createdAt: now,
                updatedAt: now,
              ),
            );
        for (int ordinal = 0; ordinal < media.length; ordinal += 1) {
          final String id = captureIds[ordinal];
          final CapturedMedia item = media[ordinal];
          await _database.into(_database.captureItems).insert(
                db.CaptureItemsCompanion.insert(
                  id: id,
                  batchId: Value<String?>(batchId),
                  ordinal: Value<int>(ordinal),
                  kind: capture_domain.CaptureItemKind.photo.name,
                  status: isAuthoritativelyAssigned
                      ? capture_domain.CaptureItemStatus.applied.name
                      : useLocalFallback
                          ? capture_domain.CaptureItemStatus.localOnly.name
                          : capture_domain.CaptureItemStatus.pendingUpload.name,
                  createdAt: now,
                  localMediaRef: Value<String?>(item.path),
                  localPreviewRef: Value<String?>(
                    previews[ordinal].processingRef,
                  ),
                  localThumbnailRef: Value<String?>(
                    previews[ordinal].cardRef,
                  ),
                  localPlaceholderRef: Value<String?>(
                    previews[ordinal].placeholderRef,
                  ),
                  capturedAt: Value<DateTime?>(item.capturedAt),
                  capturedLocalDate: Value<String?>(item.capturedLocalDate),
                  captureDateSource: Value<String?>(item.dateSource.apiValue),
                  appliedDishId: Value<String?>(authoritativeDishId),
                ),
              );
          if (authoritativeDishId != null) {
            await _database.into(_database.sourcePhotos).insert(
                  db.SourcePhotosCompanion.insert(
                    id: '${id}_source',
                    dishId: authoritativeDishId,
                    url: item.path,
                    previewUrl: Value<String?>(
                      previews[ordinal].processingRef,
                    ),
                    thumbnailUrl: Value<String?>(previews[ordinal].cardRef),
                    placeholderUrl: Value<String?>(
                      previews[ordinal].placeholderRef,
                    ),
                    capturedLabel: 'Today',
                    captureId: Value<String?>(id),
                    capturedAt: Value<DateTime?>(item.capturedAt),
                    confidenceLabel: const Value<String?>('Added to dish'),
                  ),
                );
            continue;
          }
          if (useLocalFallback) {
            continue;
          }
        }
        if (authoritativeDishId != null) {
          await (_database.update(_database.dishes)
                ..where(
                  (db.Dishes table) => table.id.equals(authoritativeDishId),
                ))
              .write(
            db.DishesCompanion(
              heroImageUrl: Value<String>(
                targetDish!.heroImageUrl.isEmpty
                    ? media.first.path
                    : targetDish.heroImageUrl,
              ),
              heroPreviewUrl: Value<String?>(
                targetDish.heroImageUrl.isEmpty
                    ? previews.first.processingRef
                    : targetDish.heroPreviewUrl,
              ),
              heroThumbnailUrl: Value<String?>(
                targetDish.heroImageUrl.isEmpty
                    ? previews.first.cardRef
                    : targetDish.heroThumbnailUrl,
              ),
              heroPlaceholderUrl: Value<String?>(
                targetDish.heroImageUrl.isEmpty
                    ? previews.first.placeholderRef
                    : targetDish.heroPlaceholderUrl,
              ),
              madeCount: Value<int>(targetDish.madeCount + 1),
              lastMadeLabel: const Value<String>('Today'),
            ),
          );
          final String correctionId = _uuid.v4();
          await _database.into(_database.captureCorrections).insert(
                db.CaptureCorrectionsCompanion.insert(
                  id: correctionId,
                  batchId: batchId,
                  actionType: CaptureCorrectionType.assign.name,
                  captureIdsJson: jsonEncode(captureIds),
                  previousDishIdsJson: jsonEncode(<String, Object?>{
                    for (final String captureId in captureIds)
                      captureId: <String, Object?>{
                        'dishId': null,
                        'status':
                            capture_domain.CaptureItemStatus.localOnly.name,
                        'failureReason': null,
                      },
                  }),
                  targetDishId: authoritativeDishId,
                  status: CaptureCorrectionStatus.synced.name,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
          return;
        }
        if (useLocalFallback) {
          return;
        }
        await _processingOutboxRepository.enqueueCaptureGrouping(
          requestId: jobId,
          batchId: batchId,
          captureIds: captureIds,
          now: now,
        );
      });
    } on Object {
      await _imageDerivativeStore.remove(
        refs: previews.expand((ImageDerivativeSet preview) => preview.refs),
      );
      rethrow;
    }

    return (await listBatches()).firstWhere(
      (CaptureBatch batch) => batch.id == batchId,
    );
  }

  Future<List<String>> createPhotoCaptures(
    List<Object> capturedMedia, {
    String? targetDishId,
  }) async {
    final CaptureBatch? batch = await createPhotoBatch(
      capturedMedia,
      targetDishId: targetDishId,
    );
    return batch?.items
            .map((capture_domain.CaptureItem item) => item.id)
            .toList(growable: false) ??
        const <String>[];
  }

  Future<String?> createIdeaCapture(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final String id = _uuid.v4();
    final String jobId = _uuid.v4();
    final DateTime now = DateTime.now();
    final String localDate = _dateKey(now);
    await _database.transaction(() async {
      await _database.into(_database.captureBatches).insert(
            db.CaptureBatchesCompanion.insert(
              id: id,
              status: CaptureBatchStatus.pendingUpload.name,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _database.into(_database.captureItems).insert(
            db.CaptureItemsCompanion.insert(
              id: id,
              batchId: Value<String?>(id),
              kind: capture_domain.CaptureItemKind.idea.name,
              status: capture_domain.CaptureItemStatus.pendingUpload.name,
              createdAt: now,
              ideaText: Value<String?>(trimmed),
              capturedAt: Value<DateTime?>(now),
              capturedLocalDate: Value<String?>(localDate),
              captureDateSource: const Value<String?>('camera'),
            ),
          );
      await _processingOutboxRepository.enqueueCaptureGrouping(
        requestId: jobId,
        batchId: id,
        captureIds: <String>[id],
        now: now,
      );
    });
    return id;
  }

  String _dateKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<List<ImageDerivativeSet>> _createCapturePreviews(
    List<String> captureIds,
    List<CapturedMedia> media,
  ) async {
    const ImageDerivativeSet empty = ImageDerivativeSet(
      processingRef: null,
      cardRef: null,
      placeholderRef: null,
    );
    final List<ImageDerivativeSet> previews =
        List<ImageDerivativeSet>.filled(media.length, empty);
    for (int index = 0; index < media.length; index += 2) {
      final List<int> indexes = <int>[
        index,
        if (index + 1 < media.length) index + 1,
      ];
      final List<ImageDerivativeSet> results = await Future.wait(
        indexes.map((int itemIndex) {
          return _imageDerivativeStore.ensureSet(
            key: 'capture_${captureIds[itemIndex]}',
            sourcePath: media[itemIndex].path,
          );
        }),
      );
      for (int resultIndex = 0;
          resultIndex < indexes.length;
          resultIndex += 1) {
        previews[indexes[resultIndex]] = results[resultIndex];
      }
    }
    return previews;
  }

  CapturedMedia _normalizeCapturedMedia(Object value) {
    if (value is CapturedMedia) {
      return value;
    }
    final DateTime now = DateTime.now();
    return CapturedMedia(
      path: value.toString(),
      capturedAt: now,
      capturedLocalDate: null,
      dateSource: CaptureDateSource.unknown,
    );
  }
}
