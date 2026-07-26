import 'package:mymenu/core/network/my_menu_api_models.dart';

Map<String, Object?> apiMapValue(Map<String, Object?> data, String key) {
  final Object? value = data[key];
  if (value is Map<String, dynamic>) {
    return Map<String, Object?>.from(value);
  }
  if (value is Map<String, Object?>) {
    return value;
  }
  throw StateError('Expected JSON object at "$key".');
}

String apiStringValue(Map<String, Object?> data, String key) {
  final String? value = apiOptionalStringValue(data, key);
  if (value == null) {
    throw StateError('Expected string at "$key".');
  }
  return value;
}

String? apiOptionalStringValue(Map<String, Object?> data, String key) {
  final Object? value = data[key];
  return value is String ? value : null;
}

int apiIntValue(Map<String, Object?> data, String key) {
  final Object? value = data[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.parse(value);
  }
  throw StateError('Expected integer at "$key".');
}

bool apiBoolValue(Map<String, Object?> data, String key) {
  final Object? value = data[key];
  if (value is bool) {
    return value;
  }
  throw StateError('Expected boolean at "$key".');
}

List<Map<String, Object?>> apiListValue(
  Map<String, Object?> data,
  String key,
) {
  final Object? value = data[key];
  if (value is List<dynamic>) {
    return value
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> item) =>
              item.map((dynamic key, dynamic value) {
            return MapEntry<String, Object?>(key.toString(), value);
          }),
        )
        .toList(growable: false);
  }
  throw StateError('Expected list at "$key".');
}

ApiSyncEvent apiSyncEventFromJson(Map<String, Object?> data) {
  final Map<String, Object?> entityIds = apiMapValue(data, 'entityIds');
  return ApiSyncEvent(
    cursor: apiIntValue(data, 'cursor'),
    type: apiStringValue(data, 'type'),
    entityIds: entityIds.map((String key, Object? value) {
      return MapEntry<String, String>(key, value.toString());
    }),
  );
}

ApiCapture apiCaptureFromJson(Map<String, Object?> data) {
  final Map<String, Object?>? image = apiOptionalMapValue(data, 'image');
  return ApiCapture(
    id: apiStringValue(data, 'id'),
    kind: apiStringValue(data, 'kind'),
    status: apiStringValue(data, 'status'),
    capturedAt: DateTime.parse(apiStringValue(data, 'capturedAt')),
    batchId: apiOptionalStringValue(data, 'batchId'),
    ordinal: apiOptionalIntValue(data, 'ordinal'),
    ideaText: apiOptionalStringValue(data, 'ideaText'),
    appliedDishId: apiOptionalStringValue(data, 'appliedDishId'),
    failureReason: apiOptionalStringValue(data, 'failureReason'),
    image: image == null ? null : apiImageFromJson(image),
  );
}

ApiDish apiDishFromJson(Map<String, Object?> data) {
  final Map<String, Object?>? coverImage =
      apiOptionalMapValue(data, 'coverImage');
  return ApiDish(
    id: apiStringValue(data, 'id'),
    title: apiStringValue(data, 'title'),
    description: apiStringValue(data, 'description'),
    labels: apiStringListValue(data, 'labels'),
    prepMinutes: apiOptionalIntValue(data, 'prepMinutes'),
    difficulty: apiOptionalStringValue(data, 'difficulty'),
    isFavorite: apiBoolValue(data, 'isFavorite'),
    madeCount: apiIntValue(data, 'madeCount'),
    lastMadeAt: apiOptionalDateTimeValue(data, 'lastMadeAt'),
    coverImage: coverImage == null ? null : apiImageFromJson(coverImage),
    sourcePhotos: apiListValue(data, 'sourcePhotos')
        .map(apiSourcePhotoFromJson)
        .toList(growable: false),
    ingredients: apiStringListValue(data, 'ingredients'),
    steps: apiStringListValue(data, 'steps'),
    notes: apiStringListValue(data, 'notes'),
  );
}

ApiReviewItem apiReviewItemFromJson(Map<String, Object?> data) {
  return ApiReviewItem(
    id: apiStringValue(data, 'id'),
    captureId: apiStringValue(data, 'captureId'),
    status: apiStringValue(data, 'status'),
    summary: apiStringValue(data, 'summary'),
    suggestedDishIds: apiStringListValue(data, 'suggestedDishIds'),
    confidenceLabel: apiOptionalStringValue(data, 'confidenceLabel'),
  );
}

ApiImage apiImageFromJson(Map<String, Object?> data) {
  return ApiImage(
    id: apiStringValue(data, 'id'),
    kind: apiStringValue(data, 'kind'),
    mediaRef: apiStringValue(data, 'mediaRef'),
  );
}

ApiSourcePhoto apiSourcePhotoFromJson(Map<String, Object?> data) {
  return ApiSourcePhoto(
    id: apiStringValue(data, 'id'),
    mediaRef: apiStringValue(data, 'mediaRef'),
    capturedAt: apiOptionalDateTimeValue(data, 'capturedAt'),
    note: apiOptionalStringValue(data, 'note'),
    confidenceLabel: apiOptionalStringValue(data, 'confidenceLabel'),
  );
}

List<String> apiStringListValue(Map<String, Object?> data, String key) {
  final Object? value = data[key];
  if (value is List<dynamic>) {
    return value.whereType<String>().toList(growable: false);
  }
  return const <String>[];
}

Map<String, Object?>? apiOptionalMapValue(
  Map<String, Object?> data,
  String key,
) {
  final Object? value = data[key];
  if (value == null) {
    return null;
  }
  if (value is Map<String, dynamic>) {
    return Map<String, Object?>.from(value);
  }
  if (value is Map<String, Object?>) {
    return value;
  }
  throw StateError('Expected JSON object or null at "$key".');
}

int? apiOptionalIntValue(Map<String, Object?> data, String key) {
  final Object? value = data[key];
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.parse(value);
  }
  throw StateError('Expected integer or null at "$key".');
}

DateTime? apiOptionalDateTimeValue(Map<String, Object?> data, String key) {
  final String? value = apiOptionalStringValue(data, key);
  return value == null ? null : DateTime.parse(value);
}
