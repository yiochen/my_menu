import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/network/my_menu_api_parsers.dart';

void main() {
  group('apiMapValue', () {
    test('extracts a nested Map<String, dynamic>', () {
      final Map<String, Object?> data = <String, Object?>{
        'nested': <String, dynamic>{'key': 'value'},
      };
      final Map<String, Object?> result = apiMapValue(data, 'nested');

      expect(result['key'], 'value');
    });

    test('extracts a nested Map<String, Object?>', () {
      final Map<String, Object?> data = <String, Object?>{
        'nested': <String, Object?>{'count': 42},
      };

      expect(apiMapValue(data, 'nested')['count'], 42);
    });

    test('throws when key is missing', () {
      expect(
        () => apiMapValue(<String, Object?>{}, 'missing'),
        throwsStateError,
      );
    });

    test('throws when value is not a map', () {
      expect(
        () => apiMapValue(<String, Object?>{'key': 'string'}, 'key'),
        throwsStateError,
      );
    });
  });

  group('apiStringValue', () {
    test('returns a string value', () {
      expect(
        apiStringValue(<String, Object?>{'name': 'Alice'}, 'name'),
        'Alice',
      );
    });

    test('throws when key is missing', () {
      expect(
        () => apiStringValue(<String, Object?>{}, 'name'),
        throwsStateError,
      );
    });

    test('throws when value is not a string', () {
      expect(
        () => apiStringValue(<String, Object?>{'name': 123}, 'name'),
        throwsStateError,
      );
    });
  });

  group('apiOptionalStringValue', () {
    test('returns string when present', () {
      expect(
        apiOptionalStringValue(<String, Object?>{'k': 'v'}, 'k'),
        'v',
      );
    });

    test('returns null when key is absent', () {
      expect(
        apiOptionalStringValue(<String, Object?>{}, 'k'),
        isNull,
      );
    });

    test('returns null when value is not a string', () {
      expect(
        apiOptionalStringValue(<String, Object?>{'k': 99}, 'k'),
        isNull,
      );
    });
  });

  group('apiIntValue', () {
    test('returns an int directly', () {
      expect(apiIntValue(<String, Object?>{'n': 7}, 'n'), 7);
    });

    test('converts a double to int', () {
      expect(apiIntValue(<String, Object?>{'n': 3.9}, 'n'), 3);
    });

    test('parses a string to int', () {
      expect(apiIntValue(<String, Object?>{'n': '42'}, 'n'), 42);
    });

    test('throws when value is not numeric', () {
      expect(
        () => apiIntValue(<String, Object?>{'n': true}, 'n'),
        throwsStateError,
      );
    });
  });

  group('apiBoolValue', () {
    test('returns a bool directly', () {
      expect(apiBoolValue(<String, Object?>{'b': true}, 'b'), isTrue);
      expect(apiBoolValue(<String, Object?>{'b': false}, 'b'), isFalse);
    });

    test('throws when value is not a bool', () {
      expect(
        () => apiBoolValue(<String, Object?>{'b': 'yes'}, 'b'),
        throwsStateError,
      );
    });
  });

  group('apiListValue', () {
    test('converts a list of maps', () {
      final Map<String, Object?> data = <String, Object?>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{'id': '1'},
          <String, dynamic>{'id': '2'},
        ],
      };

      final List<Map<String, Object?>> result = apiListValue(data, 'items');

      expect(result.length, 2);
      expect(result[0]['id'], '1');
      expect(result[1]['id'], '2');
    });

    test('filters out non-map elements', () {
      final Map<String, Object?> data = <String, Object?>{
        'items': <Object?>['not_a_map', <String, dynamic>{'id': 'ok'}],
      };

      final List<Map<String, Object?>> result = apiListValue(data, 'items');

      expect(result.length, 1);
      expect(result.single['id'], 'ok');
    });

    test('throws when value is not a list', () {
      expect(
        () => apiListValue(<String, Object?>{'items': 'nope'}, 'items'),
        throwsStateError,
      );
    });
  });

  group('apiStringListValue', () {
    test('extracts a list of strings', () {
      final List<String> result = apiStringListValue(
        <String, Object?>{
          'tags': <Object?>['a', 'b', 'c'],
        },
        'tags',
      );

      expect(result, <String>['a', 'b', 'c']);
    });

    test('filters out non-string elements', () {
      final List<String> result = apiStringListValue(
        <String, Object?>{
          'tags': <Object?>['valid', 42, null, 'also_valid'],
        },
        'tags',
      );

      expect(result, <String>['valid', 'also_valid']);
    });

    test('returns empty list when key is absent', () {
      expect(
        apiStringListValue(<String, Object?>{}, 'tags'),
        isEmpty,
      );
    });

    test('returns empty list when value is not a list', () {
      expect(
        apiStringListValue(<String, Object?>{'tags': 'nope'}, 'tags'),
        isEmpty,
      );
    });
  });

  group('apiOptionalMapValue', () {
    test('returns map when present', () {
      final Map<String, Object?>? result = apiOptionalMapValue(
        <String, Object?>{
          'meta': <String, dynamic>{'v': 1},
        },
        'meta',
      );

      expect(result, isNotNull);
      expect(result!['v'], 1);
    });

    test('returns null when value is null', () {
      expect(
        apiOptionalMapValue(<String, Object?>{'meta': null}, 'meta'),
        isNull,
      );
    });

    test('returns null when key is absent', () {
      expect(
        apiOptionalMapValue(<String, Object?>{}, 'meta'),
        isNull,
      );
    });

    test('throws when value is present but not a map or null', () {
      expect(
        () => apiOptionalMapValue(<String, Object?>{'meta': 'bad'}, 'meta'),
        throwsStateError,
      );
    });
  });

  group('apiOptionalIntValue', () {
    test('returns int when present', () {
      expect(
        apiOptionalIntValue(<String, Object?>{'n': 5}, 'n'),
        5,
      );
    });

    test('converts double to int', () {
      expect(
        apiOptionalIntValue(<String, Object?>{'n': 2.7}, 'n'),
        2,
      );
    });

    test('parses string to int', () {
      expect(
        apiOptionalIntValue(<String, Object?>{'n': '10'}, 'n'),
        10,
      );
    });

    test('returns null when value is null', () {
      expect(
        apiOptionalIntValue(<String, Object?>{'n': null}, 'n'),
        isNull,
      );
    });

    test('returns null when key is absent', () {
      expect(
        apiOptionalIntValue(<String, Object?>{}, 'n'),
        isNull,
      );
    });

    test('throws when value is a non-numeric type', () {
      expect(
        () => apiOptionalIntValue(<String, Object?>{'n': true}, 'n'),
        throwsStateError,
      );
    });
  });

  group('apiOptionalDateTimeValue', () {
    test('parses an ISO 8601 date string', () {
      final DateTime? result = apiOptionalDateTimeValue(
        <String, Object?>{'at': '2026-06-15T12:00:00Z'},
        'at',
      );

      expect(result, DateTime.utc(2026, 6, 15, 12));
    });

    test('returns null when value is absent', () {
      expect(
        apiOptionalDateTimeValue(<String, Object?>{}, 'at'),
        isNull,
      );
    });

    test('returns null when value is null', () {
      expect(
        apiOptionalDateTimeValue(<String, Object?>{'at': null}, 'at'),
        isNull,
      );
    });
  });

  group('apiSyncEventFromJson', () {
    test('parses a sync event with entity IDs', () {
      final result = apiSyncEventFromJson(<String, Object?>{
        'cursor': 42,
        'type': 'capture.applied_to_new_dish',
        'entityIds': <String, dynamic>{
          'captureId': 'cap_1',
          'dishId': 'dish_1',
        },
      });

      expect(result.cursor, 42);
      expect(result.type, 'capture.applied_to_new_dish');
      expect(result.entityIds['captureId'], 'cap_1');
      expect(result.entityIds['dishId'], 'dish_1');
    });
  });

  group('apiCaptureFromJson', () {
    test('parses a capture with an image', () {
      final result = apiCaptureFromJson(<String, Object?>{
        'id': 'cap_1',
        'kind': 'photo',
        'status': 'applied',
        'capturedAt': '2026-06-15T10:00:00Z',
        'appliedDishId': 'dish_1',
        'image': <String, dynamic>{
          'id': 'img_1',
          'kind': 'source_photo',
          'mediaRef': 'https://example.com/photo.jpg',
        },
      });

      expect(result.id, 'cap_1');
      expect(result.kind, 'photo');
      expect(result.status, 'applied');
      expect(result.capturedAt, DateTime.utc(2026, 6, 15, 10));
      expect(result.appliedDishId, 'dish_1');
      expect(result.image, isNotNull);
      expect(result.image!.mediaRef, 'https://example.com/photo.jpg');
    });

    test('parses a capture without an image', () {
      final result = apiCaptureFromJson(<String, Object?>{
        'id': 'cap_2',
        'kind': 'idea',
        'status': 'classifying',
        'capturedAt': '2026-06-15T10:00:00Z',
        'ideaText': 'crispy tofu',
      });

      expect(result.id, 'cap_2');
      expect(result.image, isNull);
      expect(result.ideaText, 'crispy tofu');
    });
  });

  group('apiDishFromJson', () {
    test('parses a full dish', () {
      final result = apiDishFromJson(<String, Object?>{
        'id': 'dish_1',
        'title': 'Test Dish',
        'description': 'Tasty.',
        'labels': <Object?>['pasta', 'quick'],
        'prepMinutes': 20,
        'difficulty': 'Easy',
        'isFavorite': true,
        'madeCount': 5,
        'lastMadeAt': '2026-06-10T12:00:00Z',
        'coverImage': <String, dynamic>{
          'id': 'cover_1',
          'kind': 'cover',
          'mediaRef': 'https://example.com/cover.jpg',
        },
        'sourcePhotos': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'sp_1',
            'mediaRef': 'https://example.com/sp1.jpg',
            'capturedAt': '2026-06-10T12:00:00Z',
            'confidenceLabel': '92%',
          },
        ],
        'ingredients': <Object?>['flour', 'eggs'],
        'steps': <Object?>['Mix.', 'Bake.'],
        'notes': <Object?>['Delicious.'],
      });

      expect(result.id, 'dish_1');
      expect(result.title, 'Test Dish');
      expect(result.isFavorite, isTrue);
      expect(result.madeCount, 5);
      expect(result.coverImage, isNotNull);
      expect(result.sourcePhotos.length, 1);
      expect(result.sourcePhotos.first.confidenceLabel, '92%');
      expect(result.ingredients, <String>['flour', 'eggs']);
      expect(result.steps, <String>['Mix.', 'Bake.']);
    });
  });

  group('apiReviewItemFromJson', () {
    test('parses a review item', () {
      final result = apiReviewItemFromJson(<String, Object?>{
        'id': 'review_1',
        'captureId': 'cap_1',
        'status': 'pending',
        'summary': 'Possible pho capture.',
        'suggestedDishIds': <Object?>['dish_pho'],
        'confidenceLabel': '54%',
      });

      expect(result.id, 'review_1');
      expect(result.captureId, 'cap_1');
      expect(result.summary, 'Possible pho capture.');
      expect(result.suggestedDishIds, <String>['dish_pho']);
      expect(result.confidenceLabel, '54%');
    });

    test('handles missing confidenceLabel', () {
      final result = apiReviewItemFromJson(<String, Object?>{
        'id': 'review_2',
        'captureId': 'cap_2',
        'status': 'pending',
        'summary': 'A capture.',
        'suggestedDishIds': <Object?>[],
      });

      expect(result.confidenceLabel, isNull);
    });
  });

  group('apiImageFromJson', () {
    test('parses an image object', () {
      final result = apiImageFromJson(<String, Object?>{
        'id': 'img_1',
        'kind': 'source_photo',
        'mediaRef': 'https://example.com/img.jpg',
      });

      expect(result.id, 'img_1');
      expect(result.kind, 'source_photo');
      expect(result.mediaRef, 'https://example.com/img.jpg');
    });
  });

  group('apiSourcePhotoFromJson', () {
    test('parses a source photo with all fields', () {
      final result = apiSourcePhotoFromJson(<String, Object?>{
        'id': 'sp_1',
        'mediaRef': 'https://example.com/sp.jpg',
        'capturedAt': '2026-06-15T08:00:00Z',
        'note': 'Extra garlic.',
        'confidenceLabel': '88%',
      });

      expect(result.id, 'sp_1');
      expect(result.mediaRef, 'https://example.com/sp.jpg');
      expect(result.capturedAt, DateTime.utc(2026, 6, 15, 8));
      expect(result.note, 'Extra garlic.');
      expect(result.confidenceLabel, '88%');
    });

    test('handles missing optional fields', () {
      final result = apiSourcePhotoFromJson(<String, Object?>{
        'id': 'sp_2',
        'mediaRef': 'https://example.com/sp2.jpg',
      });

      expect(result.capturedAt, isNull);
      expect(result.note, isNull);
      expect(result.confidenceLabel, isNull);
    });
  });
}
