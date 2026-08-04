import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/domain/ai/ai_job.dart';
import 'package:mymenu/domain/processing/processing_consent_repository.dart';
import 'package:mymenu/domain/sync/repositories.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('AI job persistence', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      await ProcessingConsentRepository(database).acceptCurrentNotice();
    });

    tearDown(() => database.close());

    test('repeated scheduling creates one local and one backend job', () async {
      final _RecordingAiApiClient api = _RecordingAiApiClient();
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: api,
      );

      final AiJob first = await repositories.aiJobRepository.schedule(
        type: AiJobType.batchGrouping,
        subjectId: '60000000-0000-4000-8000-000000000301',
        inputHash: 'hash-301',
        inputVersion: '1',
      );
      final AiJob repeated = await repositories.aiJobRepository.schedule(
        type: AiJobType.batchGrouping,
        subjectId: '60000000-0000-4000-8000-000000000301',
        inputHash: 'hash-301',
        inputVersion: '1',
      );

      expect(repeated.id, first.id);
      expect(await database.select(database.aiJobs).get(), hasLength(1));

      await repositories.syncRepository.processPendingAiJobs();
      await repositories.syncRepository.processPendingAiJobs();

      expect(api.scheduledIds, <String>[first.id]);
      expect(
        (await repositories.aiJobRepository.listJobs()).single.status,
        AiJobStatus.queued,
      );
    });

    test('offline scheduling remains visible and retries after reconnect',
        () async {
      final _ReconnectAiApiClient api = _ReconnectAiApiClient();
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: api,
      );
      await repositories.aiJobRepository.schedule(
        type: AiJobType.coverGeneration,
        subjectId: '60000000-0000-4000-8000-000000000302',
        inputHash: 'hash-302',
        inputVersion: 'cover-1',
      );

      await repositories.syncRepository.processPendingAiJobs();
      AiJob job = (await repositories.aiJobRepository.listJobs()).single;

      expect(job.status, AiJobStatus.pendingOffline);
      expect(job.pendingAction, 'schedule');

      api.isOnline = true;
      await repositories.syncRepository.processPendingAiJobs();
      job = (await repositories.aiJobRepository.listJobs()).single;

      expect(job.status, AiJobStatus.queued);
      expect(job.pendingAction, isNull);
      expect(api.scheduleAttempts, 2);
    });

    test('synced job rehydrates after restart without rescheduling', () async {
      final Directory temp =
          await Directory.systemTemp.createTemp('mymenu_ai_restart_');
      addTearDown(() => temp.delete(recursive: true));
      final File databaseFile = File('${temp.path}/mymenu.sqlite');
      final _RecordingAiApiClient api = _RecordingAiApiClient();

      final AppDatabase firstDatabase =
          AppDatabase.forTesting(NativeDatabase(databaseFile));
      final AppRepositories firstRepositories = AppRepositories(
        database: firstDatabase,
        apiClient: api,
      );
      await firstRepositories.processingConsentRepository.acceptCurrentNotice();
      await firstRepositories.aiJobRepository.schedule(
        type: AiJobType.recipeEnrichment,
        subjectId: '60000000-0000-4000-8000-000000000303',
        inputHash: 'hash-303',
        inputVersion: 'recipe-1',
      );
      await firstRepositories.syncRepository.processPendingAiJobs();
      await firstDatabase.close();

      final AppDatabase restartedDatabase =
          AppDatabase.forTesting(NativeDatabase(databaseFile));
      addTearDown(restartedDatabase.close);
      final AppRepositories restartedRepositories = AppRepositories(
        database: restartedDatabase,
        apiClient: api,
      );
      final AiJob rehydrated =
          (await restartedRepositories.aiJobRepository.listJobs()).single;

      expect(rehydrated.status, AiJobStatus.queued);
      await restartedRepositories.syncRepository.processPendingAiJobs();
      expect(api.scheduledIds, hasLength(1));
    });

    test('sync event maps retry state and attempt metadata into Drift',
        () async {
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: _AiSyncApiClient(),
      );

      await repositories.syncRepository.pullCaptureSync();
      final AiJob job = (await repositories.aiJobRepository.listJobs()).single;

      expect(job.status, AiJobStatus.retrying);
      expect(job.attemptCount, 2);
      expect(job.nextRetryAt, isNotNull);
      expect(job.errorMessage, 'provider_timeout');
    });

    test('explicit retry is durable and clears after backend acceptance',
        () async {
      final _RecordingAiApiClient api = _RecordingAiApiClient();
      final AppRepositories repositories = AppRepositories(
        database: database,
        apiClient: api,
      );
      final AiJob created = await repositories.aiJobRepository.schedule(
        type: AiJobType.existingDishMatch,
        subjectId: '60000000-0000-4000-8000-000000000305',
        inputHash: 'hash-305',
        inputVersion: '1',
      );
      await repositories.syncRepository.processPendingAiJobs();
      await (database.update(database.aiJobs)
            ..where((AiJobs table) => table.id.equals(created.id)))
          .write(
        const AiJobsCompanion(
          status: Value<String>('failed'),
          errorJson: Value<String?>('{"code":"invalid_output"}'),
        ),
      );

      await repositories.aiJobRepository.requestRetry(created.id);
      expect(
        (await repositories.aiJobRepository.listJobs()).single.status,
        AiJobStatus.pendingOffline,
      );

      await repositories.syncRepository.processPendingAiJobs();
      final AiJob retried =
          (await repositories.aiJobRepository.listJobs()).single;

      expect(retried.status, AiJobStatus.queued);
      expect(retried.pendingAction, isNull);
      expect(api.retriedIds, <String>[created.id]);
    });

    test('schema 3 database migrates with an empty AI jobs table', () async {
      final Directory temp =
          await Directory.systemTemp.createTemp('mymenu_ai_migration_');
      addTearDown(() => temp.delete(recursive: true));
      final File databaseFile = File('${temp.path}/mymenu.sqlite');
      sqlite.sqlite3.open(databaseFile.path)
        ..execute('''
          CREATE TABLE capture_items (
            id TEXT NOT NULL PRIMARY KEY,
            batch_id TEXT NULL,
            ordinal INTEGER NOT NULL DEFAULT 0,
            kind TEXT NOT NULL,
            status TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''')
        ..execute('PRAGMA user_version = 3')
        ..close();

      final AppDatabase migrated =
          AppDatabase.forTesting(NativeDatabase(databaseFile));
      addTearDown(migrated.close);

      expect(await migrated.select(migrated.aiJobs).get(), isEmpty);
      expect(migrated.schemaVersion, 17);
    });
  });
}

