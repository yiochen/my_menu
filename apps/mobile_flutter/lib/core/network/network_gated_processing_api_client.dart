import 'package:mymenu/core/network/processing_api_client.dart';

class NetworkGatedProcessingApiClient extends ProcessingApiClient {
  NetworkGatedProcessingApiClient(this._delegate, this._requireNetwork);

  final ProcessingApiClient _delegate;
  final void Function() _requireNetwork;

  Future<T> _online<T>(Future<T> Function() request) async {
    _requireNetwork();
    return request();
  }

  @override
  Future<ApiProcessingAllowances> getProcessingAllowances() =>
      _online(_delegate.getProcessingAllowances);

  @override
  Future<ApiProcessingJob> createProcessingJob({
    required ApiProcessingContract contract,
    required String idempotencyKey,
    required String privacyNoticeVersion,
    required List<ApiProcessingAssetManifest> assets,
  }) {
    return _online(
      () => _delegate.createProcessingJob(
        contract: contract,
        idempotencyKey: idempotencyKey,
        privacyNoticeVersion: privacyNoticeVersion,
        assets: assets,
      ),
    );
  }

  @override
  Future<void> uploadProcessingAsset({
    required ApiProcessingUploadTarget target,
    required String localPath,
  }) {
    return _online(
      () => _delegate.uploadProcessingAsset(
        target: target,
        localPath: localPath,
      ),
    );
  }

  @override
  Future<ApiProcessingJob> submitProcessingJob({
    required String jobId,
    required ApiProcessingInput input,
  }) =>
      _online(() => _delegate.submitProcessingJob(jobId: jobId, input: input));

  @override
  Future<ApiProcessingJob> getProcessingJob({required String jobId}) =>
      _online(() => _delegate.getProcessingJob(jobId: jobId));

  @override
  Future<ApiProcessingResult> downloadProcessingResult({
    required String jobId,
  }) =>
      _online(() => _delegate.downloadProcessingResult(jobId: jobId));

  @override
  Future<void> acknowledgeProcessingJob({required String jobId}) =>
      _online(() => _delegate.acknowledgeProcessingJob(jobId: jobId));

  @override
  Future<void> cancelProcessingJob({required String jobId}) =>
      _online(() => _delegate.cancelProcessingJob(jobId: jobId));
}
