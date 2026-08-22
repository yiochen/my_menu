import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/debug/debug_performance_recorder.dart';

void main() {
  test('records frame timings and a VM timeline to a JSON trace', () async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'mymenu-performance-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    TimingsCallback? timingsCallback;
    final _FakeTimelineSession session = _FakeTimelineSession();
    final DebugPerformanceRecorder recorder = DebugPerformanceRecorder(
      timelineCapture: () async => session,
      directoryProvider: () async => directory,
      addTimingsCallback: (TimingsCallback callback) {
        timingsCallback = callback;
      },
      removeTimingsCallback: (TimingsCallback callback) {
        expect(callback, timingsCallback);
        timingsCallback = null;
      },
      refreshRateProvider: () => 120,
      timingFlushDelay: Duration.zero,
    );
    addTearDown(recorder.dispose);
    final bool originalBuilds = debugProfileBuildsEnabledUserWidgets;
    final bool originalLayouts = debugProfileLayoutsEnabled;
    final bool originalPaints = debugProfilePaintsEnabled;

    recorder.setDetailedTracing(enabled: true);
    await recorder.start();
    expect(debugProfileBuildsEnabledUserWidgets, isTrue);
    expect(debugProfileLayoutsEnabled, isTrue);
    expect(debugProfilePaintsEnabled, isTrue);
    timingsCallback!(<FrameTiming>[
      FrameTiming(
        vsyncStart: 0,
        buildStart: 1000,
        buildFinish: 13000,
        rasterStart: 13000,
        rasterFinish: 15000,
        rasterFinishWallTime: 15000,
        frameNumber: 7,
      ),
    ]);
    await recorder.stop();

    final DebugPerformanceReport report = recorder.latestReport!;
    expect(recorder.state, DebugPerformanceRecorderState.complete);
    expect(report.frameCount, 1);
    expect(report.slowFrameCount, 1);
    expect(report.highLatencyFrameCount, 1);
    expect(report.likelyBottleneck, 'Likely UI-thread bound');
    expect(report.timelineCaptured, isTrue);
    expect(session.stopped, isTrue);
    expect(timingsCallback, isNull);
    expect(debugProfileBuildsEnabledUserWidgets, originalBuilds);
    expect(debugProfileLayoutsEnabled, originalLayouts);
    expect(debugProfilePaintsEnabled, originalPaints);
    final Map<String, Object?> trace = Map<String, Object?>.from(
      jsonDecode(await File(report.tracePath).readAsString())! as Map,
    );
    expect(trace['traceEvents'], isNotEmpty);
    expect(
      (trace['mymenuReport']! as Map<String, Object?>)['slowFrameCount'],
      1,
    );
    expect(trace['mymenuFrames'], hasLength(1));
  });

  test('still saves frame timings when the VM timeline is unavailable',
      () async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'mymenu-performance-fallback-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    TimingsCallback? timingsCallback;
    final DebugPerformanceRecorder recorder = DebugPerformanceRecorder(
      timelineCapture: () => throw StateError('unavailable'),
      directoryProvider: () async => directory,
      addTimingsCallback: (TimingsCallback callback) {
        timingsCallback = callback;
      },
      removeTimingsCallback: (_) {
        timingsCallback = null;
      },
      refreshRateProvider: () => 60,
      timingFlushDelay: Duration.zero,
    );
    addTearDown(recorder.dispose);

    await recorder.start();
    expect(recorder.state, DebugPerformanceRecorderState.recording);
    expect(recorder.warning, contains('VM timeline unavailable'));
    timingsCallback!(<FrameTiming>[]);
    await recorder.stop();

    expect(recorder.latestReport!.timelineCaptured, isFalse);
    expect(File(recorder.latestReport!.tracePath).existsSync(), isTrue);
  });
}

class _FakeTimelineSession implements DebugTimelineSession {
  bool stopped = false;

  @override
  Future<void> cancel() async {}

  @override
  Future<List<Object?>> stop() async {
    stopped = true;
    return <Object?>[
      <String, Object?>{
        'name': 'Flutter.Frame',
        'ph': 'X',
        'ts': 1,
        'dur': 2,
        'pid': 1,
        'tid': 1,
      },
    ];
  }
}
