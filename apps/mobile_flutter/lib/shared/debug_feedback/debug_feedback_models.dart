import 'package:flutter/widgets.dart';

class DebugFeedbackCandidate {
  const DebugFeedbackCandidate({
    required this.element,
    required this.bounds,
    required this.snapshot,
    required this.explicit,
  });

  final Element element;
  final Rect bounds;
  final DebugFeedbackTargetSnapshot snapshot;
  final bool explicit;
}

@immutable
class DebugFeedbackTargetSnapshot {
  const DebugFeedbackTargetSnapshot({
    required this.label,
    required this.widgetType,
    required this.widgetPath,
    this.id,
    this.route,
    this.visibleText,
    this.semantics,
    this.sourceLocation,
  });

  factory DebugFeedbackTargetSnapshot.fromJson(Map<String, Object?> json) {
    return DebugFeedbackTargetSnapshot(
      id: json['id'] as String?,
      label: json['label']! as String,
      route: json['route'] as String?,
      widgetType: json['widgetType']! as String,
      widgetPath: (json['widgetPath']! as List<Object?>).cast<String>(),
      visibleText: json['visibleText'] as String?,
      semantics: json['semantics'] as String?,
      sourceLocation: json['sourceLocation'] as String?,
    );
  }

  final String? id;
  final String label;
  final String? route;
  final String widgetType;
  final List<String> widgetPath;
  final String? visibleText;
  final String? semantics;
  final String? sourceLocation;

  DebugFeedbackTargetSnapshot withSourceLocation(String? value) {
    return DebugFeedbackTargetSnapshot(
      id: id,
      label: label,
      route: route,
      widgetType: widgetType,
      widgetPath: widgetPath,
      visibleText: visibleText,
      semantics: semantics,
      sourceLocation: value,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'label': label,
      'route': route,
      'widgetType': widgetType,
      'widgetPath': widgetPath,
      'visibleText': visibleText,
      'semantics': semantics,
      'sourceLocation': sourceLocation,
    };
  }
}

@immutable
class DebugFeedbackEntry {
  const DebugFeedbackEntry({
    required this.target,
    required this.comment,
    required this.createdAt,
  });

  factory DebugFeedbackEntry.fromJson(Map<String, Object?> json) {
    return DebugFeedbackEntry(
      target: DebugFeedbackTargetSnapshot.fromJson(
        (json['target']! as Map<Object?, Object?>).cast<String, Object?>(),
      ),
      comment: json['comment']! as String,
      createdAt: DateTime.parse(json['createdAt']! as String),
    );
  }

  final DebugFeedbackTargetSnapshot target;
  final String comment;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'target': target.toJson(),
      'comment': comment,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}
