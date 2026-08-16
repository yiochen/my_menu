import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/processing_api_client.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/capture/captured_media.dart';
import 'package:mymenu/domain/menu/app_repositories.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/processing/processing_privacy_notice.dart';

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
      processingApiClient: FakeProcessingApiClient(),
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
      processingApiClient: FakeProcessingApiClient(),
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
    final FakeProcessingApiClient server = FakeProcessingApiClient()
      ..interruptNextProcessingUpload();

    final AppDatabase firstDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    final AppRepositories firstRepositories = AppRepositories(
      database: firstDatabase,
      processingApiClient: server,
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

    await firstRepositories.processingCoordinator.processPendingCaptures();
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
      processingApiClient: server,
    );

    await restartedRepositories.processingCoordinator.processPendingCaptures();

    final ProcessingOutboxRequest completed =
        (await restartedRepositories.processingOutboxRepository.listRequests())
            .singleWhere(
      (ProcessingOutboxRequest request) =>
          request.kind == ProcessingRequestKind.captureGrouping,
    );
    expect(completed.idempotencyKey, interrupted.idempotencyKey);
    expect(completed.serverJobId, interrupted.serverJobId);
    expect(completed.deliveryState, ProcessingDeliveryState.acknowledged);
    expect(completed.adoptionState, ProcessingAdoptionState.adopted);
    expect(completed.resultPayload?['operation'], 'capture_grouping');
    expect(server.processingJobCreationCount, 1);
    expect(server.hasPayloadForProcessingJob(completed.serverJobId!), isFalse);
  });

  test('capture adoption resumes after the server acknowledgement commits',
      () async {
    final Directory temp = await Directory.systemTemp.createTemp(
      'mymenu_processing_ack_resume_',
    );
    addTearDown(() => temp.delete(recursive: true));
    final File photo = File('${temp.path}/capture.jpg')
      ..writeAsBytesSync(<int>[0xff, 0xd8, 0xff, 0xd9]);
    final FakeProcessingApiClient server = FakeProcessingApiClient()
      ..interruptNextAcknowledgementAfterCommit();
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      processingApiClient: server,
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.captureRepository.createPhotoBatch(
      <CapturedMedia>[
        CapturedMedia(
          path: photo.path,
          capturedAt: DateTime.utc(2026, 8, 2, 12),
          capturedLocalDate: '2026-08-02',
          dateSource: CaptureDateSource.camera,
        ),
      ],
    );

    await repositories.processingCoordinator.processPendingCaptures();
    ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(request.deliveryState, ProcessingDeliveryState.submitted);
    expect(
      request.adoptionState,
      ProcessingAdoptionState.readyForAdoption,
    );

    await repositories.processingCoordinator.processPendingCaptures();

    request = (await repositories.processingOutboxRepository.listRequests())
        .singleWhere(
      (ProcessingOutboxRequest item) =>
          item.kind == ProcessingRequestKind.captureGrouping,
    );
    expect(request.deliveryState, ProcessingDeliveryState.acknowledged);
    expect(request.adoptionState, ProcessingAdoptionState.adopted);
    expect(await repositories.dishRepository.listDishes(), hasLength(1));
  });

  test('consent makes held work eligible and disabling holds new uploads',
      () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      processingApiClient: FakeProcessingApiClient(),
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
      processingApiClient: FakeProcessingApiClient(),
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.captureRepository.createIdeaCapture('reset noodles');

    await repositories.processingConsentRepository.resetCurrentNotice();

    expect(
      await repositories.processingConsentRepository.currentDecision(),
      ProcessingConsentDecision.notDecided,
    );
    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests())
            .singleWhere(
      (ProcessingOutboxRequest request) =>
          request.kind == ProcessingRequestKind.captureGrouping,
    );
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
      processingApiClient: FakeProcessingApiClient(),
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
  });

  test('declining cancels held AI work without inventing a dish', () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      processingApiClient: FakeProcessingApiClient(),
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
  });

  test('canceling pending processing keeps the local capture', () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      processingApiClient: FakeProcessingApiClient(),
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
      processingApiClient: FakeProcessingApiClient(),
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
      processingApiClient: FakeProcessingApiClient(),
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
      processingApiClient: FakeProcessingApiClient(),
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

  test('capture processing waits for current consent', () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_processing_consent_');
    addTearDown(() => temp.delete(recursive: true));
    final File photo = File('${temp.path}/consented-capture.jpg')
      ..writeAsBytesSync(<int>[0xff, 0xd8, 0xff, 0xd9]);
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final FakeProcessingApiClient api = FakeProcessingApiClient();
    final AppRepositories repositories = AppRepositories(
      database: database,
      processingApiClient: api,
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

    await repositories.processingCoordinator.processPendingCaptures();
    expect(api.processingJobCreationCount, 0);

    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.processingCoordinator.processPendingCaptures();

    expect(api.processingJobCreationCount, 1);
    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests())
            .singleWhere(
      (ProcessingOutboxRequest request) =>
          request.kind == ProcessingRequestKind.captureGrouping,
    );
    expect(request.deliveryState, ProcessingDeliveryState.acknowledged);
    expect(
      request.privacyNoticeVersion,
      ProcessingPrivacyNotice.currentVersion,
    );
  });

  test('quota exhaustion leaves captures local and unorganized', () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_processing_quota_');
    addTearDown(() => temp.delete(recursive: true));
    final File photo = File('${temp.path}/quota-capture.jpg')
      ..writeAsBytesSync(<int>[0xff, 0xd8, 0xff, 0xd9]);
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final AppRepositories repositories = AppRepositories(
      database: database,
      processingApiClient: _QuotaExhaustedProcessingApi(),
    );
    await repositories.processingConsentRepository.acceptCurrentNotice();
    await repositories.captureRepository.createPhotoBatch(
      <CapturedMedia>[
        CapturedMedia(
          path: photo.path,
          capturedAt: DateTime.utc(2026, 8, 11, 12),
          capturedLocalDate: '2026-08-11',
          dateSource: CaptureDateSource.camera,
        ),
      ],
    );

    await repositories.processingCoordinator.processPendingCaptures();

    final CaptureBatch batch =
        (await repositories.captureRepository.listBatches()).single;
    final ProcessingOutboxRequest request =
        (await repositories.processingOutboxRepository.listRequests()).single;
    expect(batch.status, CaptureBatchStatus.local);
    expect(batch.items.single.status, CaptureItemStatus.localOnly);
    expect(batch.failureReason, isNull);
    expect(batch.items.single.failureReason, isNull);
    expect(request.deliveryState, ProcessingDeliveryState.failed);
    expect(request.failureCode, 'free_allowance_exhausted');

    await (database.update(database.captureItems)
          ..where((row) => row.batchId.equals(batch.id)))
        .write(
      const CaptureItemsCompanion(
        status: Value<String>('failed'),
        failureReason: Value<String?>('The free processing allowance is used.'),
      ),
    );
    await (database.update(database.captureBatches)
          ..where((row) => row.id.equals(batch.id)))
        .write(
      const CaptureBatchesCompanion(
        status: Value<String>('failed'),
        failureReason: Value<String?>('The free processing allowance is used.'),
      ),
    );

    await repositories.prepareLocalData();

    final CaptureBatch repaired =
        (await repositories.captureRepository.listBatches()).single;
    expect(repaired.status, CaptureBatchStatus.local);
    expect(repaired.items.single.status, CaptureItemStatus.localOnly);
    expect(repaired.failureReason, isNull);
    expect(repaired.items.single.failureReason, isNull);
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
      processingApiClient: FakeProcessingApiClient(),
    );
    await firstRepositories.processingConsentRepository.acceptCurrentNotice();
    await firstDatabase.close();

    final AppDatabase restartedDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    addTearDown(restartedDatabase.close);
    final AppRepositories restartedRepositories = AppRepositories(
      database: restartedDatabase,
      processingApiClient: FakeProcessingApiClient(),
    );

    expect(
      await restartedRepositories.processingConsentRepository.currentDecision(),
      ProcessingConsentDecision.accepted,
    );
  });
}

class _QuotaExhaustedProcessingApi extends ProcessingApiClient {
  @override
  Future<ApiProcessingJob> createProcessingJob({
    required ApiProcessingContract contract,
    required String idempotencyKey,
    required String privacyNoticeVersion,
    required List<ApiProcessingAssetManifest> assets,
  }) {
    throw StateError('free_allowance_exhausted');
  }
}
