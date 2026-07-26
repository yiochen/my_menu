part of 'repositories.dart';

class AiJobRepository {
  AiJobRepository(this._database);

  final db.AppDatabase _database;
  static const Uuid _uuid = Uuid();

  Future<List<AiJob>> listJobs() async {
    final List<db.AiJobRow> rows = await (_database.select(_database.aiJobs)
          ..where((db.AiJobs table) => table.dismissedAt.isNull())
          ..orderBy(<OrderingTerm Function(db.$AiJobsTable)>[
            (db.$AiJobsTable table) => OrderingTerm.desc(table.updatedAt),
          ]))
        .get();
    return rows.map(_aiJobFromRow).toList(growable: false);
  }

  Future<AiJob> schedule({
    required AiJobType type,
    required String subjectId,
    required String inputHash,
    required String inputVersion,
    String promptVersion = '1',
    String modelVersion = 'default',
    String schemaVersion = '1',
    int maxAttempts = 3,
  }) async {
    final String idempotencyKey = '${type.apiValue}:$subjectId:$inputVersion';
    final db.AiJobRow? existing = await (_database.select(_database.aiJobs)
          ..where(
            (db.AiJobs table) => table.idempotencyKey.equals(idempotencyKey),
          ))
        .getSingleOrNull();
    if (existing != null) {
      return _aiJobFromRow(existing);
    }

    final DateTime now = DateTime.now();
    final db.AiJobRow row = db.AiJobRow(
      id: _uuid.v4(),
      jobType: type.apiValue,
      subjectId: subjectId,
      status: AiJobStatus.pendingOffline.databaseValue,
      idempotencyKey: idempotencyKey,
      inputHash: inputHash,
      inputVersion: inputVersion,
      attemptCount: 0,
      maxAttempts: maxAttempts,
      promptVersion: promptVersion,
      modelVersion: modelVersion,
      schemaVersion: schemaVersion,
      pendingAction: 'schedule',
      createdAt: now,
      updatedAt: now,
    );
    await _database.into(_database.aiJobs).insert(row);
    return _aiJobFromRow(row);
  }

