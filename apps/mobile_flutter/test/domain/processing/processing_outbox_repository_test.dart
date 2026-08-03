import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/domain/ai/ai_job.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/capture/captured_media.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/processing/processing_privacy_notice.dart';
import 'package:mymenu/domain/sync/repositories.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('a capture and its processing request survive restart together',
      () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_processing_outbox_');
    addTearDown(() => temp.delete(recursive: true));
    final File databaseFile = File('${temp.path}/mymenu.sqlite');

    final AppDatabase firstDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    final AppRepositories firstRepositories = AppRepositories(
      database: firstDatabase,
      apiClient: FakeMyMenuApiClient(),
    );

    final batch = await firstRepositories.captureRepository.createPhotoBatch(
      <CapturedMedia>[
        CapturedMedia(
          path: '/tmp/capture.jpg',
          capturedAt: DateTime.utc(2026, 8, 1, 12),
          capturedLocalDate: '2026-08-01',
          dateSource: CaptureDateSource.exifOriginal,
        ),
      ],
    );
    expect(batch, isNotNull);
    await firstDatabase.close();

    final AppDatabase restartedDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    addTearDown(restartedDatabase.close);
    final AppRepositories restartedRepositories = AppRepositories(
      database: restartedDatabase,
      apiClient: FakeMyMenuApiClient(),
    );

    final captures =
        await restartedRepositories.captureRepository.listBatches();
    final requests =
        await restartedRepositories.processingOutboxRepository.listRequests();

    expect(captures.single.id, batch!.id);
    expect(requests.single.subjectId, batch.id);
    expect(
      requests.single.deliveryState,
      ProcessingDeliveryState.waitingForConsent,
    );
    expect(
      requests.single.adoptionState,
      ProcessingAdoptionState.awaitingProposal,
    );
  });

  test('capture processing resumes one server job after an interrupted upload',
      () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_processing_resume_');
    addTearDown(() => temp.delete(recursive: true));
    final File databaseFile = File('${temp.path}/mymenu.sqlite');
    final File photo = File('${temp.path}/capture.jpg')
      ..writeAsBytesSync(<int>[0xff, 0xd8, 0xff, 0xd9]);
    final FakeMyMenuApiClient server = FakeMyMenuApiClient()
      ..interruptNextProcessingUpload();

    final AppDatabase firstDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    final AppRepositories firstRepositories = AppRepositories(
      database: firstDatabase,
      apiClient: server,
    );
    await firstRepositories.processingConsentRepository.acceptCurrentNotice();
    await firstRepositories.captureRepository.createPhotoBatch(
      <CapturedMedia>[
        CapturedMedia(
          path: photo.path,
          capturedAt: DateTime.utc(2026, 8, 2, 12),
          capturedLocalDate: '2026-08-02',
          dateSource: CaptureDateSource.camera,
        ),
      ],
    );

    await firstRepositories.syncRepository.processPendingCaptures();
    final ProcessingOutboxRequest interrupted =
        (await firstRepositories.processingOutboxRepository.listRequests())
            .single;
    expect(interrupted.serverJobId, isNotNull);
    expect(interrupted.deliveryState, ProcessingDeliveryState.uploading);
    expect(server.processingJobCreationCount, 1);
    await firstDatabase.close();

    final AppDatabase restartedDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    addTearDown(restartedDatabase.close);
    final AppRepositories restartedRepositories = AppRepositories(
      database: restartedDatabase,
      apiClient: server,
    );

    await restartedRepositories.syncRepository.processPendingCaptures();

    final ProcessingOutboxRequest completed =
        (await restartedRepositories.processingOutboxRepository.listRequests())
            .single;
    expect(completed.idempotencyKey, interrupted.idempotencyKey);
    expect(completed.serverJobId, interrupted.serverJobId);
    expect(completed.deliveryState, ProcessingDeliveryState.acknowledged);
    expect(completed.adoptionState, ProcessingAdoptionState.readyForAdoption);
    expect(completed.resultPayload?['operation'], 'capture_grouping');
    expect(server.processingJobCreationCount, 1);
    expect(server.hasPayloadForProcessingJob(completed.serverJobId!), isFalse);
  });

  test('consent makes held work eligible and disabling holds new uploads',
      () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );

    await repositories.captureRepository.createIdeaCapture('ramen');
    ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(
      request.deliveryState,
      ProcessingDeliveryState.waitingForConsent,
    );
    expect(request.privacyNoticeVersion, isNull);

    await repositories.processingConsentRepository.acceptCurrentNotice();
    expect(
      await repositories.processingConsentRepository.currentDecision(),
      ProcessingConsentDecision.accepted,
    );
    request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(request.deliveryState, ProcessingDeliveryState.pendingUpload);
    expect(
      request.privacyNoticeVersion,
      ProcessingPrivacyNotice.currentVersion,
    );

    await repositories.processingConsentRepository.disableAiProcessing();
    expect(
      await repositories.processingConsentRepository.currentDecision(),
      ProcessingConsentDecision.declined,
    );
    request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(
      request.deliveryState,
      ProcessingDeliveryState.waitingForConsent,
    );
    expect(request.privacyNoticeVersion, isNull);

    await repositories.captureRepository.createIdeaCapture('udon');
    final requests =
        await repositories.processingOutboxRepository.listRequests();
    expect(requests, hasLength(2));
    expect(
      requests.map((item) => item.deliveryState),
      everyElement(ProcessingDeliveryState.waitingForConsent),
    );
  });

  test('debug reset clears consent and holds pending uploads', () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.captureRepository.createIdeaCapture('reset noodles');

    await repositories.processingConsentRepository.resetCurrentNotice();

    expect(
      await repositories.processingConsentRepository.currentDecision(),
      ProcessingConsentDecision.notDecided,
    );
    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(
      request.deliveryState,
      ProcessingDeliveryState.waitingForConsent,
    );
    expect(request.privacyNoticeVersion, isNull);
  });

  test('declined AI keeps every photo locally available and unorganized',
      () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.processingConsentRepository.declineCurrentNotice();

    final batch = await repositories.captureRepository.createPhotoBatch(
      <CapturedMedia>[
        CapturedMedia(
          path: '/tmp/no-ai-one.jpg',
          capturedAt: DateTime.utc(2026, 8, 1, 14),
          capturedLocalDate: '2026-08-01',
          dateSource: CaptureDateSource.camera,
        ),
        CapturedMedia(
          path: '/tmp/no-ai-two.jpg',
          capturedAt: DateTime.utc(2026, 8, 1, 15),
          capturedLocalDate: '2026-08-01',
          dateSource: CaptureDateSource.camera,
        ),
      ],
    );

    expect(batch, isNotNull);
    expect(batch!.status, CaptureBatchStatus.applied);
    expect(
      batch.items.map((CaptureItem item) => item.status),
      everyElement(CaptureItemStatus.localOnly),
    );
    final dishes = await repositories.dishRepository.listDishes();
    expect(dishes, isEmpty);
    expect(batch.items.map((CaptureItem item) => item.appliedDishId),
        everyElement(isNull));
    expect(
      await repositories.processingOutboxRepository.listRequests(),
      isEmpty,
    );
    expect(await database.select(database.aiJobs).get(), isEmpty);
    expect(await database.select(database.syncOperations).get(), isEmpty);
  });

  test('declining cancels held AI work without inventing a dish', () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.captureRepository.createPhotoBatch(
      <CapturedMedia>[
        CapturedMedia(
          path: '/tmp/already-waiting.jpg',
          capturedAt: DateTime.utc(2026, 8, 1, 16),
          capturedLocalDate: '2026-08-01',
          dateSource: CaptureDateSource.camera,
        ),
      ],
    );

    await repositories.processingConsentRepository.declineCurrentNotice();
    await repositories.captureRepository.adoptDeclinedPhotoCapturesLocally();

    final dishes = await repositories.dishRepository.listDishes();
    final repairedBatch =
        (await repositories.captureRepository.listBatches()).single;
    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(dishes, isEmpty);
    expect(repairedBatch.status, CaptureBatchStatus.applied);
    expect(repairedBatch.items.single.status, CaptureItemStatus.localOnly);
    expect(repairedBatch.items.single.appliedDishId, isNull);
    expect(request.deliveryState, ProcessingDeliveryState.canceled);
    expect(await database.select(database.aiJobs).get(), isEmpty);
    expect(await database.select(database.syncOperations).get(), isEmpty);
  });

  test('canceling pending processing keeps the local capture', () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );

    final String captureId =
        (await repositories.captureRepository.createIdeaCapture('soba'))!;
    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;

    expect(
      await repositories.processingOutboxRepository.cancelBeforeUpload(
        request.id,
      ),
      isTrue,
    );
    final ProcessingOutboxRequest canceled =
        (await repositories.processingOutboxRepository.listRequests()).single;
    final captures = await repositories.captureRepository.listFeedItems();

    expect(canceled.deliveryState, ProcessingDeliveryState.canceled);
    expect(captures.single.id, captureId);
  });

  test('delivery and proposal adoption advance independently', () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.captureRepository.createIdeaCapture('yakisoba');
    final String requestId =
        (await repositories.processingOutboxRepository.listRequests())
            .single
            .id;

    await repositories.processingOutboxRepository.claimForUpload(requestId);
    await repositories.processingOutboxRepository.markSubmitted(requestId);
    await repositories.processingOutboxRepository.markProposalReady(requestId);
    await repositories.processingOutboxRepository.markAdopted(requestId);

    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(request.deliveryState, ProcessingDeliveryState.submitted);
    expect(request.adoptionState, ProcessingAdoptionState.adopted);
  });

  test('an upload claim is rejected after pending work is canceled', () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.captureRepository.createIdeaCapture('cold soba');
    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;

    expect(
      await repositories.processingOutboxRepository.cancelBeforeUpload(
        request.id,
      ),
      isTrue,
    );
    expect(
      await repositories.processingOutboxRepository.claimForUpload(request.id),
      isFalse,
    );
  });

  test('retrying a failed capture makes its outbox request uploadable again',
      () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: FakeMyMenuApiClient(),
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    final String batchId =
        (await repositories.captureRepository.createIdeaCapture('zaru soba'))!;
    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    await repositories.processingOutboxRepository.claimForUpload(request.id);
    await repositories.processingOutboxRepository.markFailed(request.id);

    await repositories.captureRepository.retryBatch(batchId);

    final ProcessingOutboxRequest retried =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(retried.deliveryState, ProcessingDeliveryState.pendingUpload);
    expect(
      retried.privacyNoticeVersion,
      ProcessingPrivacyNotice.currentVersion,
    );
  });

  test('legacy applied batch adoption survives restart', () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_adoption_restart_');
    addTearDown(() => temp.delete(recursive: true));
    final File databaseFile = File('${temp.path}/mymenu.sqlite');
    final _AppliedBatchApiClient api = _AppliedBatchApiClient();
    final AppDatabase firstDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    final AppRepositories firstRepositories = AppRepositories(
      database: firstDatabase,
      apiClient: api,
    );
    await firstRepositories.processingConsentRepository.acceptCurrentNotice();
    api.batchId =
        await firstRepositories.captureRepository.createIdeaCapture('somen');

    await firstRepositories.syncRepository.pullCaptureSync();
    await firstDatabase.close();

    final AppDatabase restartedDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    addTearDown(restartedDatabase.close);
    final AppRepositories restartedRepositories = AppRepositories(
      database: restartedDatabase,
      apiClient: FakeMyMenuApiClient(),
    );
    final ProcessingOutboxRequest request =
        (await restartedRepositories.processingOutboxRepository.listRequests())
            .single;
    expect(request.adoptionState, ProcessingAdoptionState.adopted);
  });

  test('capture processing waits for current consent', () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_processing_consent_');
    addTearDown(() => temp.delete(recursive: true));
    final File photo = File('${temp.path}/consented-capture.jpg')
      ..writeAsBytesSync(<int>[0xff, 0xd8, 0xff, 0xd9]);
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final FakeMyMenuApiClient api = FakeMyMenuApiClient();
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: api,
    );
    await repositories.captureRepository.createPhotoBatch(
      <CapturedMedia>[
        CapturedMedia(
          path: photo.path,
          capturedAt: DateTime.utc(2026, 8, 1, 13),
          capturedLocalDate: '2026-08-01',
          dateSource: CaptureDateSource.exifOriginal,
        ),
      ],
    );

    await repositories.syncRepository.processPendingCaptures();
    expect(api.processingJobCreationCount, 0);

    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.syncRepository.processPendingCaptures();

    expect(api.processingJobCreationCount, 1);
    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(request.deliveryState, ProcessingDeliveryState.acknowledged);
    expect(
      request.privacyNoticeVersion,
      ProcessingPrivacyNotice.currentVersion,
    );
  });

  test('accepted consent survives restart', () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_consent_restart_');
    addTearDown(() => temp.delete(recursive: true));
    final File databaseFile = File('${temp.path}/mymenu.sqlite');

    final AppDatabase firstDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    final AppRepositories firstRepositories = AppRepositories(
      database: firstDatabase,
      apiClient: FakeMyMenuApiClient(),
    );
    await firstRepositories.processingConsentRepository.acceptCurrentNotice();
    await firstDatabase.close();

    final AppDatabase restartedDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    addTearDown(restartedDatabase.close);
    final AppRepositories restartedRepositories = AppRepositories(
      database: restartedDatabase,
      apiClient: FakeMyMenuApiClient(),
    );

    expect(
      await restartedRepositories.processingConsentRepository.currentDecision(),
      ProcessingConsentDecision.accepted,
    );
  });

  test('schema 8 capture work is expanded into a held outbox request',
      () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_outbox_migration_');
    addTearDown(() => temp.delete(recursive: true));
    final File databaseFile = File('${temp.path}/mymenu.sqlite');

    final AppDatabase currentDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    final AppRepositories currentRepositories = AppRepositories(
      database: currentDatabase,
      apiClient: FakeMyMenuApiClient(),
    );
    final String captureId =
        (await currentRepositories.captureRepository.createIdeaCapture(
      'legacy idea',
    ))!;
    final DateTime now = DateTime.utc(2026, 8);
    await currentDatabase.into(currentDatabase.aiJobs).insert(
          AiJobsCompanion.insert(
            id: '50000000-0000-4000-8000-000000000055',
            jobType: AiJobType.batchGrouping.apiValue,
            subjectId: captureId,
            status: AiJobStatus.pendingOffline.databaseValue,
            idempotencyKey: 'legacy-capture-grouping-$captureId',
            inputHash: 'legacy-input',
            inputVersion: 'batch-grouping-v2',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await currentDatabase.close();

    sqlite.sqlite3.open(databaseFile.path)
      ..execute('DROP TABLE processing_outbox')
      ..execute('DROP TABLE processing_consents')
      ..execute('PRAGMA user_version = 8')
      ..close();

    final AppDatabase migratedDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    addTearDown(migratedDatabase.close);
    final AppRepositories migratedRepositories = AppRepositories(
      database: migratedDatabase,
      apiClient: FakeMyMenuApiClient(),
    );

    final ProcessingOutboxRequest request =
        (await migratedRepositories.processingOutboxRepository.listRequests())
            .single;
    expect(request.subjectId, captureId);
    expect(
      request.deliveryState,
      ProcessingDeliveryState.waitingForConsent,
    );
  });

  test('other AI submissions also wait for current consent', () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final _RecordingAiApiClient api = _RecordingAiApiClient();
    final AppRepositories repositories = AppRepositories(
      database: database,
      apiClient: api,
    );
    await repositories.aiJobRepository.schedule(
      type: AiJobType.coverGeneration,
      subjectId: 'dish-local-cover',
      inputHash: 'cover-input',
      inputVersion: '1',
    );

    await repositories.syncRepository.processPendingAiJobs();
    expect(api.scheduledJobIds, isEmpty);

    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.syncRepository.processPendingAiJobs();
    expect(api.scheduledJobIds, hasLength(1));
  });
}

