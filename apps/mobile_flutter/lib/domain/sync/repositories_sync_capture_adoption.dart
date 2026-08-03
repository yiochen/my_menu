part of 'repositories.dart';

extension SyncRepositoryCaptureAdoption on SyncRepository {
  Future<bool> _upsertCapture(
    ApiCapture capture, {
    String? createdDishId,
  }) async {
    final db.CaptureItemRow? existing =
        await (_database.select(_database.captureItems)
              ..where((db.CaptureItems table) => table.id.equals(capture.id)))
            .getSingleOrNull();
    if (existing == null && await _isRejectedBatch(capture.batchId)) {
      return false;
    }
    final bool preserveLocalOrganization = existing != null &&
        await _hasAuthoritativeLocalOrganization(capture.id, existing.batchId);
    if (!preserveLocalOrganization &&
        existing != null &&
        existing.appliedDishId == null &&
        capture.appliedDishId != null) {
      await _recordAutomaticOrganization(
        existing,
        capture.appliedDishId!,
        createdDishId: createdDishId,
      );
    }

    await _database.into(_database.captureItems).insertOnConflictUpdate(
          db.CaptureItemsCompanion.insert(
            id: capture.id,
            batchId: Value<String?>(existing?.batchId ?? capture.batchId),
            ordinal: Value<int>(capture.ordinal ?? existing?.ordinal ?? 0),
            kind: capture.kind,
            status: preserveLocalOrganization
                ? existing.status
                : _localCaptureStatus(capture.status),
            createdAt: capture.capturedAt,
            localMediaRef: Value<String?>(existing?.localMediaRef),
            remoteMediaRef: Value<String?>(capture.image?.mediaRef),
            ideaText: Value<String?>(capture.ideaText),
            capturedAt: Value<DateTime?>(capture.capturedAt),
            capturedLocalDate: Value<String?>(capture.capturedLocalDate),
            captureDateSource: Value<String?>(capture.captureDateSource),
            appliedDishId: Value<String?>(preserveLocalOrganization
                ? existing.appliedDishId
                : capture.appliedDishId),
            failureReason: Value<String?>(preserveLocalOrganization
                ? existing.failureReason
                : capture.failureReason),
          ),
        );
    final String? batchId = existing?.batchId ?? capture.batchId;
    if (!preserveLocalOrganization &&
        batchId != null &&
        capture.status == 'needs_review') {
      await ProcessingOutboxRepository(_database).markProposalReadyForSubject(
        kind: ProcessingRequestKind.captureGrouping,
        subjectId: batchId,
      );
    }
    return !(preserveLocalOrganization &&
        capture.appliedDishId != existing.appliedDishId);
  }

  Future<void> _upsertReviewItem(ApiReviewItem item) async {
    final db.CaptureItemRow? capture =
        await (_database.select(_database.captureItems)
              ..where(
                (db.CaptureItems table) => table.id.equals(item.captureId),
              ))
            .getSingleOrNull();
    if (capture == null) {
      return;
    }
    if (await _hasAuthoritativeLocalOrganization(
      capture.id,
      capture.batchId,
    )) {
      return;
    }
    await _database.into(_database.reviewItems).insertOnConflictUpdate(
          db.ReviewItemsCompanion.insert(
            id: item.id,
            captureId: Value<String?>(item.captureId),
            summary: item.summary,
            suggestedDishIdsJson: jsonEncode(item.suggestedDishIds),
            confidenceLabel: item.confidenceLabel ?? item.status,
          ),
        );
  }

  Future<bool> _hasAuthoritativeLocalOrganization(
    String captureId,
    String? batchId,
  ) async {
    if (batchId != null) {
      final db.ProcessingOutboxRow? request =
          await (_database.select(_database.processingOutbox)
                ..where(
                  (db.ProcessingOutbox table) =>
                      table.subjectId.equals(batchId) &
                      table.adoptionState.equals(
                        ProcessingAdoptionState.rejected.name,
                      ),
                )
                ..limit(1))
              .getSingleOrNull();
      if (request != null) {
        return true;
      }
    }
    final List<db.CaptureCorrectionRow> corrections =
        await (_database.select(_database.captureCorrections)
              ..where(
                (db.CaptureCorrections table) => table.status.isIn(<String>[
                  CaptureCorrectionStatus.pending.name,
                  CaptureCorrectionStatus.synced.name,
                ]),
              ))
            .get();
    return corrections.any((db.CaptureCorrectionRow correction) {
      final Object? decoded = jsonDecode(correction.captureIdsJson);
      return decoded is List<dynamic> && decoded.contains(captureId);
    });
  }

  Future<bool> _isRejectedBatch(String? batchId) async {
    if (batchId == null) {
      return false;
    }
    final db.ProcessingOutboxRow? request =
        await (_database.select(_database.processingOutbox)
              ..where(
                (db.ProcessingOutbox table) =>
                    table.subjectId.equals(batchId) &
                    table.adoptionState.equals(
                      ProcessingAdoptionState.rejected.name,
                    ),
              )
              ..limit(1))
            .getSingleOrNull();
    return request != null;
  }

  Future<void> _recordAutomaticOrganization(
    db.CaptureItemRow existing,
    String targetDishId, {
    String? createdDishId,
  }) async {
    final DateTime now = DateTime.now();
    final String correctionId = 'auto_${existing.id}_$targetDishId';
    await _database.into(_database.captureCorrections).insertOnConflictUpdate(
          db.CaptureCorrectionsCompanion.insert(
            id: correctionId,
            batchId: existing.batchId ?? existing.id,
            actionType: CaptureCorrectionType.autoAssign.name,
            captureIdsJson: jsonEncode(<String>[existing.id]),
            previousDishIdsJson: jsonEncode(<String, Object?>{
              existing.id: <String, Object?>{
                'dishId': existing.appliedDishId,
                'status': existing.status,
                'failureReason': existing.failureReason,
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

  String _localCaptureStatus(String status) {
    return switch (status) {
      'needs_review' => capture_domain.CaptureItemStatus.needsReview.name,
      _ => status,
    };
  }
}
