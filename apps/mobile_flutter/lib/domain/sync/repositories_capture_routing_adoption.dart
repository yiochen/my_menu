part of 'repositories.dart';

extension SyncRepositoryCaptureRoutingAdoption on SyncRepository {
  Future<void> _adoptCaptureRoutingProposal(
    ProcessingOutboxRequest request,
  ) async {
    try {
      await _validateAndAdoptCaptureRoutingProposal(request);
    } on FormatException {
      await ProcessingOutboxRepository(_database).rejectProposal(request.id);
      await _markBatchStatus(
        request.subjectId,
        CaptureBatchStatus.failed,
        failureReason: 'The processing result could not be safely applied.',
      );
      await _markCapturesFailed(
        request.subjectId,
        'The processing result could not be safely applied.',
      );
    }
  }

  Future<void> _validateAndAdoptCaptureRoutingProposal(
    ProcessingOutboxRequest request,
  ) async {
    final Map<String, Object?>? result = request.resultPayload;
    if (request.deliveryState != ProcessingDeliveryState.acknowledged ||
        request.adoptionState != ProcessingAdoptionState.readyForAdoption ||
        request.resultSchemaVersion != 'capture-grouping-result-v2' ||
        result == null ||
        result['decisions'] is! List<Object?>) {
      return;
    }
    _validateCaptureGroupingResult(
      request,
      result,
      schemaVersion: request.resultSchemaVersion!,
    );

    final List<String> expectedIds =
        (request.payload['captureIds']! as List<Object?>)
            .whereType<String>()
            .toList(growable: false);
    final List<db.CaptureItemRow> captures =
        await (_database.select(_database.captureItems)
              ..where(
                (db.CaptureItems table) =>
                    table.id.isIn(expectedIds) &
                    table.batchId.equals(request.subjectId),
              ))
            .get();
    if (captures.length != expectedIds.length ||
        captures.any(
          (db.CaptureItemRow capture) => capture.appliedDishId != null,
        )) {
      throw const FormatException('Capture state changed before adoption.');
    }
    final Map<String, db.CaptureItemRow> captureById =
        <String, db.CaptureItemRow>{
      for (final db.CaptureItemRow capture in captures) capture.id: capture,
    };
    final Set<String> submittedDishIds =
        (request.payload['submittedDishIds'] as List<Object?>? ??
                const <Object?>[])
            .whereType<String>()
            .toSet();
    final List<Map<String, Object?>> decisions =
        (result['decisions']! as List<Object?>)
            .map(
              (Object? value) =>
                  Map<String, Object?>.from(value! as Map<dynamic, dynamic>),
            )
            .toList(growable: false);
    final Set<String> routedDishIds = decisions
        .map(
          (Map<String, Object?> decision) =>
              (decision['outcome']! as Map<String, Object?>)['localDishId'],
        )
        .whereType<String>()
        .toSet();
    if (!submittedDishIds.containsAll(routedDishIds)) {
      throw const FormatException('A route references an unsubmitted dish.');
    }
    if (routedDishIds.isNotEmpty) {
      final List<db.DishRow> existing =
          await (_database.select(_database.dishes)
                ..where((db.Dishes table) => table.id.isIn(routedDishIds)))
              .get();
      if (existing.length != routedDishIds.length) {
        throw const FormatException('A routed dish is no longer available.');
      }
    }

    final CaptureCorrectionRepository corrections =
        CaptureCorrectionRepository(_database);
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      for (int index = 0; index < decisions.length; index += 1) {
        final Map<String, Object?> decision = decisions[index];
        final List<String> captureIds =
            (decision['captureIds']! as List<Object?>).cast<String>();
        final List<db.CaptureItemRow> items = captureIds
            .map((String id) => captureById[id]!)
            .toList(growable: false);
        final Map<String, Object?> outcome = Map<String, Object?>.from(
          decision['outcome']! as Map<dynamic, dynamic>,
        );
        final String type = outcome['type']! as String;
        switch (type) {
          case 'existing_dish':
            final String dishId = outcome['localDishId']! as String;
            await corrections._moveLocalAssignments(
              batchId: request.subjectId,
              items: items,
              targetDishId: dishId,
            );
            await _recordRoutingCorrection(
              request: request,
              decisionIndex: index,
              items: items,
              targetDishId: dishId,
              now: now,
            );
          case 'new_dish':
            final Map<String, Object?> draft = Map<String, Object?>.from(
              outcome['draft']! as Map<dynamic, dynamic>,
            );
            final String dishId = const Uuid().v4();
            await corrections._insertLocalDish(
              id: dishId,
              title: draft['title']! as String,
              items: items,
            );
            await (_database.update(_database.dishes)
                  ..where((db.Dishes table) => table.id.equals(dishId)))
                .write(
              db.DishesCompanion(
                description: Value<String>(
                  draft['description'] is String
                      ? draft['description']! as String
                      : '',
                ),
                ingredientsJson: Value<String>(
                  jsonEncode(
                    (draft['visibleIngredients'] as List<Object?>? ??
                            const <Object?>[])
                        .whereType<String>()
                        .toList(growable: false),
                  ),
                ),
              ),
            );
            await corrections._moveLocalAssignments(
              batchId: request.subjectId,
              items: items,
              targetDishId: dishId,
            );
            await _recordRoutingCorrection(
              request: request,
              decisionIndex: index,
              items: items,
              targetDishId: dishId,
              createdDishId: dishId,
              now: now,
            );
            await CoverRepository(_database).enqueueAutomaticCover(
              dishId: dishId,
              sourceIds: items
                  .take(3)
                  .map((db.CaptureItemRow item) => '${item.id}_source')
                  .toList(growable: false),
              now: now,
            );
          case 'unresolved':
            final db.CaptureItemRow item = items.single;
            final List<String> uncertainty =
                (decision['uncertainty']! as List<Object?>).cast<String>();
            final List<String> evidence =
                (decision['evidence']! as List<Object?>).cast<String>();
            await _database.into(_database.reviewItems).insertOnConflictUpdate(
                  db.ReviewItemsCompanion.insert(
                    id: 'review_${request.id}_${item.id}',
                    captureId: Value<String?>(item.id),
                    summary: uncertainty.isNotEmpty
                        ? uncertainty.join(' ')
                        : evidence.join(' '),
                    suggestedDishIdsJson: '[]',
                    confidenceLabel: 'Unresolved',
                    imageRef: Value<String?>(item.localMediaRef),
                  ),
                );
            await (_database.update(_database.captureItems)
                  ..where(
                    (db.CaptureItems table) => table.id.equals(item.id),
                  ))
                .write(
              db.CaptureItemsCompanion(
                status: Value<String>(
                  capture_domain.CaptureItemStatus.needsReview.name,
                ),
                failureReason: const Value<String?>(null),
              ),
            );
          case 'not_a_dish':
            final db.CaptureItemRow item = items.single;
            await (_database.update(_database.captureItems)
                  ..where(
                    (db.CaptureItems table) => table.id.equals(item.id),
                  ))
                .write(
              db.CaptureItemsCompanion(
                status: Value<String>(
                  capture_domain.CaptureItemStatus.notADish.name,
                ),
                failureReason: const Value<String?>(null),
              ),
            );
        }
      }
      await (_database.update(_database.captureBatches)
            ..where(
              (db.CaptureBatches table) => table.id.equals(request.subjectId),
            ))
          .write(
        db.CaptureBatchesCompanion(
          status: Value<String>(CaptureBatchStatus.applied.name),
          updatedAt: Value<DateTime>(now),
          failureReason: const Value<String?>(null),
        ),
      );
      await (_database.update(_database.processingOutbox)
            ..where(
              (db.ProcessingOutbox table) =>
                  table.id.equals(request.id) &
                  table.adoptionState.equals(
                    ProcessingAdoptionState.readyForAdoption.name,
                  ),
            ))
          .write(
        db.ProcessingOutboxCompanion(
          adoptionState: Value<String>(ProcessingAdoptionState.adopted.name),
          updatedAt: Value<DateTime>(now),
        ),
      );
    });
  }

  Future<void> _recordRoutingCorrection({
    required ProcessingOutboxRequest request,
    required int decisionIndex,
    required List<db.CaptureItemRow> items,
    required String targetDishId,
    required DateTime now,
    String? createdDishId,
  }) async {
    await _database.into(_database.captureCorrections).insertOnConflictUpdate(
          db.CaptureCorrectionsCompanion.insert(
            id: 'auto_${request.id}_$decisionIndex',
            batchId: request.subjectId,
            actionType: CaptureCorrectionType.autoAssign.name,
            captureIdsJson: jsonEncode(
              items.map((db.CaptureItemRow item) => item.id).toList(),
            ),
            previousDishIdsJson: jsonEncode(<String, Object?>{
              for (final db.CaptureItemRow item in items)
                item.id: <String, Object?>{
                  'dishId': item.appliedDishId,
                  'status': item.status,
                  'failureReason': item.failureReason,
                },
            }),
            targetDishId: targetDishId,
            createdDishId: Value<String?>(createdDishId),
            status: CaptureCorrectionStatus.synced.name,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }
}
