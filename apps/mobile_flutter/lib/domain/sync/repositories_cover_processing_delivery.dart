part of 'repositories.dart';

extension SyncRepositoryCoverDelivery on SyncRepository {
  Future<String> _materializeGeneratedCover(
    ProcessingOutboxRequest request,
    Map<String, Object?> result,
  ) async {
    final Map<String, Object?> output =
        result['output']! as Map<String, Object?>;
    final String contentType = output['contentType'] as String? ?? '';
    final Uint8List bytes;
    if (output['imageBase64'] case final String encoded) {
      bytes = base64Decode(encoded);
    } else if (output['downloadUrl'] case final String downloadUrl) {
      final HttpClient client = HttpClient();
      try {
        final HttpClientResponse response =
            await (await client.getUrl(Uri.parse(downloadUrl))).close();
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw HttpException('Generated Cover download failed.',
              uri: Uri.parse(downloadUrl));
        }
        final BytesBuilder builder = BytesBuilder(copy: false);
        await for (final List<int> chunk in response) {
          builder.add(chunk);
        }
        bytes = builder.takeBytes();
      } finally {
        client.close(force: true);
      }
    } else {
      throw const FormatException('Generated Cover bytes are missing.');
    }
    final bool png = contentType == 'image/png' &&
        bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47;
    final bool jpeg = contentType == 'image/jpeg' &&
        bytes.length >= 4 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[bytes.length - 2] == 0xff &&
        bytes[bytes.length - 1] == 0xd9;
    if (!png && !jpeg) {
      throw const FormatException('Generated Cover file is invalid.');
    }
    final Directory directory = await _generatedCoverDirectory(
      request.subjectId,
    );
    await directory.create(recursive: true);
    final File staged = File(
      '${directory.path}/${request.id}.${png ? 'png' : 'jpg'}.staging',
    );
    await staged.writeAsBytes(bytes, flush: true);
    final File committed = File(staged.path.replaceFirst('.staging', ''));
    return (await staged.rename(committed.path)).path;
  }

  Future<Directory> _generatedCoverDirectory(String dishId) async {
    try {
      final Directory support = await getApplicationSupportDirectory();
      return Directory('${support.path}/generated-covers/$dishId');
    } on Object {
      if (Platform.environment['FLUTTER_TEST'] != 'true') rethrow;
      return Directory('${Directory.systemTemp.path}/mymenu-covers/$dishId');
    }
  }

  Future<void> _storeDeliveredCover(
    ProcessingOutboxRequest request,
    Map<String, Object?> result,
    String localPath,
  ) async {
    final Map<String, Object?> treatment =
        request.payload['treatment']! as Map<String, Object?>;
    final List<String> sourceIds = _payloadStringList(
      request.payload,
      'sourceIds',
    );
    await CoverRepository(_database).storeDeliveredCover(
      id: request.id,
      dishId: request.subjectId,
      localPath: localPath,
      origin: CoverOrigin.values.byName(request.payload['origin']! as String),
      grounding:
          sourceIds.isEmpty ? CoverGrounding.context : CoverGrounding.source,
      selectedSourceIds: sourceIds,
      treatment: CoverTreatment(
        look: CoverLook.values.firstWhere(
          (CoverLook value) => value.apiValue == treatment['look'],
        ),
        view: CoverView.values.firstWhere(
          (CoverView value) => value.apiValue == treatment['view'],
        ),
        finish: CoverFinish.values.firstWhere(
          (CoverFinish value) => value.apiValue == treatment['finish'],
        ),
      ),
      proposalId: result['proposalId']! as String,
      createdAt: DateTime.now(),
    );
  }

  Future<void> _cancelCoverJob(
    ProcessingOutboxRepository outbox,
    ProcessingOutboxRequest request,
  ) async {
    if (request.serverJobId != null) {
      try {
        await _apiClient.cancelProcessingJob(jobId: request.serverJobId!);
      } on Object catch (error) {
        if (!_isProcessingJobNotFound(error) && _isConnectivityError(error)) {
          return;
        }
      }
      await outbox.clearServerJob(request.id);
    }
    await _deleteProcessingAssets(request.id);
    if (request.payload['restartAfterCancel'] == true) {
      final Map<String, Object?> payload = Map<String, Object?>.from(
        request.payload,
      )..remove('restartAfterCancel');
      await outbox.restartCanceledCover(request.id, payload);
    }
  }
}
