import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/domain/processing/processing_consent_repository.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/processing/processing_privacy_notice.dart';

class ProcessingOutboxRepository {
  ProcessingOutboxRepository(this._database);

  final db.AppDatabase _database;

  Future<List<ProcessingOutboxRequest>> listRequests() async {
    final rows = await (_database.select(_database.processingOutbox)
          ..orderBy(<OrderingTerm Function(db.$ProcessingOutboxTable)>[
            (db.$ProcessingOutboxTable table) =>
                OrderingTerm.asc(table.createdAt),
          ]))
        .get();
    return rows.map(_requestFromRow).toList(growable: false);
  }

  Future<ProcessingOutboxRequest?> requestForSubject({
    required ProcessingRequestKind kind,
    required String subjectId,
  }) async {
    final db.ProcessingOutboxRow? row = await (_database.select(
      _database.processingOutbox,
    )..where(
            (db.ProcessingOutbox table) =>
                table.requestKind.equals(kind.databaseValue) &
                table.subjectId.equals(subjectId),
          ))
        .getSingleOrNull();
    return row == null ? null : _requestFromRow(row);
  }

  Future<bool> claimForUpload(String requestId) {
    return _database.transaction(() async {
      final ProcessingConsentDecision consent =
          await ProcessingConsentRepository(_database).currentDecision();
      if (consent != ProcessingConsentDecision.accepted) {
        return false;
      }
      final int changed = await (_database.update(_database.processingOutbox)
            ..where(
              (db.ProcessingOutbox table) =>
                  table.id.equals(requestId) &
                  table.privacyNoticeVersion.equals(
                    ProcessingPrivacyNotice.currentVersion,
                  ) &
                  (table.deliveryState.equals(
                        ProcessingDeliveryState.pendingUpload.name,
                      ) |
                      table.deliveryState.equals(
                        ProcessingDeliveryState.uploading.name,
                      )),
            ))
          .write(
        db.ProcessingOutboxCompanion(
          deliveryState: Value<String>(
            ProcessingDeliveryState.uploading.name,
          ),
          updatedAt: Value<DateTime>(DateTime.now()),
        ),
      );
      return changed == 1;
    });
  }

