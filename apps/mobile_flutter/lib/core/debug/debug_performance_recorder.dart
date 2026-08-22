import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate' as isolate;
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:mymenu/core/debug/debug_performance_report.dart';
import 'package:mymenu/core/debug/debug_performance_timeline.dart';
import 'package:path_provider/path_provider.dart';

export 'package:mymenu/core/debug/debug_performance_report.dart';
export 'package:mymenu/core/debug/debug_performance_timeline.dart'
    show DebugTimelineSession;

typedef DebugTraceDirectoryProvider = Future<Directory> Function();
typedef DebugTimingsRegistration = void Function(TimingsCallback callback);
typedef DebugRefreshRateProvider = double Function();

class DebugPerformanceRecorder extends ChangeNotifier {
  DebugPerformanceRecorder({
    DebugTimelineCapture timelineCapture = startVmServiceDebugTimelineCapture,
    DebugTraceDirectoryProvider? directoryProvider,
    DebugTimingsRegistration? addTimingsCallback,
    DebugTimingsRegistration? removeTimingsCallback,
    DebugRefreshRateProvider? refreshRateProvider,
    this.maximumDuration = const Duration(seconds: 30),
    this.timingFlushDelay = const Duration(milliseconds: 150),
  })  : _timelineCapture = timelineCapture,
        _directoryProvider = directoryProvider ?? _defaultTraceDirectory,
        _addTimingsCallback = addTimingsCallback,
        _removeTimingsCallback = removeTimingsCallback,
        _refreshRateProvider = refreshRateProvider ?? _displayRefreshRate;

  final DebugTimelineCapture _timelineCapture;
  final DebugTraceDirectoryProvider _directoryProvider;
  final DebugTimingsRegistration? _addTimingsCallback;
  final DebugTimingsRegistration? _removeTimingsCallback;
  final DebugRefreshRateProvider _refreshRateProvider;
  final Duration maximumDuration;
  final Duration timingFlushDelay;
  final List<FrameTiming> _frames = <FrameTiming>[];

  DebugPerformanceRecorderState _state = DebugPerformanceRecorderState.idle;
  DebugTimelineSession? _timelineSession;
  DateTime? _startedAt;
  Timer? _maximumTimer;
  Timer? _elapsedTimer;
  DebugPerformanceReport? _latestReport;
  String? _warning;
  String? _error;
  bool _detailedTracing = false;
  bool? _previousProfileBuilds;
  bool? _previousProfileLayouts;
  bool? _previousProfilePaints;
  bool _timingsRegistered = false;

  DebugPerformanceRecorderState get state => _state;
  DebugPerformanceReport? get latestReport => _latestReport;
  String? get warning => _warning;
  String? get error => _error;
  bool get detailedTracing => _detailedTracing;
  bool get isRecording => _state == DebugPerformanceRecorderState.recording;
  Duration get elapsed => _startedAt == null
      ? Duration.zero
      : DateTime.now().difference(_startedAt!);

  void setDetailedTracing({required bool enabled}) {
    if (_state == DebugPerformanceRecorderState.recording ||
        _state == DebugPerformanceRecorderState.starting ||
        _state == DebugPerformanceRecorderState.stopping ||
        _detailedTracing == enabled) {
      return;
    }
    _detailedTracing = enabled;
    notifyListeners();
  }

