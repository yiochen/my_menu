import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/network/processing_api_client.dart';

void main() {
  test('server queue states map to client processing states', () {
    expect(
      ApiProcessingJobStatus.fromApi('queued'),
      ApiProcessingJobStatus.submitted,
    );
    expect(
      ApiProcessingJobStatus.fromApi('running'),
      ApiProcessingJobStatus.processing,
    );
  });

  test('shared server and client states map directly', () {
    for (final ApiProcessingJobStatus status in <ApiProcessingJobStatus>[
      ApiProcessingJobStatus.created,
      ApiProcessingJobStatus.succeeded,
      ApiProcessingJobStatus.acknowledged,
      ApiProcessingJobStatus.failed,
      ApiProcessingJobStatus.expired,
      ApiProcessingJobStatus.canceled,
    ]) {
      expect(ApiProcessingJobStatus.fromApi(status.name), status);
    }
  });
}
