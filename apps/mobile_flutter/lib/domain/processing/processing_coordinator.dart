import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/core/files/image_derivative_store.dart';
import 'package:mymenu/core/network/processing_api_client.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_item.dart' as capture_domain;
import 'package:mymenu/domain/covers/cover_repository.dart';
import 'package:mymenu/domain/covers/generated_cover.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/processing/processing_consent_repository.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/processing/processing_outbox_repository.dart';
import 'package:mymenu/domain/processing/processing_privacy_notice.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'processing_coordinator_assets.dart';
part 'processing_coordinator_capture_adoption.dart';
part 'processing_coordinator_capture_contract.dart';
part 'processing_coordinator_captures.dart';
part 'processing_coordinator_cover_delivery.dart';
part 'processing_coordinator_covers.dart';
part 'processing_coordinator_support.dart';

class ProcessingCoordinator {
  ProcessingCoordinator(
    this._database,
    this._processingApi, {
    required Duration controlRequestTimeout,
    required ImageDerivativeStore imageDerivativeStore,
    required CaptureProposalAdopter captureProposalAdopter,
    required CaptureProcessingLocalStore captureProcessingLocalStore,
  })  : _controlRequestTimeout = controlRequestTimeout,
        _imageDerivativeStore = imageDerivativeStore,
        _captureProposalAdopter = captureProposalAdopter,
        _captureProcessingLocalStore = captureProcessingLocalStore;

  final db.AppDatabase _database;
  final ProcessingApiClient _processingApi;
  final Duration _controlRequestTimeout;
  final ImageDerivativeStore _imageDerivativeStore;
  final CaptureProposalAdopter _captureProposalAdopter;
  final CaptureProcessingLocalStore _captureProcessingLocalStore;
}

typedef CaptureProposalAdopter = Future<void> Function(
  ProcessingOutboxRequest request,
);

abstract interface class CaptureProcessingLocalStore {
  Future<List<db.CaptureItemRow>> activeItemsForBatch(String batchId);

  Future<void> updatePreviewRefs(
    String captureId,
    ImageDerivativeSet previews,
  );

  Future<void> markCaptureStatus(
    String captureId,
    capture_domain.CaptureItemStatus status,
  );

  Future<void> markCapturesClassifying(String batchId);

  Future<void> markCapturesPending(String batchId);

  Future<void> markBatchUnorganized(String batchId);

  Future<void> markCapturesFailed(String batchId, String reason);

  Future<void> markBatchStatus(
    String batchId,
    CaptureBatchStatus status, {
    String? failureReason,
  });
}
