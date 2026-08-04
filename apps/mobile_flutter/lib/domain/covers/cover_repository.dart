import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/domain/covers/generated_cover.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/processing/processing_outbox_repository.dart';
import 'package:uuid/uuid.dart';

part 'cover_repository_selection.dart';

const String automaticCoversSettingKey = 'automatic_ai_covers_enabled';

class CoverRepository {
  CoverRepository(this._database);

  final db.AppDatabase _database;

  Future<bool> automaticGenerationEnabled() async {
    final db.LocalSettingRow? row = await (_database.select(
      _database.localSettings,
    )..where(
            (db.LocalSettings table) =>
                table.key.equals(automaticCoversSettingKey),
          ))
        .getSingleOrNull();
    return row?.value != 'false';
  }

  Future<void> setAutomaticGenerationEnabled({required bool enabled}) async {
    await _database.transaction(() async {
      await _database.into(_database.localSettings).insertOnConflictUpdate(
            db.LocalSettingsCompanion.insert(
              key: automaticCoversSettingKey,
              value: enabled.toString(),
            ),
          );
      if (!enabled) {
        await _database.customStatement(
          "UPDATE processing_outbox SET delivery_state = 'canceled', "
          'updated_at = ? WHERE request_kind = ? '
          r"AND json_extract(payload_json, '$.origin') = 'automatic' "
          "AND delivery_state NOT IN ('acknowledged', 'failed', 'expired', 'canceled')",
          <Object?>[
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
            ProcessingRequestKind.coverGeneration.databaseValue,
          ],
        );
      }
    });
  }

  Future<bool> enqueueAutomaticCover({
    required String dishId,
    required List<String> sourceIds,
    required DateTime now,
  }) async {
    if (!await automaticGenerationEnabled()) {
      return false;
    }
    final Map<String, Object?> payload = await _automaticPayload(
      dishId: dishId,
      sourceIds: sourceIds,
    );
    return ProcessingOutboxRepository(_database).enqueueCoverGeneration(
      requestId: const Uuid().v4(),
      dishId: dishId,
      payload: payload,
      now: now,
    );
  }

  Future<bool> restartAutomaticCoverIfPending({
    required String dishId,
    required DateTime now,
  }) async {
    final db.ProcessingOutboxRow? existing = await (_database.select(
      _database.processingOutbox,
    )..where(
            (db.ProcessingOutbox table) =>
                table.requestKind.equals(
                  ProcessingRequestKind.coverGeneration.databaseValue,
                ) &
                table.subjectId.equals(dishId),
          ))
        .getSingleOrNull();
    if (existing == null) return false;
    final Object? decoded = jsonDecode(existing.payloadJson);
    if (decoded is! Map<String, dynamic> ||
        decoded['origin'] != CoverOrigin.automatic.name ||
        <String>{'acknowledged', 'failed', 'expired', 'canceled'}
            .contains(existing.deliveryState)) {
      return false;
    }
    final List<String> sourceIds = await (_database.select(
      _database.sourcePhotos,
    )..where((db.SourcePhotos table) => table.dishId.equals(dishId)))
        .get()
        .then(
          (List<db.SourcePhotoRow> rows) =>
              rows.map((db.SourcePhotoRow row) => row.id).take(3).toList(),
        );
    final Map<String, Object?> payload = await _automaticPayload(
      dishId: dishId,
      sourceIds: sourceIds,
    );
    payload['restartAfterCancel'] = true;
    await (_database.update(_database.processingOutbox)
          ..where((db.ProcessingOutbox table) => table.id.equals(existing.id)))
        .write(
      db.ProcessingOutboxCompanion(
        payloadJson: Value<String>(jsonEncode(payload)),
        deliveryState: Value<String>(ProcessingDeliveryState.canceled.name),
        updatedAt: Value<DateTime>(now),
      ),
    );
    return true;
  }

