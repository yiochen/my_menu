import 'dart:convert';

import 'package:mymenu/core/debug/debug_controls.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesDebugControls implements DebugControlsPersistence {
  SharedPreferencesDebugControls._(this._preferences);

  static const String _networkEnabledKey = 'debug_controls.network_enabled';
  static const String _slowAnimationsKey = 'debug_controls.slow_animations';
  static const String _cameraAccessEnabledKey =
      'debug_controls.camera_access_enabled';
  static const String _feedbackEntriesKey = 'debug_controls.feedback_entries';

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
      feedbackEntries: _readFeedbackEntries(),
    );
  }

  List<DebugFeedbackEntry> _readFeedbackEntries() {
    final String? encoded = _preferences.getString(_feedbackEntriesKey);
    if (encoded == null) {
      return const <DebugFeedbackEntry>[];
    }
    try {
      final Object? decoded = jsonDecode(encoded);
      if (decoded is! List<Object?>) {
        return const <DebugFeedbackEntry>[];
      }
      return decoded
          .whereType<Map<Object?, Object?>>()
          .map(
            (Map<Object?, Object?> value) => DebugFeedbackEntry.fromJson(
              value.cast<String, Object?>(),
            ),
          )
          .toList(growable: false);
    } on Object {
      return const <DebugFeedbackEntry>[];
    }
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

  @override
  Future<void> setFeedbackEntries(List<DebugFeedbackEntry> entries) {
    return _preferences.setString(
      _feedbackEntriesKey,
      jsonEncode(
        entries
            .map((DebugFeedbackEntry entry) => entry.toJson())
            .toList(growable: false),
      ),
    );
  }
}
