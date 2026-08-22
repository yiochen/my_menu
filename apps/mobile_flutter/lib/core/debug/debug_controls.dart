import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:mymenu/core/debug/debug_performance_recorder.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_controller.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_models.dart';

class DebugControlsSettings {
  const DebugControlsSettings({
    this.networkEnabled = true,
    this.slowAnimations = false,
    this.cameraAccessEnabled = true,
    this.performanceOverlayEnabled = false,
    this.feedbackEntries = const <DebugFeedbackEntry>[],
  });

  final bool networkEnabled;
  final bool slowAnimations;
  final bool cameraAccessEnabled;
  final bool performanceOverlayEnabled;
  final List<DebugFeedbackEntry> feedbackEntries;
}

abstract interface class DebugControlsPersistence {
  Future<void> setNetworkEnabled({required bool enabled});

  Future<void> setSlowAnimations({required bool enabled});

  Future<void> setCameraAccessEnabled({required bool enabled});

  Future<void> setPerformanceOverlayEnabled({required bool enabled});

  Future<void> setFeedbackEntries(List<DebugFeedbackEntry> entries);
}

class DebugControlsBootstrap {
  const DebugControlsBootstrap({
    required this.settings,
    required this.persistence,
  });

  final DebugControlsSettings settings;
  final DebugControlsPersistence persistence;
}

class DebugControlsController extends ChangeNotifier
    implements NetworkStatusMonitor {
  DebugControlsController({
    DebugControlsSettings initialSettings = const DebugControlsSettings(),
    DebugControlsPersistence? persistence,
    DebugPerformanceRecorder? performanceRecorder,
  })  : _networkEnabled = initialSettings.networkEnabled,
        _slowAnimations = initialSettings.slowAnimations,
        _cameraAccessEnabled = initialSettings.cameraAccessEnabled,
        _performanceOverlayEnabled = initialSettings.performanceOverlayEnabled,
        _persistence = persistence,
        performanceRecorder = performanceRecorder ?? DebugPerformanceRecorder(),
        feedback = DebugFeedbackController(
          initialEntries: initialSettings.feedbackEntries,
          persistEntries: persistence?.setFeedbackEntries,
        ) {
    if (_slowAnimations) {
      timeDilation = 5;
    }
  }

  final StreamController<void> _networkChanges =
      StreamController<void>.broadcast();
  final DebugControlsPersistence? _persistence;
  final DebugFeedbackController feedback;
  final DebugPerformanceRecorder performanceRecorder;

  bool _networkEnabled;
  bool _slowAnimations;
  bool _cameraAccessEnabled;
  bool _performanceOverlayEnabled;
  bool _panelOpen = false;

  bool get networkEnabled => _networkEnabled;
  bool get slowAnimations => _slowAnimations;
  bool get cameraAccessEnabled => _cameraAccessEnabled;
  bool get performanceOverlayEnabled => _performanceOverlayEnabled;
  bool get panelOpen => _panelOpen;

  @override
  Stream<void> get changes => _networkChanges.stream;

  void setNetworkEnabled({required bool enabled}) {
    final bool value = enabled;
    if (_networkEnabled == value) {
      return;
    }
    _networkEnabled = value;
    notifyListeners();
    _networkChanges.add(null);
    final DebugControlsPersistence? persistence = _persistence;
    if (persistence != null) {
      unawaited(persistence.setNetworkEnabled(enabled: value));
    }
  }

  void setSlowAnimations({required bool enabled}) {
    final bool value = enabled;
    if (_slowAnimations == value) {
      return;
    }
    _slowAnimations = value;
    timeDilation = value ? 5 : 1;
    notifyListeners();
    final DebugControlsPersistence? persistence = _persistence;
    if (persistence != null) {
      unawaited(persistence.setSlowAnimations(enabled: value));
    }
  }

  void setCameraAccessEnabled({required bool enabled}) {
    final bool value = enabled;
    if (_cameraAccessEnabled == value) {
      return;
    }
    _cameraAccessEnabled = value;
    notifyListeners();
    final DebugControlsPersistence? persistence = _persistence;
    if (persistence != null) {
      unawaited(persistence.setCameraAccessEnabled(enabled: value));
    }
  }

  void setPerformanceOverlayEnabled({required bool enabled}) {
    final bool value = enabled;
    if (_performanceOverlayEnabled == value) {
      return;
    }
    _performanceOverlayEnabled = value;
    notifyListeners();
    final DebugControlsPersistence? persistence = _persistence;
    if (persistence != null) {
      unawaited(persistence.setPerformanceOverlayEnabled(enabled: value));
    }
  }

  void setPanelOpen({required bool open}) {
    final bool value = open;
    if (_panelOpen == value) {
      return;
    }
    _panelOpen = value;
    notifyListeners();
  }

  void requireNetwork() {
    if (!_networkEnabled) {
      throw const SocketException('Network disabled by debug controls.');
    }
  }

  @override
  void dispose() {
    if (_slowAnimations) {
      timeDilation = 1;
    }
    feedback.dispose();
    performanceRecorder.dispose();
    unawaited(_networkChanges.close());
    super.dispose();
  }
}
