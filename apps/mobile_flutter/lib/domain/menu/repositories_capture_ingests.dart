part of 'app_repositories.dart';

extension CaptureRepositoryIngests on CaptureRepository {
  Future<List<CaptureIngest>> listIngests() async {
    final List<db.CaptureItemRow> itemRows =
        await (_database.select(_database.captureItems)
              ..orderBy(<OrderingTerm Function(db.$CaptureItemsTable)>[
                (db.$CaptureItemsTable table) =>
                    OrderingTerm.asc(table.ordinal),
              ]))
            .get();
    final List<ProcessingOutboxRequest> requests =
        await _processingOutboxRepository.listRequests();
    final Map<String, ProcessingOutboxRequest> requestsByIngest =
        <String, ProcessingOutboxRequest>{
      for (final ProcessingOutboxRequest request in requests)
        if (request.kind == ProcessingRequestKind.captureGrouping)
          request.subjectId: request,
    };
    final Map<String, List<capture_domain.CaptureItem>> itemsByIngest =
        <String, List<capture_domain.CaptureItem>>{};
    for (final db.CaptureItemRow row in itemRows) {
      final String ingestId = row.ingestId ?? row.id;
      itemsByIngest
          .putIfAbsent(ingestId, () => <capture_domain.CaptureItem>[])
          .add(row.toDomain());
    }
    final List<CaptureIngest> ingests = itemsByIngest.entries
        .map((MapEntry<String, List<capture_domain.CaptureItem>> entry) {
      final ProcessingOutboxRequest? request = requestsByIngest[entry.key];
      final DateTime createdAt = entry.value
          .map((capture_domain.CaptureItem item) => item.createdAt)
          .reduce((DateTime a, DateTime b) => a.isBefore(b) ? a : b);
      return CaptureIngest(
        id: entry.key,
        status: _deriveIngestStatus(entry.value, request),
        createdAt: createdAt,
        updatedAt: request?.updatedAt ?? createdAt,
        items: List<capture_domain.CaptureItem>.unmodifiable(entry.value),
        failureReason: entry.value
            .map((capture_domain.CaptureItem item) => item.failureReason)
            .whereType<String>()
            .firstOrNull,
      );
    }).toList(growable: false)
      ..sort((CaptureIngest a, CaptureIngest b) =>
          b.createdAt.compareTo(a.createdAt));
    return ingests;
  }

  CaptureIngestStatus _deriveIngestStatus(
    List<capture_domain.CaptureItem> items,
    ProcessingOutboxRequest? request,
  ) {
    final Set<capture_domain.CaptureItemStatus> statuses =
        items.map((capture_domain.CaptureItem item) => item.status).toSet();
    if (statuses.every(
      (capture_domain.CaptureItemStatus status) =>
          status == capture_domain.CaptureItemStatus.discarded,
    )) {
      return CaptureIngestStatus.discarded;
    }
    if (statuses.every(
      (capture_domain.CaptureItemStatus status) =>
          status == capture_domain.CaptureItemStatus.localOnly ||
          status == capture_domain.CaptureItemStatus.discarded,
    )) {
      return CaptureIngestStatus.local;
    }
    if (statuses.contains(capture_domain.CaptureItemStatus.failed) ||
        request?.deliveryState == ProcessingDeliveryState.failed ||
        request?.deliveryState == ProcessingDeliveryState.expired) {
      return CaptureIngestStatus.failed;
    }
    if (request?.adoptionState == ProcessingAdoptionState.adopted ||
        statuses.every(
          (capture_domain.CaptureItemStatus status) =>
              status == capture_domain.CaptureItemStatus.applied ||
              status == capture_domain.CaptureItemStatus.notADish ||
              status == capture_domain.CaptureItemStatus.needsReview ||
              status == capture_domain.CaptureItemStatus.discarded,
        )) {
      return CaptureIngestStatus.applied;
    }
    if (statuses.contains(capture_domain.CaptureItemStatus.classifying) ||
        request?.deliveryState == ProcessingDeliveryState.submitted ||
        request?.deliveryState == ProcessingDeliveryState.downloading ||
        request?.deliveryState == ProcessingDeliveryState.acknowledged) {
      return CaptureIngestStatus.processing;
    }
    if (statuses.contains(capture_domain.CaptureItemStatus.uploading) ||
        request?.deliveryState == ProcessingDeliveryState.uploading) {
      return CaptureIngestStatus.uploading;
    }
    if (statuses.every(
      (capture_domain.CaptureItemStatus status) =>
          status == capture_domain.CaptureItemStatus.uploaded ||
          status == capture_domain.CaptureItemStatus.discarded,
    )) {
      return CaptureIngestStatus.readyForAi;
    }
    return CaptureIngestStatus.pendingUpload;
  }
}
