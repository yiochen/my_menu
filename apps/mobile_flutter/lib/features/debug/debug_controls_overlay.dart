import 'package:flutter/material.dart';
import 'package:mymenu/core/debug/debug_controls.dart';
import 'package:mymenu/features/debug/debug_feedback_panel_section.dart';
import 'package:mymenu/features/debug/debug_performance_panel_section.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_overlay.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

class DebugControlsOverlay extends StatefulWidget {
  const DebugControlsOverlay({
    required this.controller,
    required this.child,
    required this.enabled,
    required this.onResetProcessingConsent,
    super.key,
  });

  final DebugControlsController controller;
  final Widget child;
  final bool enabled;
  final Future<void> Function() onResetProcessingConsent;

  @override
  State<DebugControlsOverlay> createState() => _DebugControlsOverlayState();
}

class _DebugControlsOverlayState extends State<DebugControlsOverlay> {
  static const double _edgeInset = 10;
  static const double _launcherExtent = 48;

  Offset? _launcherPosition;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return DebugFeedbackOverlay(
      controller: widget.controller.feedback,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          widget.controller,
          widget.controller.feedback,
          widget.controller.performanceRecorder,
        ]),
        builder: (BuildContext context, _) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Size viewport = constraints.biggest;
              final EdgeInsets safeInsets = MediaQuery.paddingOf(context);
              final Offset launcherPosition = _clampLauncher(
                _launcherPosition ?? _defaultLauncher(viewport, safeInsets),
                viewport,
                safeInsets,
              );
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  widget.child,
                  if (widget.controller.performanceOverlayEnabled)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: PerformanceOverlay.allEnabled(),
                      ),
                    ),
                  if (!widget.controller.feedback.collecting &&
                      widget.controller.panelOpen)
                    CustomSingleChildLayout(
                      delegate: _DebugPanelLayoutDelegate(
                        anchor: launcherPosition,
                        safeInsets: safeInsets,
                        edgeInset: _edgeInset,
                        launcherExtent: _launcherExtent,
                      ),
                      child: _DebugPanel(
                        controller: widget.controller,
                        onResetProcessingConsent:
                            widget.onResetProcessingConsent,
                      ),
                    )
                  else if (!widget.controller.feedback.collecting)
                    Positioned(
                      left: launcherPosition.dx,
                      top: launcherPosition.dy,
                      child: _DebugLauncher(
                        controller: widget.controller,
                        onPanUpdate: (DragUpdateDetails details) {
                          _moveLauncher(
                            details.delta,
                            viewport,
                            safeInsets,
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Offset _defaultLauncher(Size viewport, EdgeInsets safeInsets) {
    return Offset(
      viewport.width - safeInsets.right - _edgeInset - _launcherExtent,
      safeInsets.top + _edgeInset,
    );
  }

  void _moveLauncher(
    Offset delta,
    Size viewport,
    EdgeInsets safeInsets,
  ) {
    setState(() {
      final Offset current = _clampLauncher(
        _launcherPosition ?? _defaultLauncher(viewport, safeInsets),
        viewport,
        safeInsets,
      );
      _launcherPosition = _clampLauncher(
        current + delta,
        viewport,
        safeInsets,
      );
    });
  }

  Offset _clampLauncher(
    Offset position,
    Size viewport,
    EdgeInsets safeInsets,
  ) {
    final double minX = safeInsets.left + _edgeInset;
    final double maxX =
        (viewport.width - safeInsets.right - _edgeInset - _launcherExtent)
            .clamp(minX, double.infinity);
    final double minY = safeInsets.top + _edgeInset;
    final double maxY =
        (viewport.height - safeInsets.bottom - _edgeInset - _launcherExtent)
            .clamp(minY, double.infinity);
    return Offset(
      position.dx.clamp(minX, maxX),
      position.dy.clamp(minY, maxY),
    );
  }
}

class _DebugLauncher extends StatelessWidget {
  const _DebugLauncher({
    required this.controller,
    required this.onPanUpdate,
  });

  final DebugControlsController controller;
  final GestureDragUpdateCallback onPanUpdate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: onPanUpdate,
      child: Material(
        color: MyMenuColors.ink.withValues(alpha: 0.9),
        shape: const CircleBorder(),
        elevation: 6,
        child: Semantics(
          label: 'Open debug controls. Drag to move.',
          button: true,
          child: IconButton(
            key: const ValueKey<String>('debug_controls_open'),
            onPressed: () => controller.setPanelOpen(open: true),
            icon: Icon(
              controller.performanceRecorder.isRecording
                  ? Icons.fiber_manual_record_rounded
                  : Icons.developer_mode_rounded,
              color: controller.performanceRecorder.isRecording
                  ? Colors.redAccent
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _DebugPanelLayoutDelegate extends SingleChildLayoutDelegate {
  const _DebugPanelLayoutDelegate({
    required this.anchor,
    required this.safeInsets,
    required this.edgeInset,
    required this.launcherExtent,
  });

  final Offset anchor;
  final EdgeInsets safeInsets;
  final double edgeInset;
  final double launcherExtent;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(
      Size(
        (constraints.maxWidth - safeInsets.horizontal - edgeInset * 2)
            .clamp(0, double.infinity),
        (constraints.maxHeight - safeInsets.vertical - edgeInset * 2)
            .clamp(0, double.infinity),
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double minX = safeInsets.left + edgeInset;
    final double maxX =
        (size.width - safeInsets.right - edgeInset - childSize.width)
            .clamp(minX, double.infinity);
    final double minY = safeInsets.top + edgeInset;
    final double maxY =
        (size.height - safeInsets.bottom - edgeInset - childSize.height)
            .clamp(minY, double.infinity);
    return Offset(
      (anchor.dx + launcherExtent - childSize.width).clamp(minX, maxX),
      anchor.dy.clamp(minY, maxY),
    );
  }

  @override
  bool shouldRelayout(_DebugPanelLayoutDelegate oldDelegate) {
    return anchor != oldDelegate.anchor ||
        safeInsets != oldDelegate.safeInsets ||
        edgeInset != oldDelegate.edgeInset ||
        launcherExtent != oldDelegate.launcherExtent;
  }
}

class _DebugPanel extends StatelessWidget {
  const _DebugPanel({
    required this.controller,
    required this.onResetProcessingConsent,
  });

  final DebugControlsController controller;
  final Future<void> Function() onResetProcessingConsent;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey<String>('debug_controls_panel'),
      color: MyMenuColors.surface,
      elevation: 12,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 290,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _DebugPanelHeader(controller: controller),
              const Divider(height: 1),
              _DebugToggle(
                key: const ValueKey<String>('debug_network_toggle'),
                icon: controller.networkEnabled
                    ? Icons.wifi_rounded
                    : Icons.wifi_off_rounded,
                label: 'Network',
                value: controller.networkEnabled,
                onChanged: (bool value) {
                  controller.setNetworkEnabled(enabled: value);
                },
              ),
              _DebugToggle(
                key: const ValueKey<String>('debug_slow_animation_toggle'),
                icon: Icons.slow_motion_video_rounded,
                label: 'Slow animation',
                value: controller.slowAnimations,
                onChanged: (bool value) {
                  controller.setSlowAnimations(enabled: value);
                },
              ),
              _DebugToggle(
                key: const ValueKey<String>('debug_camera_toggle'),
                icon: controller.cameraAccessEnabled
                    ? Icons.photo_camera_rounded
                    : Icons.no_photography_rounded,
                label: 'Camera access',
                value: controller.cameraAccessEnabled,
                onChanged: (bool value) {
                  controller.setCameraAccessEnabled(enabled: value);
                },
              ),
              _DebugToggle(
                key: const ValueKey<String>('debug_performance_overlay_toggle'),
                icon: Icons.speed_rounded,
                label: 'Performance overlay',
                value: controller.performanceOverlayEnabled,
                onChanged: (bool value) {
                  controller.setPerformanceOverlayEnabled(enabled: value);
                },
              ),
              DebugFeedbackPanelSection(
                controller: controller.feedback,
                onStart: () {
                  controller.setPanelOpen(open: false);
                  controller.feedback.startCollecting();
                },
              ),
              const Divider(height: 1),
              ListTile(
                key: const ValueKey<String>('debug_reset_processing_consent'),
                leading: const Icon(
                  Icons.restart_alt_rounded,
                  color: MyMenuColors.orangeDark,
                ),
                title: const Text('Reset AI consent'),
                dense: true,
                onTap: () async {
                  await onResetProcessingConsent();
                  controller.setPanelOpen(open: false);
                },
              ),
              const Divider(height: 1),
              DebugPerformancePanelSection(
                recorder: controller.performanceRecorder,
                onRecordingStarted: () {
                  controller.setPanelOpen(open: false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DebugPanelHeader extends StatelessWidget {
  const _DebugPanelHeader({required this.controller});

  final DebugControlsController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 6, 8),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.developer_mode_rounded,
            color: MyMenuColors.orangeDark,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Debug controls',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Semantics(
            label: 'Close debug controls',
            button: true,
            child: IconButton(
              key: const ValueKey<String>('debug_controls_close'),
              onPressed: () => controller.setPanelOpen(open: false),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _DebugToggle extends StatelessWidget {
  const _DebugToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: MyMenuColors.orangeDark),
      title: Text(label),
      value: value,
      onChanged: onChanged,
      dense: true,
    );
  }
}
