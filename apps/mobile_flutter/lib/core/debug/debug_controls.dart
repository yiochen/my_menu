import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';

class DebugControlsSettings {
  const DebugControlsSettings({
    this.networkEnabled = true,
    this.slowAnimations = false,
    this.cameraAccessEnabled = true,
  });

  final bool networkEnabled;
  final bool slowAnimations;
  final bool cameraAccessEnabled;
}

abstract interface class DebugControlsPersistence {
  Future<void> setNetworkEnabled({required bool enabled});

  Future<void> setSlowAnimations({required bool enabled});

  Future<void> setCameraAccessEnabled({required bool enabled});
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
  })  : _networkEnabled = initialSettings.networkEnabled,
        _slowAnimations = initialSettings.slowAnimations,
        _cameraAccessEnabled = initialSettings.cameraAccessEnabled,
        _persistence = persistence {
    if (_slowAnimations) {
      timeDilation = 5;
    }
  }

  final StreamController<void> _networkChanges =
      StreamController<void>.broadcast();
  final DebugControlsPersistence? _persistence;

  bool _networkEnabled;
  bool _slowAnimations;
  bool _cameraAccessEnabled;
  bool _panelOpen = false;

  bool get networkEnabled => _networkEnabled;
  bool get slowAnimations => _slowAnimations;
  bool get cameraAccessEnabled => _cameraAccessEnabled;
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
    unawaited(_networkChanges.close());
    super.dispose();
  }
}
