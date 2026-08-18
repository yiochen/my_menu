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

  test('allowance states distinguish enforcement from exhaustion and bypass',
      () {
    expect(
      ApiProcessingAllowanceStatus.fromApi('enforced'),
      ApiProcessingAllowanceStatus.enforced,
    );
    expect(
      ApiProcessingAllowanceStatus.fromApi('exhausted'),
      ApiProcessingAllowanceStatus.exhausted,
    );
    expect(
      ApiProcessingAllowanceStatus.fromApi('enforcement_disabled'),
      ApiProcessingAllowanceStatus.enforcementDisabled,
    );
    expect(
      const ApiProcessingAllowance(
        status: ApiProcessingAllowanceStatus.enforcementDisabled,
        used: 11,
        limit: 10,
        remaining: null,
      ).enforced,
      isFalse,
    );
  });
}
