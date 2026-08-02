import 'package:drift/drift.dart';
import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/processing/processing_privacy_notice.dart';

class ProcessingConsentRepository {
  ProcessingConsentRepository(this._database);

  final db.AppDatabase _database;

  Future<ProcessingConsentDecision> currentDecision() async {
    final db.ProcessingConsentRow? row =
        await (_database.select(_database.processingConsents)
          ..where(
            (db.ProcessingConsents table) => table.noticeVersion.equals(
              ProcessingPrivacyNotice.currentVersion,
            ),
          ))
        .getSingleOrNull();
    return row == null
        ? ProcessingConsentDecision.notDecided
        : ProcessingConsentDecision.values.byName(row.decision);
  }

  Future<void> acceptCurrentNotice() {
    return _recordDecision(ProcessingConsentDecision.accepted);
  }

  Future<void> declineCurrentNotice() {
    return _recordDecision(ProcessingConsentDecision.declined);
  }

  Future<void> disableAiProcessing() {
    return _recordDecision(ProcessingConsentDecision.declined);
  }

  Future<void> _recordDecision(ProcessingConsentDecision decision) async {
    final DateTime now = DateTime.now();
    await _database.transaction(() async {
      await _database.into(_database.processingConsents).insertOnConflictUpdate(
            db.ProcessingConsentsCompanion.insert(
              noticeVersion: ProcessingPrivacyNotice.currentVersion,
              decision: decision.name,
              decidedAt: now,
            ),
          );
      if (decision == ProcessingConsentDecision.accepted) {
        await (_database.update(_database.processingOutbox)
              ..where(
                (db.ProcessingOutbox table) => table.deliveryState.equals(
                  ProcessingDeliveryState.waitingForConsent.name,
                ),
              ))
            .write(
          db.ProcessingOutboxCompanion(
            deliveryState: Value<String>(
              ProcessingDeliveryState.pendingUpload.name,
            ),
            privacyNoticeVersion: const Value<String?>(
              ProcessingPrivacyNotice.currentVersion,
            ),
            updatedAt: Value<DateTime>(now),
          ),
        );
        return;
      }
      await (_database.update(_database.processingOutbox)
            ..where(
              (db.ProcessingOutbox table) => table.deliveryState.equals(
                ProcessingDeliveryState.pendingUpload.name,
              ),
            ))
          .write(
        db.ProcessingOutboxCompanion(
          deliveryState: Value<String>(
            ProcessingDeliveryState.waitingForConsent.name,
          ),
          privacyNoticeVersion: const Value<String?>(null),
          updatedAt: Value<DateTime>(now),
        ),
      );
    });
  }
}