  Future<Map<String, Object?>> _automaticPayload({
    required String dishId,
    required List<String> sourceIds,
  }) async {
    final db.DishRow dish = await (_database.select(_database.dishes)
          ..where((db.Dishes table) => table.id.equals(dishId)))
        .getSingle();
    final List<db.DishNoteRow> notes = await (_database.select(
      _database.dishNotes,
    )
          ..where(
            (db.DishNotes table) =>
                table.dishId.equals(dishId) & table.deletedAt.isNull(),
          )
          ..orderBy(<OrderingTerm Function(db.$DishNotesTable)>[
            (db.$DishNotesTable table) => OrderingTerm.asc(table.position),
            (db.$DishNotesTable table) => OrderingTerm.asc(table.createdAt),
          ]))
        .get();
    return <String, Object?>{
      'dishTitle': dish.title,
      'sourceIds': sourceIds.take(3).toList(growable: false),
      'notes': notes
          .map(
            (db.DishNoteRow note) => <String, Object?>{
              'body': note.body,
              'position': note.position,
            },
          )
          .toList(growable: false),
      'treatment': CoverTreatment.defaults.toJson(),
      'origin': CoverOrigin.automatic.name,
      'contractVersion': 'cover-generation-v1',
      'coverSnapshot': <String, Object?>{
        'image': dish.heroImageUrl,
        'preview': dish.heroPreviewUrl,
        'thumbnail': dish.heroThumbnailUrl,
        'placeholder': dish.heroPlaceholderUrl,
      },
    };
  }

