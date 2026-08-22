import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mymenu/core/debug/debug_performance_recorder.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

class DebugPerformancePanelSection extends StatelessWidget {
  const DebugPerformancePanelSection({
    required this.recorder,
    required this.onRecordingStarted,
    super.key,
  });

  final DebugPerformanceRecorder recorder;
  final VoidCallback onRecordingStarted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.speed_rounded, color: MyMenuColors.orangeDark),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Performance recording',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _body(context),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    return switch (recorder.state) {
      DebugPerformanceRecorderState.starting => const _ProgressMessage(
          label: 'Starting timeline…',
        ),
      DebugPerformanceRecorderState.recording => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Recording ${recorder.elapsed.inSeconds}s of '
              '${recorder.maximumDuration.inSeconds}s',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              key: const ValueKey<String>('debug_performance_record_stop'),
              onPressed: recorder.stop,
              icon: const Icon(Icons.stop_rounded),
              label: const Text('Stop & save'),
            ),
          ],
        ),
      DebugPerformanceRecorderState.stopping => const _ProgressMessage(
          label: 'Saving trace…',
        ),
      DebugPerformanceRecorderState.idle ||
      DebugPerformanceRecorderState.complete ||
      DebugPerformanceRecorderState.failed =>
        _ReadyToRecord(
          recorder: recorder,
          onRecordingStarted: onRecordingStarted,
        ),
    };
  }
}

class _ReadyToRecord extends StatelessWidget {
  const _ReadyToRecord({
    required this.recorder,
    required this.onRecordingStarted,
  });

  final DebugPerformanceRecorder recorder;
  final VoidCallback onRecordingStarted;

  @override
  Widget build(BuildContext context) {
    final DebugPerformanceReport? report = recorder.latestReport;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SwitchListTile(
          key: const ValueKey<String>('debug_performance_detailed_toggle'),
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Detailed widget tracing'),
          subtitle: const Text(
            'Adds build, layout, and paint events with extra overhead.',
          ),
          value: recorder.detailedTracing,
          onChanged: (bool value) {
            recorder.setDetailedTracing(enabled: value);
          },
        ),
        FilledButton.icon(
          key: const ValueKey<String>('debug_performance_record_start'),
          onPressed: () async {
            await recorder.start();
            if (recorder.isRecording) onRecordingStarted();
          },
          icon: const Icon(Icons.fiber_manual_record_rounded),
          label: Text('Record up to ${recorder.maximumDuration.inSeconds}s'),
        ),
        if (report != null) ...<Widget>[
          const SizedBox(height: 12),
          _PerformanceSummary(report: report),
        ],
        if (recorder.warning case final String warning) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            warning,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: MyMenuColors.orangeDark,
                ),
          ),
        ],
        if (recorder.error case final String error) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ],
      ],
    );
  }
}

class _PerformanceSummary extends StatelessWidget {
  const _PerformanceSummary({required this.report});

  final DebugPerformanceReport report;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MyMenuColors.orangeSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${report.frameCount} frames · ${report.slowFrameCount} slow',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 3),
            Text(
              '${report.likelyBottleneck}\n'
              'Worst UI ${_milliseconds(report.worstBuild)}, '
              'raster ${_milliseconds(report.worstRaster)}, '
              'total ${_milliseconds(report.worstTotal)}\n'
              '${report.refreshRate.toStringAsFixed(0)} Hz budget '
              '${_milliseconds(report.frameBudget)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              report.timelineCaptured
                  ? 'Full VM timeline saved'
                  : 'Frame timing report saved',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 2),
            SelectableText(
              report.tracePath,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 3,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const ValueKey<String>('debug_performance_copy_path'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: report.tracePath));
                },
                icon: const Icon(Icons.copy_rounded, size: 17),
                label: const Text('Copy path'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _milliseconds(Duration value) {
    return '${(value.inMicroseconds / 1000).toStringAsFixed(1)}ms';
  }
}

class _ProgressMessage extends StatelessWidget {
  const _ProgressMessage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}