  Future<void> start() async {
    if (_state == DebugPerformanceRecorderState.starting ||
        _state == DebugPerformanceRecorderState.recording ||
        _state == DebugPerformanceRecorderState.stopping) {
      return;
    }
    _state = DebugPerformanceRecorderState.starting;
    _latestReport = null;
    _warning = null;
    _error = null;
    _frames.clear();
    notifyListeners();

    try {
      try {
        _timelineSession = await _timelineCapture();
      } on Object catch (error) {
        _timelineSession = null;
        _warning = 'VM timeline unavailable: $error';
      }
      _enableDetailedTracing();
      _startedAt = DateTime.now();
      (_addTimingsCallback ?? SchedulerBinding.instance.addTimingsCallback)(
        _recordTimings,
      );
      _timingsRegistered = true;
      _state = DebugPerformanceRecorderState.recording;
      _maximumTimer = Timer(maximumDuration, () => unawaited(stop()));
      _elapsedTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => notifyListeners(),
      );
      notifyListeners();
    } on Object catch (error) {
      final DebugTimelineSession? timelineSession = _timelineSession;
      _timelineSession = null;
      if (timelineSession != null) await timelineSession.cancel();
      _removeTimingsRegistration();
      _restoreDetailedTracing();
      _state = DebugPerformanceRecorderState.failed;
      _error = 'Could not start performance recording: $error';
      notifyListeners();
    }
  }

  Future<void> stop() async {
    if (_state != DebugPerformanceRecorderState.recording) return;
    _state = DebugPerformanceRecorderState.stopping;
    _maximumTimer?.cancel();
    _elapsedTimer?.cancel();
    notifyListeners();

    try {
      await Future<void>.delayed(timingFlushDelay);
      _removeTimingsRegistration();
      _restoreDetailedTracing();
      final DateTime finishedAt = DateTime.now();
      List<Object?> timelineEvents = const <Object?>[];
      final DebugTimelineSession? timelineSession = _timelineSession;
      _timelineSession = null;
      if (timelineSession != null) {
        try {
          timelineEvents = await timelineSession.stop().timeout(
                const Duration(seconds: 5),
              );
        } on Object catch (error) {
          _warning = 'VM timeline could not be saved: $error';
          await timelineSession.cancel();
        }
      }
      final DebugPerformanceReport report = await _writeReport(
        finishedAt: finishedAt,
        timelineEvents: timelineEvents,
      );
      _latestReport = report;
      _state = DebugPerformanceRecorderState.complete;
    } on Object catch (error) {
      _state = DebugPerformanceRecorderState.failed;
      _error = 'Could not save performance recording: $error';
    } finally {
      notifyListeners();
    }
  }

  void _recordTimings(List<FrameTiming> timings) => _frames.addAll(timings);

  void _removeTimingsRegistration() {
    if (!_timingsRegistered) return;
    _timingsRegistered = false;
    (_removeTimingsCallback ??
        SchedulerBinding.instance.removeTimingsCallback)(_recordTimings);
  }

  void _enableDetailedTracing() {
    _previousProfileBuilds = debugProfileBuildsEnabledUserWidgets;
    _previousProfileLayouts = debugProfileLayoutsEnabled;
    _previousProfilePaints = debugProfilePaintsEnabled;
    if (_detailedTracing) {
      debugProfileBuildsEnabledUserWidgets = true;
      debugProfileLayoutsEnabled = true;
      debugProfilePaintsEnabled = true;
    }
  }

  void _restoreDetailedTracing() {
    if (_previousProfileBuilds case final bool value) {
      debugProfileBuildsEnabledUserWidgets = value;
    }
    if (_previousProfileLayouts case final bool value) {
      debugProfileLayoutsEnabled = value;
    }
    if (_previousProfilePaints case final bool value) {
      debugProfilePaintsEnabled = value;
    }
    _previousProfileBuilds = null;
    _previousProfileLayouts = null;
    _previousProfilePaints = null;
  }

  Future<DebugPerformanceReport> _writeReport({
    required DateTime finishedAt,
    required List<Object?> timelineEvents,
  }) async {
    final DateTime startedAt = _startedAt!;
    final double refreshRate = _refreshRateProvider();
    final Duration frameBudget = Duration(
      microseconds: (Duration.microsecondsPerSecond / refreshRate).round(),
    );
    final List<FrameTiming> slowFrames = _frames
        .where(
          (FrameTiming frame) =>
              frame.buildDuration > frameBudget ||
              frame.rasterDuration > frameBudget,
        )
        .toList(growable: false);
    final int highLatencyFrameCount = _frames
        .where((FrameTiming frame) => frame.totalSpan > frameBudget)
        .length;
    final DebugPerformanceReport provisional = DebugPerformanceReport(
      startedAt: startedAt,
      duration: finishedAt.difference(startedAt),
      refreshRate: refreshRate,
      frameBudget: frameBudget,
      frameCount: _frames.length,
      slowFrameCount: slowFrames.length,
      highLatencyFrameCount: highLatencyFrameCount,
      averageBuild:
          _average(_frames, (FrameTiming frame) => frame.buildDuration),
      averageRaster:
          _average(_frames, (FrameTiming frame) => frame.rasterDuration),
      worstBuild: _maximum(_frames, (FrameTiming frame) => frame.buildDuration),
      worstRaster:
          _maximum(_frames, (FrameTiming frame) => frame.rasterDuration),
      worstTotal: _maximum(_frames, (FrameTiming frame) => frame.totalSpan),
      likelyBottleneck: _bottleneck(slowFrames),
      tracePath: '',
      timelineCaptured: timelineEvents.isNotEmpty,
    );
    final Map<String, Object?> payload = <String, Object?>{
      'traceEvents': timelineEvents,
      'displayTimeUnit': 'ms',
      'mymenuReport': provisional.toJson(),
      'mymenuFrames': _frames.map(_frameToJson).toList(growable: false),
    };
    final Directory directory = await _directoryProvider();
    await directory.create(recursive: true);
    final String timestamp =
        startedAt.toUtc().toIso8601String().replaceAll(RegExp('[:.]'), '-');
    final File file =
        File('${directory.path}/mymenu-performance-$timestamp.json');
    final String encoded = await isolate.Isolate.run(() => jsonEncode(payload));
    await file.writeAsString(encoded, flush: true);
    return DebugPerformanceReport(
      startedAt: provisional.startedAt,
      duration: provisional.duration,
      refreshRate: provisional.refreshRate,
      frameBudget: provisional.frameBudget,
      frameCount: provisional.frameCount,
      slowFrameCount: provisional.slowFrameCount,
      highLatencyFrameCount: provisional.highLatencyFrameCount,
      averageBuild: provisional.averageBuild,
      averageRaster: provisional.averageRaster,
      worstBuild: provisional.worstBuild,
      worstRaster: provisional.worstRaster,
      worstTotal: provisional.worstTotal,
      likelyBottleneck: provisional.likelyBottleneck,
      tracePath: file.path,
      timelineCaptured: provisional.timelineCaptured,
    );
  }

  Map<String, Object?> _frameToJson(FrameTiming frame) => <String, Object?>{
        'frameNumber': frame.frameNumber,
        'vsyncStartMicros':
            frame.timestampInMicroseconds(FramePhase.vsyncStart),
        'buildMicros': frame.buildDuration.inMicroseconds,
        'rasterMicros': frame.rasterDuration.inMicroseconds,
        'totalMicros': frame.totalSpan.inMicroseconds,
        'vsyncOverheadMicros': frame.vsyncOverhead.inMicroseconds,
        'layerCacheCount': frame.layerCacheCount,
        'layerCacheBytes': frame.layerCacheBytes,
        'pictureCacheCount': frame.pictureCacheCount,
        'pictureCacheBytes': frame.pictureCacheBytes,
      };

  Duration _average(
    List<FrameTiming> frames,
    Duration Function(FrameTiming frame) select,
  ) {
    if (frames.isEmpty) return Duration.zero;
    final int total = frames.fold<int>(
      0,
      (int value, FrameTiming frame) => value + select(frame).inMicroseconds,
    );
    return Duration(microseconds: total ~/ frames.length);
  }

  Duration _maximum(
    List<FrameTiming> frames,
    Duration Function(FrameTiming frame) select,
  ) {
    return Duration(
      microseconds: frames.fold<int>(
        0,
        (int value, FrameTiming frame) =>
            math.max(value, select(frame).inMicroseconds),
      ),
    );
  }

  String _bottleneck(List<FrameTiming> slowFrames) {
    if (slowFrames.isEmpty) return 'No clear bottleneck';
    final int buildMicros = slowFrames.fold<int>(
      0,
      (int value, FrameTiming frame) =>
          value + frame.buildDuration.inMicroseconds,
    );
    final int rasterMicros = slowFrames.fold<int>(
      0,
      (int value, FrameTiming frame) =>
          value + frame.rasterDuration.inMicroseconds,
    );
    if (buildMicros > rasterMicros * 1.25) return 'Likely UI-thread bound';
    if (rasterMicros > buildMicros * 1.25) return 'Likely raster-thread bound';
    return 'Mixed UI and raster work';
  }

  @override
  void dispose() {
    _maximumTimer?.cancel();
    _elapsedTimer?.cancel();
    _removeTimingsRegistration();
    _restoreDetailedTracing();
    final DebugTimelineSession? timelineSession = _timelineSession;
    if (timelineSession != null) unawaited(timelineSession.cancel());
    super.dispose();
  }

  static Future<Directory> _defaultTraceDirectory() async {
    if (Platform.isAndroid) {
      final Directory? external = await getExternalStorageDirectory();
      if (external != null) {
        return Directory('${external.path}/performance-traces');
      }
    }
    final Directory support = await getApplicationSupportDirectory();
    return Directory('${support.path}/performance-traces');
  }

  static double _displayRefreshRate() {
    final Iterable<Display> displays = PlatformDispatcher.instance.displays;
    if (displays.isEmpty || displays.first.refreshRate <= 0) return 60;
    return displays.first.refreshRate;
  }
}
