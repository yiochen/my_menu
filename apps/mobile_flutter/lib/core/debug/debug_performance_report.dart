enum DebugPerformanceRecorderState {
  idle,
  starting,
  recording,
  stopping,
  complete,
  failed,
}

class DebugPerformanceReport {
  const DebugPerformanceReport({
    required this.startedAt,
    required this.duration,
    required this.refreshRate,
    required this.frameBudget,
    required this.frameCount,
    required this.slowFrameCount,
    required this.highLatencyFrameCount,
    required this.averageBuild,
    required this.averageRaster,
    required this.worstBuild,
    required this.worstRaster,
    required this.worstTotal,
    required this.likelyBottleneck,
    required this.tracePath,
    required this.timelineCaptured,
  });

  final DateTime startedAt;
  final Duration duration;
  final double refreshRate;
  final Duration frameBudget;
  final int frameCount;
  final int slowFrameCount;
  final int highLatencyFrameCount;
  final Duration averageBuild;
  final Duration averageRaster;
  final Duration worstBuild;
  final Duration worstRaster;
  final Duration worstTotal;
  final String likelyBottleneck;
  final String tracePath;
  final bool timelineCaptured;

  Map<String, Object?> toJson() => <String, Object?>{
        'startedAt': startedAt.toUtc().toIso8601String(),
        'durationMicros': duration.inMicroseconds,
        'refreshRate': refreshRate,
        'frameBudgetMicros': frameBudget.inMicroseconds,
        'frameCount': frameCount,
        'slowFrameCount': slowFrameCount,
        'highLatencyFrameCount': highLatencyFrameCount,
        'averageBuildMicros': averageBuild.inMicroseconds,
        'averageRasterMicros': averageRaster.inMicroseconds,
        'worstBuildMicros': worstBuild.inMicroseconds,
        'worstRasterMicros': worstRaster.inMicroseconds,
        'worstTotalMicros': worstTotal.inMicroseconds,
        'likelyBottleneck': likelyBottleneck,
        'timelineCaptured': timelineCaptured,
      };
}
