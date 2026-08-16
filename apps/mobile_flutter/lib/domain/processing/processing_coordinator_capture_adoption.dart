part of 'processing_coordinator.dart';

extension ProcessingCoordinatorCaptureRoutingAdoption on ProcessingCoordinator {
  Future<void> _adoptCaptureRoutingProposal(
    ProcessingOutboxRequest request,
  ) async {
    try {
      final Map<String, Object?>? result = request.resultPayload;
      if (request.deliveryState != ProcessingDeliveryState.acknowledged ||
          request.adoptionState != ProcessingAdoptionState.readyForAdoption ||
          request.resultSchemaVersion !=
              ApiProcessingContract.captureGroupingV2.resultSchemaVersion ||
          result == null) {
        return;
      }
      _validateCaptureGroupingResult(
        request,
        result,
        schemaVersion: request.resultSchemaVersion!,
      );
      await _captureProposalAdopter(request);
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
}
