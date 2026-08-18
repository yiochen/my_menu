part of 'my_menu_state.dart';

extension MyMenuStateCovers on MyMenuState {
  List<GeneratedCover> get generatedCovers =>
      List<GeneratedCover>.unmodifiable(_generatedCovers);

  List<GeneratedCover> coverHistoryForDish(String dishId) => _generatedCovers
      .where((GeneratedCover cover) => cover.dishId == dishId)
      .toList(growable: false);

  bool isCoverGenerationActiveForDish(String dishId) {
    return _processingRequests.any(
      (ProcessingOutboxRequest request) =>
          request.kind == ProcessingRequestKind.coverGeneration &&
          request.subjectId == dishId &&
          <ProcessingDeliveryState>{
            ProcessingDeliveryState.pendingUpload,
            ProcessingDeliveryState.uploading,
            ProcessingDeliveryState.submitted,
            ProcessingDeliveryState.downloading,
          }.contains(request.deliveryState),
    );
  }

  GeneratedCover? proposedCoverForDish(String dishId) {
    for (final GeneratedCover cover in coverHistoryForDish(dishId)) {
      if (cover.state == GeneratedCoverState.proposed) {
        return cover;
      }
    }
    return null;
  }

  GeneratedCover? unacknowledgedAutomaticCoverForDish(String dishId) {
    for (final GeneratedCover cover in coverHistoryForDish(dishId)) {
      if (cover.origin == CoverOrigin.automatic &&
          cover.state == GeneratedCoverState.current &&
          !cover.automaticAcknowledged) {
        return cover;
      }
    }
    return null;
  }

  Future<CoverTreatment?> lastManualCoverTreatment() async {
    await _repositoryBootstrap;
    return _repositories?.coverRepository.lastManualTreatment();
  }

  Future<bool> enqueueAutomaticCoverForDish(String dishId) async {
    await _repositoryBootstrap;
    final AppRepositories? repositories = _repositories;
    if (repositories == null ||
        _processingConsentDecision != ProcessingConsentDecision.accepted) {
      return false;
    }
    final Dish dish = dishById(dishId);
    final bool enqueued =
        await repositories.coverRepository.enqueueAutomaticCover(
      dishId: dishId,
      sourceIds: dish.sourcePhotos
          .map((SourcePhoto source) => source.id)
          .whereType<String>()
          .take(3)
          .toList(growable: false),
      now: DateTime.now(),
    );
    if (enqueued) {
      await _reloadFromRepositories();
      _startProcessingResumeWindow();
    }
    return enqueued;
  }

  Future<bool> startManualCoverGeneration({
    required String dishId,
    required List<String> selectedSourceIds,
    required CoverTreatment treatment,
  }) async {
    await _repositoryBootstrap;
    final AppRepositories? repositories = _repositories;
    if (repositories == null ||
        _processingConsentDecision != ProcessingConsentDecision.accepted) {
      return false;
    }
    final Dish dish = dishById(dishId);
    final Set<String> availableSourceIds = dish.sourcePhotos
        .map((SourcePhoto source) => source.id)
        .whereType<String>()
        .toSet();
    final List<String> normalizedSourceIds = selectedSourceIds
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (dish.sourcePhotos.isEmpty) {
      if (normalizedSourceIds.isNotEmpty) {
        throw ArgumentError.value(
          selectedSourceIds,
          'selectedSourceIds',
          'A context-grounded Cover cannot include Sources.',
        );
      }
    } else if (normalizedSourceIds.isEmpty ||
        normalizedSourceIds.length > 3 ||
        !availableSourceIds.containsAll(normalizedSourceIds)) {
      throw ArgumentError.value(
        selectedSourceIds,
        'selectedSourceIds',
        'Choose one to three Sources belonging to the Dish.',
      );
    }

    final db.ProcessingOutboxRow? existing = await (repositories.database
            .select(repositories.database.processingOutbox)
          ..where(
            (db.ProcessingOutbox table) =>
                table.requestKind.equals(
                  ProcessingRequestKind.coverGeneration.databaseValue,
                ) &
                table.subjectId.equals(dishId),
          ))
        .getSingleOrNull();
    final Map<String, Object?> payload = _coverPayload(
      dish,
      sourceIds: normalizedSourceIds,
      treatment: treatment,
      origin: CoverOrigin.manual,
    );
    if (existing != null) {
      final ProcessingDeliveryState state =
          ProcessingDeliveryState.values.byName(existing.deliveryState);
      if (!<ProcessingDeliveryState>{
        ProcessingDeliveryState.acknowledged,
        ProcessingDeliveryState.failed,
        ProcessingDeliveryState.expired,
        ProcessingDeliveryState.canceled,
      }.contains(state)) {
        final Object? decoded = jsonDecode(existing.payloadJson);
        if (decoded is! Map<String, dynamic> ||
            decoded['origin'] != CoverOrigin.automatic.name) {
          return false;
        }
        await (repositories.database.update(
          repositories.database.processingOutbox,
        )..where(
                (db.ProcessingOutbox table) => table.id.equals(existing.id),
              ))
            .write(
          db.ProcessingOutboxCompanion(
            payloadJson: Value<String>(
              jsonEncode(<String, Object?>{
                ...payload,
                'restartAfterCancel': true,
              }),
            ),
            deliveryState: Value<String>(ProcessingDeliveryState.canceled.name),
            updatedAt: Value<DateTime>(DateTime.now()),
          ),
        );
        await _reloadFromRepositories();
        await repositories.coverRepository.rememberManualTreatment(treatment);
        _startProcessingResumeWindow();
        return true;
      }
      await (repositories.database
              .delete(repositories.database.processingOutbox)
            ..where(
                (db.ProcessingOutbox table) => table.id.equals(existing.id)))
          .go();
    }

    final bool enqueued =
        await repositories.processingOutboxRepository.enqueueCoverGeneration(
      requestId: const Uuid().v4(),
      dishId: dishId,
      payload: payload,
      now: DateTime.now(),
    );
    if (enqueued) {
      await repositories.coverRepository.rememberManualTreatment(treatment);
      await _reloadFromRepositories();
      _startProcessingResumeWindow();
    }
    return enqueued;
  }

