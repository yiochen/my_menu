part of 'my_menu_api_client.dart';

extension _FakeCaptureGrouping on FakeMyMenuApiClient {
  void _completeQueuedGroupingJobs() {
    final List<ApiAiJob> queued = _aiJobs.values
        .where(
          (ApiAiJob job) =>
              job.jobType == 'batch_grouping' && job.status == 'queued',
        )
        .toList(growable: false);
    for (final ApiAiJob job in queued) {
      final List<_FakeCaptureRecord> captures = _captures.values
          .where(
            (_FakeCaptureRecord capture) =>
                capture.batchId == job.subjectId &&
                capture.status != 'discarded',
          )
          .toList(growable: false)
        ..sort(
          (_FakeCaptureRecord left, _FakeCaptureRecord right) =>
              left.ordinal.compareTo(right.ordinal),
        );
      final Map<String, List<_FakeCaptureRecord>> groups =
          <String, List<_FakeCaptureRecord>>{};
      for (final _FakeCaptureRecord capture in captures) {
        final String key = capture.capturedLocalDate == null
            ? 'unknown:${capture.id}'
            : 'date:${capture.capturedLocalDate}';
        groups.putIfAbsent(key, () => <_FakeCaptureRecord>[]).add(capture);
      }
      _applyFakeGroups(job, groups);
    }
  }

  void _applyFakeGroups(
    ApiAiJob job,
    Map<String, List<_FakeCaptureRecord>> groups,
  ) {
    final List<Map<String, Object?>> results = <Map<String, Object?>>[];
    for (final MapEntry<String, List<_FakeCaptureRecord>> entry
        in groups.entries) {
      final _FakeCaptureRecord first = entry.value.first;
      final String dishId =
          'fake-dish-${job.subjectId}-${entry.key.replaceAll(':', '-')}';
      final String title = first.kind == 'idea'
          ? _titleCase(first.ideaText ?? 'Captured Dish')
          : _datedFakeTitle(first.capturedLocalDate);
      final List<ApiSourcePhoto> photos = entry.value
          .where((_FakeCaptureRecord capture) => capture.mediaRef != null)
          .map(
            (_FakeCaptureRecord capture) => ApiSourcePhoto(
              id: 'fake-image-${capture.id}',
              mediaRef: capture.mediaRef!,
              capturedAt: capture.capturedAt,
              confidenceLabel: 'Fake AI',
            ),
          )
          .toList(growable: false);
      _dishes[dishId] = ApiDish(
        id: dishId,
        title: title,
        description: 'Fake AI draft from a date-grouped capture.',
        labels: const <String>['capture', 'fake-ai'],
        isFavorite: false,
        madeCount: photos.isEmpty ? 0 : 1,
        lastMadeAt: photos.isEmpty ? null : first.capturedAt,
        sourcePhotos: photos,
        ingredients: const <String>[],
        steps: const <String>[],
        notes: const <String>[],
      );
      for (final _FakeCaptureRecord capture in entry.value) {
        capture
          ..status = 'applied'
          ..appliedDishId = dishId;
        _emit(
          'capture.applied_to_new_dish',
          <String, String>{
            'captureId': capture.id,
            'batchId': job.subjectId,
            'dishId': dishId,
          },
        );
      }
      _emit('dish.created', <String, String>{'dishId': dishId});
      results.add(<String, Object?>{
        'groupingKey': entry.key,
        'dishId': dishId,
        'captureIds':
            entry.value.map((_FakeCaptureRecord item) => item.id).toList(),
        'title': title,
      });
    }

    _batchStatuses[job.subjectId] = 'applied';
    _emit(
      'capture_batch.applied',
      <String, String>{'batchId': job.subjectId},
    );
    final DateTime now = DateTime.now();
    _aiJobs[job.id] = _copyAiJob(
      job,
      status: 'succeeded',
      updatedAt: now,
      normalizedResult: <String, Object?>{
        'batchId': job.subjectId,
        'occasions': results,
      },
      completedAt: now,
    );
    _emit('ai_job.succeeded', <String, String>{'aiJobId': job.id});
  }

  void _emit(String type, Map<String, String> entityIds) {
    _cursor += 1;
    _events.add(
      ApiSyncEvent(cursor: _cursor, type: type, entityIds: entityIds),
    );
  }

  String _datedFakeTitle(String? localDate) {
    if (localDate == null) {
      return 'Captured Dish';
    }
    final DateTime date = DateTime.parse(localDate);
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Captured Dish · ${months[date.month - 1]} ${date.day}';
  }

  String _titleCase(String value) {
    return value
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .map(
          (String part) =>
              '${part.substring(0, 1).toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}
