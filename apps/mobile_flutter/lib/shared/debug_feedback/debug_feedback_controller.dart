import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_models.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_prompt.dart';

typedef DebugFeedbackPersistCallback = Future<void> Function(
  List<DebugFeedbackEntry> entries,
);

class DebugFeedbackController extends ChangeNotifier {
  DebugFeedbackController({
    List<DebugFeedbackEntry> initialEntries = const <DebugFeedbackEntry>[],
    DebugFeedbackPersistCallback? persistEntries,
    DebugFeedbackPromptBuilder promptBuilder =
        const DebugFeedbackPromptBuilder(),
  })  : _entries = List<DebugFeedbackEntry>.of(initialEntries),
        _persistEntries = persistEntries,
        _promptBuilder = promptBuilder;

  final List<DebugFeedbackEntry> _entries;
  final DebugFeedbackPersistCallback? _persistEntries;
  final DebugFeedbackPromptBuilder _promptBuilder;
  Future<void> _persistenceTail = Future<void>.value();
  bool _collecting = false;

  List<DebugFeedbackEntry> get entries =>
      List<DebugFeedbackEntry>.unmodifiable(_entries);
  bool get collecting => _collecting;
  bool get hasEntries => _entries.isNotEmpty;

  void startCollecting() {
    if (_collecting) {
      return;
    }
    _collecting = true;
    notifyListeners();
  }

  void stopCollecting() {
    if (!_collecting) {
      return;
    }
    _collecting = false;
    notifyListeners();
  }

  void add({
    required DebugFeedbackTargetSnapshot target,
    required String comment,
    DateTime? createdAt,
  }) {
    final String normalizedComment = comment.trim();
    if (normalizedComment.isEmpty) {
      return;
    }
    _entries.add(
      DebugFeedbackEntry(
        target: target,
        comment: normalizedComment,
        createdAt: createdAt ?? DateTime.now(),
      ),
    );
    notifyListeners();
    _persist();
  }

  void clear() {
    if (_entries.isEmpty) {
      return;
    }
    _entries.clear();
    notifyListeners();
    _persist();
  }

  String buildAgentPrompt() => _promptBuilder.build(entries);

  void _persist() {
    final DebugFeedbackPersistCallback? callback = _persistEntries;
    if (callback != null) {
      final List<DebugFeedbackEntry> snapshot = entries;
      _persistenceTail = _persistenceTail.then((_) async {
        try {
          await callback(snapshot);
        } on Object catch (error, stackTrace) {
          debugPrint(
            'Debug feedback persistence failed: $error\n$stackTrace',
          );
        }
      });
      unawaited(_persistenceTail);
    }
  }
}