  Future<void> acceptCoverProposal(String coverId) async {
    await _repositories?.coverRepository.acceptProposal(coverId);
    if (_repositories != null) await _reloadFromRepositories();
  }

  Future<void> keepCurrentCover(String coverId) async {
    await _repositories?.coverRepository.keepCurrent(coverId);
    if (_repositories != null) await _reloadFromRepositories();
  }

  Future<void> selectGeneratedCover(String coverId) async {
    await _repositories?.coverRepository.selectGenerated(coverId);
    if (_repositories != null) await _reloadFromRepositories();
  }

  Future<void> selectSourceAsCover(String dishId, String sourceId) async {
    await _repositories?.coverRepository.selectSource(dishId, sourceId);
    if (_repositories != null) await _reloadFromRepositories();
  }

  Future<void> undoAutomaticCover(String coverId) async {
    await _repositories?.coverRepository.undoAutomatic(coverId);
    if (_repositories != null) await _reloadFromRepositories();
  }

  Future<void> acknowledgeAutomaticCover(String coverId) async {
    await _repositories?.coverRepository.acknowledgeAutomatic(coverId);
    if (_repositories != null) await _reloadFromRepositories();
  }

  Future<void> deleteGeneratedCover(String coverId) async {
    await _repositories?.coverRepository.deleteGenerated(coverId);
    if (_repositories != null) await _reloadFromRepositories();
  }

  Future<bool> automaticCoverGenerationEnabled() async =>
      await _repositories?.coverRepository.automaticGenerationEnabled() ?? true;

  Future<ApiProcessingAllowance?> coverAllowance() async {
    try {
      return (await _repositories?.processingApiClient
              .getProcessingAllowances())
          ?.cover;
    } on Object {
      return null;
    }
  }

  Future<int?> remainingCoverAllowance() async =>
      (await coverAllowance())?.remaining;

  Future<void> setAutomaticCoverGenerationEnabled(
      {required bool enabled}) async {
    await _repositories?.coverRepository.setAutomaticGenerationEnabled(
      enabled: enabled,
    );
    if (_repositories != null) {
      await _reloadFromRepositories();
      _startProcessingResumeWindow();
    }
  }
}

Map<String, Object?> _coverPayload(
  Dish dish, {
  required List<String> sourceIds,
  required CoverTreatment treatment,
  required CoverOrigin origin,
}) {
  final DateTime fallbackTimestamp = dish.createdAt ?? DateTime.now();
  return <String, Object?>{
    'dishTitle': dish.title,
    'sourceIds': sourceIds,
    'notes': dish.notes
        .map(
          (DishNote note) => <String, Object?>{
            'body': note.body,
            'position': note.position,
            'createdAt':
                (note.createdAt ?? fallbackTimestamp).toUtc().toIso8601String(),
            'updatedAt': (note.updatedAt ?? note.createdAt ?? fallbackTimestamp)
                .toUtc()
                .toIso8601String(),
          },
        )
        .toList(growable: false),
    'treatment': treatment.toJson(),
    'origin': origin.name,
    'contractVersion': 'cover-generation-v1',
  };
}
