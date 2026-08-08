import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:mymenu/core/database/app_database.dart' as db;
import 'package:mymenu/domain/covers/generated_cover.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/processing/processing_outbox_repository.dart';
import 'package:uuid/uuid.dart';

part 'cover_repository_selection.dart';
part 'cover_repository_automatic.dart';

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
          r"payload_json = json_remove(payload_json, '$.restartAfterCancel'), "
          'updated_at = ? WHERE request_kind = ? '
          r"AND json_extract(payload_json, '$.origin') = 'automatic' "
          "AND delivery_state NOT IN ('acknowledged', 'failed', 'expired')",
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
    final List<String> usableSourceIds = await _usableAutomaticSourceIds(
      dishId: dishId,
      sourceIds: sourceIds,
    );
    if (sourceIds.isNotEmpty && usableSourceIds.isEmpty) {
      return false;
    }
    final Map<String, Object?> payload = await _automaticPayload(
      dishId: dishId,
      sourceIds: usableSourceIds,
    );
    return ProcessingOutboxRepository(_database).enqueueCoverGeneration(
      requestId: const Uuid().v4(),
      dishId: dishId,
      payload: payload,
      now: now,
    );
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

  Future<GeneratedCover?> findById(String coverId) async {
    final db.GeneratedCoverRow? row = await (_database.select(
      _database.generatedCovers,
    )..where((db.GeneratedCovers table) => table.id.equals(coverId)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
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
      final db.GeneratedCoverRow? existing = await (_database.select(
        _database.generatedCovers,
      )..where((db.GeneratedCovers table) => table.id.equals(id)))
          .getSingleOrNull();
      if (existing != null) return;
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
