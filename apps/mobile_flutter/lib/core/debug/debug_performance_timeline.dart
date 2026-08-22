import 'dart:developer' show Service, ServiceProtocolInfo;
import 'dart:math' as math;

import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

typedef DebugTimelineCapture = Future<DebugTimelineSession> Function();

const List<String> debugPerformanceTimelineStreams = <String>[
  'Dart',
  'Embedder',
  'GC',
];

abstract interface class DebugTimelineSession {
  Future<List<Object?>> stop();

  Future<void> cancel();
}

Future<DebugTimelineSession> startVmServiceDebugTimelineCapture() async {
  final ServiceProtocolInfo info = await Service.getInfo();
  final Uri? serviceUri = info.serverWebSocketUri;
  if (serviceUri == null) {
    throw StateError('The Dart VM timeline service is unavailable.');
  }
  final VmService vmService = await vmServiceConnectUri(serviceUri.toString());
  return startDebugTimelineCaptureWithService(
    VmServiceDebugTimelineService(vmService),
  );
}

Future<DebugTimelineSession> startDebugTimelineCaptureWithService(
  DebugTimelineVmService service,
) async {
  try {
    final TimelineFlags flags = await service.getTimelineFlags();
    final Set<String>? availableStreams = flags.availableStreams?.toSet();
    final List<String> recordedStreams = availableStreams == null
        ? debugPerformanceTimelineStreams
        : debugPerformanceTimelineStreams
            .where(availableStreams.contains)
            .toList(growable: false);
    await service.setTimelineFlags(recordedStreams);
    await service.clearTimeline();
    final int startMicros = await service.getTimelineMicros();
    return _VmServiceDebugTimelineSession(
      service: service,
      previousStreams: flags.recordedStreams ?? const <String>[],
      startMicros: startMicros,
    );
  } on Object {
    await service.dispose();
    rethrow;
  }
}

class _VmServiceDebugTimelineSession implements DebugTimelineSession {
  _VmServiceDebugTimelineSession({
    required DebugTimelineVmService service,
    required List<String> previousStreams,
    required int startMicros,
  })  : _service = service,
        _previousStreams = previousStreams,
        _startMicros = startMicros;

  final DebugTimelineVmService _service;
  final List<String> _previousStreams;
  final int _startMicros;
  bool _closed = false;

  @override
  Future<List<Object?>> stop() async {
    try {
      final int endMicros = await _service.getTimelineMicros();
      return await _service.getTimelineEvents(
        timeOriginMicros: _startMicros,
        timeExtentMicros: math.max(1, endMicros - _startMicros),
      );
    } finally {
      await _close();
    }
  }

  @override
  Future<void> cancel() => _close();

  Future<void> _close() async {
    if (_closed) return;
    _closed = true;
    try {
      await _service.setTimelineFlags(_previousStreams);
    } finally {
      await _service.dispose();
    }
  }
}

abstract interface class DebugTimelineVmService {
  Future<TimelineFlags> getTimelineFlags();

  Future<void> setTimelineFlags(List<String> recordedStreams);

  Future<void> clearTimeline();

  Future<int> getTimelineMicros();

  Future<List<Object?>> getTimelineEvents({
    required int timeOriginMicros,
    required int timeExtentMicros,
  });

  Future<void> dispose();
}

class VmServiceDebugTimelineService implements DebugTimelineVmService {
  VmServiceDebugTimelineService(this._service);

  final VmService _service;

  @override
  Future<void> clearTimeline() async {
    await _service.clearVMTimeline();
  }

  @override
  Future<void> dispose() => _service.dispose();

  @override
  Future<TimelineFlags> getTimelineFlags() => _service.getVMTimelineFlags();

  @override
  Future<List<Object?>> getTimelineEvents({
    required int timeOriginMicros,
    required int timeExtentMicros,
  }) async {
    final Timeline timeline = await _service.getVMTimeline(
      timeOriginMicros: timeOriginMicros,
      timeExtentMicros: timeExtentMicros,
    );
    final Object? events = timeline.json?['traceEvents'];
    return events is List<Object?>
        ? List<Object?>.of(events)
        : const <Object?>[];
  }

  @override
  Future<int> getTimelineMicros() async {
    final Timestamp timestamp = await _service.getVMTimelineMicros();
    final int? value = timestamp.timestamp;
    if (value == null) {
      throw StateError('The Dart VM timeline clock is unavailable.');
    }
    return value;
  }

  @override
  Future<void> setTimelineFlags(List<String> recordedStreams) async {
    await _service.setVMTimelineFlags(recordedStreams);
  }
}
