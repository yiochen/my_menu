import 'package:mymenu/core/debug/debug_controls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesDebugControls implements DebugControlsPersistence {
  SharedPreferencesDebugControls._(this._preferences);

  static const String _networkEnabledKey = 'debug_controls.network_enabled';
  static const String _slowAnimationsKey = 'debug_controls.slow_animations';
  static const String _cameraAccessEnabledKey =
      'debug_controls.camera_access_enabled';

  final SharedPreferences _preferences;

  static Future<SharedPreferencesDebugControls> load() async {
    return SharedPreferencesDebugControls._(
      await SharedPreferences.getInstance(),
    );
  }

  DebugControlsSettings get settings {
    return DebugControlsSettings(
      networkEnabled: _preferences.getBool(_networkEnabledKey) ?? true,
      slowAnimations: _preferences.getBool(_slowAnimationsKey) ?? false,
      cameraAccessEnabled:
          _preferences.getBool(_cameraAccessEnabledKey) ?? true,
    );
  }

  @override
  Future<void> setNetworkEnabled({required bool enabled}) {
    return _preferences.setBool(_networkEnabledKey, enabled);
  }

  @override
  Future<void> setSlowAnimations({required bool enabled}) {
    return _preferences.setBool(_slowAnimationsKey, enabled);
  }

  @override
  Future<void> setCameraAccessEnabled({required bool enabled}) {
    return _preferences.setBool(_cameraAccessEnabledKey, enabled);
  }
}