class _RecordingAiApiClient extends FakeMyMenuApiClient {
  final List<String> scheduledIds = <String>[];
  final List<String> retriedIds = <String>[];

  @override
  Future<ApiAiJob> scheduleAiJob({
    required String jobId,
    required String jobType,
    required String subjectId,
    required String idempotencyKey,
    required String inputHash,
    required String inputVersion,
    required String promptVersion,
    required String modelVersion,
    required String schemaVersion,
    required int maxAttempts,
  }) {
    scheduledIds.add(jobId);
    return super.scheduleAiJob(
      jobId: jobId,
      jobType: jobType,
      subjectId: subjectId,
      idempotencyKey: idempotencyKey,
      inputHash: inputHash,
      inputVersion: inputVersion,
      promptVersion: promptVersion,
      modelVersion: modelVersion,
      schemaVersion: schemaVersion,
      maxAttempts: maxAttempts,
    );
  }

  @override
  Future<ApiAiJob> retryAiJob({required String jobId}) {
    retriedIds.add(jobId);
    return super.retryAiJob(jobId: jobId);
  }
}

class _ReconnectAiApiClient extends FakeMyMenuApiClient {
  bool isOnline = false;
  int scheduleAttempts = 0;

  @override
  Future<ApiAiJob> scheduleAiJob({
    required String jobId,
    required String jobType,
    required String subjectId,
    required String idempotencyKey,
    required String inputHash,
    required String inputVersion,
    required String promptVersion,
    required String modelVersion,
    required String schemaVersion,
    required int maxAttempts,
  }) {
    scheduleAttempts += 1;
    if (!isOnline) {
      throw const SocketException('No network');
    }
    return super.scheduleAiJob(
      jobId: jobId,
      jobType: jobType,
      subjectId: subjectId,
      idempotencyKey: idempotencyKey,
      inputHash: inputHash,
      inputVersion: inputVersion,
      promptVersion: promptVersion,
      modelVersion: modelVersion,
      schemaVersion: schemaVersion,
      maxAttempts: maxAttempts,
    );
  }
}

class _AiSyncApiClient extends FakeMyMenuApiClient {
  @override
  Future<ApiSyncPull> pullSync({
    required int afterCursor,
    required int limit,
  }) async {
    return const ApiSyncPull(
      cursor: 51,
      hasMore: false,
      requiresBootstrap: false,
      events: <ApiSyncEvent>[
        ApiSyncEvent(
          cursor: 51,
          type: 'ai_job.retrying',
          entityIds: <String, String>{
            'aiJobId': '50000000-0000-4000-8000-000000000304',
          },
        ),
      ],
    );
  }

  @override
  Future<List<ApiAiJob>> getAiJobs(List<String> ids) async {
    return <ApiAiJob>[
      ApiAiJob(
        id: ids.single,
        jobType: 'recipe_enrichment',
        subjectId: '60000000-0000-4000-8000-000000000304',
        status: 'retrying',
        idempotencyKey: 'recipe:304:1',
        inputHash: 'hash-304',
        inputVersion: '1',
        attemptCount: 2,
        maxAttempts: 3,
        promptVersion: '1',
        modelVersion: 'adapter-default',
        schemaVersion: '1',
        nextRetryAt: DateTime.utc(2026, 7, 25, 12, 1),
        normalizedError: const <String, Object?>{
          'code': 'provider_timeout',
        },
        createdAt: DateTime.utc(2026, 7, 25, 12),
        updatedAt: DateTime.utc(2026, 7, 25, 12, 0, 30),
      ),
    ];
  }
}
