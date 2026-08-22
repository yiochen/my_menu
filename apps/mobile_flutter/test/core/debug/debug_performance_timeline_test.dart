import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/debug/debug_performance_timeline.dart';
import 'package:vm_service/vm_service.dart';

void main() {
  test('clears the timeline and records only performance streams', () async {
    final _FakeTimelineVmService service = _FakeTimelineVmService(
      availableStreams: <String>[
        'API',
        'Compiler',
        'Dart',
        'Embedder',
        'GC',
      ],
      previousStreams: <String>['API'],
      timestamps: <int>[100, 450],
    );

    final DebugTimelineSession session =
        await startDebugTimelineCaptureWithService(service);

    expect(
      service.calls,
      <String>[
        'get flags',
        'set Dart,Embedder,GC',
        'clear',
        'clock 100',
      ],
    );

    final List<Object?> events = await session.stop();

    expect(events, service.events);
    expect(
      service.calls,
      <String>[
        'get flags',
        'set Dart,Embedder,GC',
        'clear',
        'clock 100',
        'clock 450',
        'timeline 100+350',
        'set API',
        'dispose',
      ],
    );
  });

  test('restores timeline streams when a recording is cancelled', () async {
    final _FakeTimelineVmService service = _FakeTimelineVmService(
      availableStreams: <String>['Dart', 'Embedder'],
      previousStreams: <String>['Compiler'],
      timestamps: <int>[200],
    );
    final DebugTimelineSession session =
        await startDebugTimelineCaptureWithService(service);

    await session.cancel();

    expect(
      service.calls,
      <String>[
        'get flags',
        'set Dart,Embedder',
        'clear',
        'clock 200',
        'set Compiler',
        'dispose',
      ],
    );
  });
}

class _FakeTimelineVmService implements DebugTimelineVmService {
  _FakeTimelineVmService({
    required this.availableStreams,
    required this.previousStreams,
    required List<int> timestamps,
  }) : _timestamps = List<int>.of(timestamps);

  final List<String> availableStreams;
  final List<String> previousStreams;
  final List<int> _timestamps;
  final List<String> calls = <String>[];
  final List<Object?> events = <Object?>[
    <String, Object?>{'name': 'Frame', 'ph': 'B', 'ts': 110},
  ];

  @override
  Future<void> clearTimeline() async {
    calls.add('clear');
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
  }

  @override
  Future<TimelineFlags> getTimelineFlags() async {
    calls.add('get flags');
    return TimelineFlags(
      availableStreams: availableStreams,
      recordedStreams: previousStreams,
    );
  }

  @override
  Future<List<Object?>> getTimelineEvents({
    required int timeOriginMicros,
    required int timeExtentMicros,
  }) async {
    calls.add('timeline $timeOriginMicros+$timeExtentMicros');
    return events;
  }

  @override
  Future<int> getTimelineMicros() async {
    final int timestamp = _timestamps.removeAt(0);
    calls.add('clock $timestamp');
    return timestamp;
  }

  @override
  Future<void> setTimelineFlags(List<String> recordedStreams) async {
    calls.add('set ${recordedStreams.join(',')}');
  }
}
