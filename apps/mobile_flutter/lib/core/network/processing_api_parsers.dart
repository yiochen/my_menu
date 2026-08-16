Map<String, Object?> apiMapValue(Map<String, Object?> data, String key) {
  final Object? value = data[key];
  if (value is Map<String, dynamic>) {
    return Map<String, Object?>.from(value);
  }
  if (value is Map<String, Object?>) return value;
  throw StateError('Expected JSON object at "$key".');
}

String apiStringValue(Map<String, Object?> data, String key) {
  final Object? value = data[key];
  if (value is String) return value;
  throw StateError('Expected string at "$key".');
}

int apiIntValue(Map<String, Object?> data, String key) {
  final Object? value = data[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.parse(value);
  throw StateError('Expected integer at "$key".');
}
