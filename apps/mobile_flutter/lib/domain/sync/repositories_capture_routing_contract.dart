part of 'repositories.dart';

extension SyncRepositoryCaptureRoutingContract on SyncRepository {
  Future<Map<String, Object?>> _captureGroupingInput(
    List<db.CaptureItemRow> captures,
  ) async {
    final List<db.DishRow> dishes =
        await _database.select(_database.dishes).get();
    final List<db.DishNoteRow> notes =
        await _database.select(_database.dishNotes).get();
    return <String, Object?>{
      'captures': captures
          .map(
            (db.CaptureItemRow capture) => <String, Object?>{
              'id': capture.id,
              'kind': capture.kind,
              'ordinal': capture.ordinal,
              'capturedAt': capture.capturedAt?.toUtc().toIso8601String(),
              'capturedLocalDate': capture.capturedLocalDate,
              'ideaText': capture.ideaText,
              if (capture.kind == capture_domain.CaptureItemKind.photo.name)
                'assetId': capture.id,
            },
          )
          .toList(growable: false),
      'dishes': dishes
          .map(
            (db.DishRow dish) => <String, Object?>{
              'localId': dish.id,
              'title': dish.title,
              'description': dish.description,
              'ingredients': _jsonStringList(dish.ingredientsJson),
              'recipeSteps': _jsonStringList(dish.recipeStepsJson),
              'notes': notes
                  .where((db.DishNoteRow note) => note.dishId == dish.id)
                  .map((db.DishNoteRow note) => note.body)
                  .toList(growable: false),
            },
          )
          .toList(growable: false),
    };
  }

  void _validateCaptureGroupingResult(
    ProcessingOutboxRequest request,
    Map<String, Object?> result, {
    required String schemaVersion,
  }) {
    if (result['operation'] != request.kind.databaseValue ||
        result['schemaVersion'] != schemaVersion ||
        schemaVersion != 'capture-grouping-result-v2' ||
        result['decisions'] is! List<Object?>) {
      throw const FormatException('Invalid capture grouping proposal.');
    }
    final Set<String> expected =
        (request.payload['captureIds']! as List<Object?>)
            .whereType<String>()
            .toSet();
    final List<String> decisions = <String>[];
    final Set<String> submittedDishIds =
        (request.payload['submittedDishIds'] as List<Object?>? ??
                const <Object?>[])
            .whereType<String>()
            .toSet();
    for (final Object? value in result['decisions']! as List<Object?>) {
      if (value is! Map<dynamic, dynamic>) {
        throw const FormatException('Invalid routing decision.');
      }
      final Map<String, Object?> decision = Map<String, Object?>.from(value);
      final Object? rawIds = decision['captureIds'];
      final Object? rawOutcome = decision['outcome'];
      final Object? rawEvidence = decision['evidence'];
      final Object? rawUncertainty = decision['uncertainty'];
      if (rawIds is! List<Object?> ||
          rawOutcome is! Map<String, Object?> ||
          rawEvidence is! List<Object?> ||
          rawUncertainty is! List<Object?> ||
          rawEvidence.whereType<String>().length != rawEvidence.length ||
          rawEvidence.isEmpty ||
          rawUncertainty.whereType<String>().length != rawUncertainty.length) {
        throw const FormatException('Invalid routing decision fields.');
      }
      final List<String> ids = rawIds.whereType<String>().toList();
      final String? type = rawOutcome['type'] as String?;
      if (ids.length != rawIds.length || ids.isEmpty) {
        throw const FormatException('Invalid routing capture references.');
      }
      if (type == 'existing_dish') {
        final String? dishId = rawOutcome['localDishId'] as String?;
        if (dishId == null ||
            !submittedDishIds.contains(dishId) ||
            rawOutcome['draft'] != null ||
            rawUncertainty.isNotEmpty) {
          throw const FormatException('Invalid existing-dish route.');
        }
      } else if (type == 'new_dish') {
        final Object? draft = rawOutcome['draft'];
        if (draft is! Map<String, Object?> ||
            draft['title'] is! String ||
            (draft['title']! as String).trim().isEmpty ||
            rawOutcome['localDishId'] != null ||
            rawUncertainty.isNotEmpty) {
          throw const FormatException('Invalid new-dish route.');
        }
      } else if (type == 'unresolved') {
        if (ids.length != 1 || rawUncertainty.isEmpty) {
          throw const FormatException('Invalid unresolved route.');
        }
      } else if (type == 'not_a_dish') {
        if (ids.length != 1 || rawUncertainty.isNotEmpty) {
          throw const FormatException('Invalid not-a-dish route.');
        }
      } else {
        throw const FormatException('Unknown routing outcome.');
      }
      decisions.addAll(ids);
    }
    if (decisions.length != decisions.toSet().length ||
        decisions.toSet().difference(expected).isNotEmpty ||
        expected.difference(decisions.toSet()).isNotEmpty) {
      throw const FormatException(
        'Capture grouping proposal must exactly partition the input.',
      );
    }
  }
}