  Future<void> requestRetry(String jobId) async {
    await (_database.update(_database.aiJobs)
          ..where(
            (db.AiJobs table) =>
                table.id.equals(jobId) & table.status.equals('failed'),
          ))
        .write(
      db.AiJobsCompanion(
        status: Value<String>(AiJobStatus.pendingOffline.databaseValue),
        pendingAction: const Value<String?>('retry'),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  Future<void> requestCancel(String jobId) async {
    final db.AiJobRow? row = await (_database.select(
      _database.aiJobs,
    )..where((db.AiJobs table) => table.id.equals(jobId)))
        .getSingleOrNull();
    if (row == null) {
      return;
    }
    if (row.pendingAction == 'schedule') {
      await (_database.update(
        _database.aiJobs,
      )..where((db.AiJobs table) => table.id.equals(jobId)))
          .write(
        db.AiJobsCompanion(
          status: Value<String>(AiJobStatus.canceled.databaseValue),
          pendingAction: const Value<String?>(null),
          updatedAt: Value<DateTime>(DateTime.now()),
        ),
      );
      return;
    }
    final AiJobStatus status = AiJobStatus.fromDatabase(row.status);
    if (!status.canCancel) {
      return;
    }
    await (_database.update(
      _database.aiJobs,
    )..where((db.AiJobs table) => table.id.equals(jobId)))
        .write(
      db.AiJobsCompanion(
        status: Value<String>(AiJobStatus.canceled.databaseValue),
        pendingAction: const Value<String?>('cancel'),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  Future<void> dismiss(String jobId) async {
    await (_database.update(
      _database.aiJobs,
    )..where((db.AiJobs table) => table.id.equals(jobId)))
        .write(
      db.AiJobsCompanion(
        dismissedAt: Value<DateTime?>(DateTime.now()),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }
}

AiJob _aiJobFromRow(db.AiJobRow row) {
  return AiJob(
    id: row.id,
    type: AiJobType.fromApiValue(row.jobType),
    subjectId: row.subjectId,
    status: AiJobStatus.fromDatabase(row.status),
    idempotencyKey: row.idempotencyKey,
    inputHash: row.inputHash,
    inputVersion: row.inputVersion,
    attemptCount: row.attemptCount,
    maxAttempts: row.maxAttempts,
    promptVersion: row.promptVersion,
    modelVersion: row.modelVersion,
    schemaVersion: row.schemaVersion,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    nextRetryAt: row.nextRetryAt,
    normalizedResult: _decodeOptionalObject(row.resultJson),
    normalizedError: _decodeOptionalObject(row.errorJson),
    startedAt: row.startedAt,
    completedAt: row.completedAt,
    pendingAction: row.pendingAction,
  );
}

Map<String, Object?>? _decodeOptionalObject(String? value) {
  if (value == null) {
    return null;
  }
  final Object? decoded = jsonDecode(value);
  if (decoded is Map<String, dynamic>) {
    return Map<String, Object?>.from(decoded);
  }
  return null;
}

extension SyncRepositoryAiJobs on SyncRepository {
  Future<void> processPendingAiJobs() async {
    final List<db.AiJobRow> rows = await (_database.select(_database.aiJobs)
          ..where((db.AiJobs table) => table.pendingAction.isNotNull())
          ..where(
            (db.AiJobs table) =>
                table.pendingAction.equals('finalize_capture').not(),
          )
          ..orderBy(<OrderingTerm Function(db.$AiJobsTable)>[
            (db.$AiJobsTable table) => OrderingTerm.asc(table.createdAt),
          ]))
        .get();
    for (final db.AiJobRow row in rows) {
      try {
        final ApiAiJob remote = switch (row.pendingAction) {
          'schedule' => await _apiClient
              .scheduleAiJob(
                jobId: row.id,
                jobType: row.jobType,
                subjectId: row.subjectId,
                idempotencyKey: row.idempotencyKey,
                inputHash: row.inputHash,
                inputVersion: row.inputVersion,
                promptVersion: row.promptVersion,
                modelVersion: row.modelVersion,
                schemaVersion: row.schemaVersion,
                maxAttempts: row.maxAttempts,
              )
              .timeout(_controlRequestTimeout),
          'retry' => await _apiClient
              .retryAiJob(jobId: row.id)
              .timeout(_controlRequestTimeout),
          'cancel' => await _apiClient
              .cancelAiJob(jobId: row.id)
              .timeout(_controlRequestTimeout),
          _ => throw StateError('Unknown AI job action ${row.pendingAction}.'),
        };
        await _upsertAiJob(remote, localJobId: row.id);
      } on Object catch (error, stackTrace) {
        _logSync('AI job sync failed id=${row.id}', error, stackTrace);
        if (!_isConnectivityError(error)) {
          await (_database.update(
            _database.aiJobs,
          )..where((db.AiJobs table) => table.id.equals(row.id)))
              .write(
            db.AiJobsCompanion(
              status: Value<String>(AiJobStatus.failed.databaseValue),
              errorJson: Value<String?>(
                jsonEncode(<String, Object?>{
                  'code': 'scheduling_failed',
                  'message': error.toString(),
                }),
              ),
              pendingAction: const Value<String?>(null),
              updatedAt: Value<DateTime>(DateTime.now()),
            ),
          );
        }
      }
    }
  }

  Future<void> _upsertAiJob(ApiAiJob job, {String? localJobId}) async {
    await _database.transaction(() async {
      if (localJobId != null && localJobId != job.id) {
        await (_database.delete(
          _database.aiJobs,
        )..where((db.AiJobs table) => table.id.equals(localJobId)))
            .go();
      }
      final db.AiJobRow? existing = await (_database.select(
        _database.aiJobs,
      )..where((db.AiJobs table) => table.id.equals(job.id)))
          .getSingleOrNull();
      await _database.into(_database.aiJobs).insertOnConflictUpdate(
            db.AiJobsCompanion.insert(
              id: job.id,
              jobType: job.jobType,
              subjectId: job.subjectId,
              status: job.status,
              idempotencyKey: job.idempotencyKey,
              inputHash: job.inputHash,
              inputVersion: job.inputVersion,
              attemptCount: Value<int>(job.attemptCount),
              maxAttempts: Value<int>(job.maxAttempts),
              nextRetryAt: Value<DateTime?>(job.nextRetryAt),
              promptVersion: Value<String>(job.promptVersion),
              modelVersion: Value<String>(job.modelVersion),
              schemaVersion: Value<String>(job.schemaVersion),
              resultJson: Value<String?>(
                job.normalizedResult == null
                    ? null
                    : jsonEncode(job.normalizedResult),
              ),
              errorJson: Value<String?>(
                job.normalizedError == null
                    ? null
                    : jsonEncode(job.normalizedError),
              ),
              pendingAction: const Value<String?>(null),
              startedAt: Value<DateTime?>(job.startedAt),
              completedAt: Value<DateTime?>(job.completedAt),
              dismissedAt: Value<DateTime?>(existing?.dismissedAt),
              createdAt: job.createdAt,
              updatedAt: job.updatedAt,
            ),
          );
    });
  }
}