  Future<List<GeneratedCover>> listForDish(String dishId) async {
    final List<db.GeneratedCoverRow> rows = await (_database.select(
      _database.generatedCovers,
    )
          ..where((db.GeneratedCovers table) => table.dishId.equals(dishId))
          ..orderBy(<OrderingTerm Function(db.$GeneratedCoversTable)>[
            (db.$GeneratedCoversTable table) =>
                OrderingTerm.desc(table.createdAt),
          ]))
        .get();
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<List<GeneratedCover>> listAll() async {
    final List<db.GeneratedCoverRow> rows = await (_database.select(
      _database.generatedCovers,
    )..orderBy(<OrderingTerm Function(db.$GeneratedCoversTable)>[
            (db.$GeneratedCoversTable table) =>
                OrderingTerm.desc(table.createdAt),
          ]))
        .get();
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<void> storeDeliveredCover({
    required String id,
    required String dishId,
    required String localPath,
    required CoverOrigin origin,
    required CoverGrounding grounding,
    required List<String> selectedSourceIds,
    required CoverTreatment treatment,
    required String proposalId,
    required DateTime createdAt,
    String contractVersion = 'cover-generation-v1',
    String? previewPath,
    String? thumbnailPath,
    String? placeholderPath,
  }) async {
    await _database.transaction(() async {
      String? previousCoverJson;
      if (origin == CoverOrigin.manual) {
        await (_database.update(_database.generatedCovers)
              ..where(
                (db.GeneratedCovers table) =>
                    table.dishId.equals(dishId) &
                    table.state.equals(GeneratedCoverState.proposed.name),
              ))
            .write(
          const db.GeneratedCoversCompanion(
            state: Value<String>('history'),
          ),
        );
      } else {
        final db.DishRow dish = await (_database.select(_database.dishes)
              ..where((db.Dishes table) => table.id.equals(dishId)))
            .getSingle();
        previousCoverJson = jsonEncode(<String, Object?>{
          'image': dish.heroImageUrl,
          'preview': dish.heroPreviewUrl,
          'thumbnail': dish.heroThumbnailUrl,
          'placeholder': dish.heroPlaceholderUrl,
        });
        await (_database.update(_database.generatedCovers)
              ..where(
                (db.GeneratedCovers table) =>
                    table.dishId.equals(dishId) &
                    table.state.equals(GeneratedCoverState.current.name),
              ))
            .write(
          db.GeneratedCoversCompanion(
            state: Value<String>(GeneratedCoverState.history.name),
            automaticUndoAvailable: const Value<bool>(false),
          ),
        );
      }
      await _database.into(_database.generatedCovers).insertOnConflictUpdate(
            db.GeneratedCoversCompanion.insert(
              id: id,
              dishId: dishId,
              localPath: localPath,
              previewPath: Value<String?>(previewPath),
              thumbnailPath: Value<String?>(thumbnailPath),
              placeholderPath: Value<String?>(placeholderPath),
              origin: origin.name,
              grounding: grounding.name,
              selectedSourceIdsJson: jsonEncode(selectedSourceIds),
              look: treatment.look.apiValue,
              view: treatment.view.apiValue,
              finish: treatment.finish.apiValue,
              contractVersion: contractVersion,
              proposalId: proposalId,
              state: origin == CoverOrigin.manual
                  ? GeneratedCoverState.proposed.name
                  : GeneratedCoverState.current.name,
              automaticUndoAvailable:
                  Value<bool>(origin == CoverOrigin.automatic),
              previousCoverJson: Value<String?>(previousCoverJson),
              createdAt: createdAt,
            ),
          );
      if (origin == CoverOrigin.automatic) {
        await (_database.update(_database.dishes)
              ..where((db.Dishes table) => table.id.equals(dishId)))
            .write(
          db.DishesCompanion(
            heroImageUrl: Value<String>(localPath),
            heroPreviewUrl: Value<String?>(previewPath),
            heroThumbnailUrl: Value<String?>(thumbnailPath),
            heroPlaceholderUrl: Value<String?>(placeholderPath),
          ),
        );
      }
    });
  }

  Future<void> undoAutomatic(String coverId) async {
    await _database.transaction(() async {
      final db.GeneratedCoverRow cover = await (_database.select(
        _database.generatedCovers,
      )..where((db.GeneratedCovers table) => table.id.equals(coverId)))
          .getSingle();
      if (!cover.automaticUndoAvailable ||
          cover.state != GeneratedCoverState.current.name ||
          cover.previousCoverJson == null) {
        return;
      }
      final Object? decoded = jsonDecode(cover.previousCoverJson!);
      final Map<String, Object?> previous = decoded is Map<String, dynamic>
          ? Map<String, Object?>.from(decoded)
          : const <String, Object?>{};
      await (_database.update(_database.dishes)
            ..where((db.Dishes table) => table.id.equals(cover.dishId)))
          .write(
        db.DishesCompanion(
          heroImageUrl: Value<String>((previous['image'] as String?) ?? ''),
          heroPreviewUrl: Value<String?>(previous['preview'] as String?),
          heroThumbnailUrl: Value<String?>(previous['thumbnail'] as String?),
          heroPlaceholderUrl:
              Value<String?>(previous['placeholder'] as String?),
        ),
      );
      await (_database.update(_database.generatedCovers)
            ..where((db.GeneratedCovers table) => table.id.equals(coverId)))
          .write(
        db.GeneratedCoversCompanion(
          state: Value<String>(GeneratedCoverState.history.name),
          automaticUndoAvailable: const Value<bool>(false),
        ),
      );
    });
  }

  Future<void> acceptProposal(String coverId) async {
    await _database.transaction(() async {
      final db.GeneratedCoverRow cover = await (_database.select(
        _database.generatedCovers,
      )..where((db.GeneratedCovers table) => table.id.equals(coverId)))
          .getSingle();
      if (cover.state != GeneratedCoverState.proposed.name) {
        return;
      }
      await (_database.update(_database.generatedCovers)
            ..where(
              (db.GeneratedCovers table) =>
                  table.dishId.equals(cover.dishId) &
                  table.state.equals(GeneratedCoverState.current.name),
            ))
          .write(
        db.GeneratedCoversCompanion(
          state: Value<String>(GeneratedCoverState.history.name),
        ),
      );
      await (_database.update(_database.generatedCovers)
            ..where((db.GeneratedCovers table) => table.id.equals(coverId)))
          .write(
        db.GeneratedCoversCompanion(
          state: Value<String>(GeneratedCoverState.current.name),
        ),
      );
      await (_database.update(_database.dishes)
            ..where((db.Dishes table) => table.id.equals(cover.dishId)))
          .write(
        db.DishesCompanion(
          heroImageUrl: Value<String>(cover.localPath),
          heroPreviewUrl: Value<String?>(cover.previewPath),
          heroThumbnailUrl: Value<String?>(cover.thumbnailPath),
          heroPlaceholderUrl: Value<String?>(cover.placeholderPath),
        ),
      );
    });
  }

  Future<void> keepCurrent(String coverId) =>
      CoverRepositorySelection(this).keepCurrent(coverId);
  Future<void> selectGenerated(String coverId) =>
      CoverRepositorySelection(this).selectGenerated(coverId);
  Future<void> selectSource(String dishId, String sourceId) =>
      CoverRepositorySelection(this).selectSource(dishId, sourceId);
  Future<void> acknowledgeAutomatic(String coverId) =>
      CoverRepositorySelection(this).acknowledgeAutomatic(coverId);
  Future<void> deleteGenerated(String coverId) =>
      CoverRepositorySelection(this).deleteGenerated(coverId);
}