class _RecordingAiApiClient extends FakeMyMenuApiClient {
  final List<String> scheduledJobIds = <String>[];

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
    scheduledJobIds.add(jobId);
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

class _AppliedBatchApiClient extends FakeMyMenuApiClient {
  String? batchId;

  @override
  Future<ApiSyncPull> pullSync({
    required int afterCursor,
    required int limit,
  }) async {
    final String? id = batchId;
    if (id == null || afterCursor >= 1) {
      return const ApiSyncPull(
        cursor: 1,
        hasMore: false,
        requiresBootstrap: false,
        events: <ApiSyncEvent>[],
      );
    }
    return ApiSyncPull(
      cursor: 1,
      hasMore: false,
      requiresBootstrap: false,
      events: <ApiSyncEvent>[
        ApiSyncEvent(
          cursor: 1,
          type: 'capture_batch.applied',
          entityIds: <String, String>{'batchId': id},
        ),
      ],
    );
  }

  @override
  Future<List<ApiCaptureBatch>> getCaptureBatches(List<String> ids) async {
    final String? id = batchId;
    return <ApiCaptureBatch>[
      if (id != null && ids.contains(id))
        ApiCaptureBatch(
          id: id,
          status: 'applied',
          itemCount: 1,
          uploadedItemCount: 1,
        ),
    ];
  }
}