  Future<void> enqueueCaptureGrouping({
    required String requestId,
    required String batchId,
    required List<String> captureIds,
    required DateTime now,
  }) async {
    final bool isAccepted =
        await ProcessingConsentRepository(_database).currentDecision() ==
            ProcessingConsentDecision.accepted;
    await _database.into(_database.processingOutbox).insert(
          db.ProcessingOutboxCompanion.insert(
            id: requestId,
            requestKind: ProcessingRequestKind.captureGrouping.databaseValue,
            subjectId: batchId,
            payloadJson: jsonEncode(<String, Object?>{
              'batchId': batchId,
              'captureIds': captureIds,
            }),
            deliveryState: isAccepted
                ? ProcessingDeliveryState.pendingUpload.name
                : ProcessingDeliveryState.waitingForConsent.name,
            adoptionState: ProcessingAdoptionState.awaitingProposal.name,
            privacyNoticeVersion: Value<String?>(
              isAccepted ? ProcessingPrivacyNotice.currentVersion : null,
            ),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<bool> cancelBeforeUpload(String requestId) async {
    final int changed = await (_database.update(_database.processingOutbox)
          ..where(
            (db.ProcessingOutbox table) =>
                table.id.equals(requestId) &
                (table.deliveryState.equals(
                      ProcessingDeliveryState.waitingForConsent.name,
                    ) |
                    table.deliveryState.equals(
                      ProcessingDeliveryState.pendingUpload.name,
                    )),
          ))
        .write(
      db.ProcessingOutboxCompanion(
        deliveryState: Value<String>(ProcessingDeliveryState.canceled.name),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
    return changed == 1;
  }

  Future<void> retryCaptureGrouping({
    required String batchId,
    required DateTime now,
  }) async {
    final bool isAccepted =
        await ProcessingConsentRepository(_database).currentDecision() ==
            ProcessingConsentDecision.accepted;
    await (_database.update(_database.processingOutbox)
          ..where(
            (db.ProcessingOutbox table) =>
                table.requestKind.equals(
                  ProcessingRequestKind.captureGrouping.databaseValue,
                ) &
                table.subjectId.equals(batchId) &
                table.deliveryState.equals(
                  ProcessingDeliveryState.failed.name,
                ),
          ))
        .write(
      db.ProcessingOutboxCompanion(
        deliveryState: Value<String>(
          isAccepted
              ? ProcessingDeliveryState.pendingUpload.name
              : ProcessingDeliveryState.waitingForConsent.name,
        ),
        privacyNoticeVersion: Value<String?>(
          isAccepted ? ProcessingPrivacyNotice.currentVersion : null,
        ),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }

  Future<void> markSubmitted(String requestId) {
    return _setDeliveryState(
      requestId,
      ProcessingDeliveryState.submitted,
      from: ProcessingDeliveryState.uploading,
    );
  }

  Future<void> markFailed(String requestId) async {
    await (_database.update(_database.processingOutbox)
          ..where(
            (db.ProcessingOutbox table) =>
                table.id.equals(requestId) &
                table.deliveryState.equals(
                  ProcessingDeliveryState.uploading.name,
                ),
          ))
        .write(
      db.ProcessingOutboxCompanion(
        deliveryState: Value<String>(ProcessingDeliveryState.failed.name),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  Future<void> markProposalReady(String requestId) {
    return _setAdoptionState(
      requestId,
      ProcessingAdoptionState.readyForAdoption,
      from: ProcessingAdoptionState.awaitingProposal,
    );
  }

  Future<void> markAdopted(String requestId) {
    return _setAdoptionStateWhere(
      (db.ProcessingOutbox table) =>
          table.id.equals(requestId) &
          (table.adoptionState.equals(
                ProcessingAdoptionState.awaitingProposal.name,
              ) |
              table.adoptionState.equals(
                ProcessingAdoptionState.readyForAdoption.name,
              )),
      ProcessingAdoptionState.adopted,
    );
  }

  Future<void> rejectProposal(String requestId) {
    return _setAdoptionStateWhere(
      (db.ProcessingOutbox table) => table.id.equals(requestId),
      ProcessingAdoptionState.rejected,
    );
  }

  Future<void> supersedeCaptureGrouping(String batchId) async {
    final DateTime now = DateTime.now();
    await (_database.update(_database.processingOutbox)
          ..where(
            (db.ProcessingOutbox table) =>
                table.requestKind.equals(
                  ProcessingRequestKind.captureGrouping.databaseValue,
                ) &
                table.subjectId.equals(batchId),
          ))
        .write(
      db.ProcessingOutboxCompanion(
        adoptionState: Value<String>(ProcessingAdoptionState.rejected.name),
        updatedAt: Value<DateTime>(now),
      ),
    );
    await (_database.update(_database.processingOutbox)
          ..where(
            (db.ProcessingOutbox table) =>
                table.requestKind.equals(
                  ProcessingRequestKind.captureGrouping.databaseValue,
                ) &
                table.subjectId.equals(batchId) &
                (table.deliveryState.equals(
                      ProcessingDeliveryState.waitingForConsent.name,
                    ) |
                    table.deliveryState.equals(
                      ProcessingDeliveryState.pendingUpload.name,
                    )),
          ))
        .write(
      db.ProcessingOutboxCompanion(
        deliveryState: Value<String>(ProcessingDeliveryState.canceled.name),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }

  Future<void> markProposalReadyForSubject({
    required ProcessingRequestKind kind,
    required String subjectId,
  }) {
    return _setAdoptionStateWhere(
      (db.ProcessingOutbox table) =>
          table.requestKind.equals(kind.databaseValue) &
          table.subjectId.equals(subjectId) &
          table.adoptionState.equals(
            ProcessingAdoptionState.awaitingProposal.name,
          ),
      ProcessingAdoptionState.readyForAdoption,
    );
  }

  Future<void> markAdoptedForSubject({
    required ProcessingRequestKind kind,
    required String subjectId,
  }) {
    return _setAdoptionStateWhere(
      (db.ProcessingOutbox table) =>
          table.requestKind.equals(kind.databaseValue) &
          table.subjectId.equals(subjectId) &
          (table.adoptionState.equals(
                ProcessingAdoptionState.awaitingProposal.name,
              ) |
              table.adoptionState.equals(
                ProcessingAdoptionState.readyForAdoption.name,
              )),
      ProcessingAdoptionState.adopted,
    );
  }

  Future<void> _setDeliveryState(
    String requestId,
    ProcessingDeliveryState next, {
    required ProcessingDeliveryState from,
  }) async {
    await (_database.update(_database.processingOutbox)
          ..where(
            (db.ProcessingOutbox table) =>
                table.id.equals(requestId) &
                table.deliveryState.equals(from.name),
          ))
        .write(
      db.ProcessingOutboxCompanion(
        deliveryState: Value<String>(next.name),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  Future<void> _setAdoptionState(
    String requestId,
    ProcessingAdoptionState next, {
    required ProcessingAdoptionState from,
  }) async {
    await _setAdoptionStateWhere(
      (db.ProcessingOutbox table) =>
          table.id.equals(requestId) & table.adoptionState.equals(from.name),
      next,
    );
  }

  Future<void> _setAdoptionStateWhere(
    Expression<bool> Function(db.ProcessingOutbox table) predicate,
    ProcessingAdoptionState next,
  ) async {
    await (_database.update(_database.processingOutbox)..where(predicate))
        .write(
      db.ProcessingOutboxCompanion(
        adoptionState: Value<String>(next.name),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }
}

ProcessingOutboxRequest _requestFromRow(db.ProcessingOutboxRow row) {
  final Object? decoded = jsonDecode(row.payloadJson);
  return ProcessingOutboxRequest(
    id: row.id,
    kind: ProcessingRequestKind.fromDatabase(row.requestKind),
    subjectId: row.subjectId,
    payload: decoded is Map<String, dynamic>
        ? Map<String, Object?>.from(decoded)
        : const <String, Object?>{},
    deliveryState: ProcessingDeliveryState.values.byName(row.deliveryState),
    adoptionState: ProcessingAdoptionState.values.byName(row.adoptionState),
    privacyNoticeVersion: row.privacyNoticeVersion,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
