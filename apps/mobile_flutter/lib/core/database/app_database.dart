import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('DishRow')
class Dishes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get heroImageUrl => text()();
  TextColumn get category => text()();
  IntColumn get prepMinutes => integer()();
  TextColumn get difficulty => text()();
  IntColumn get madeCount => integer()();
  TextColumn get lastMadeLabel => text()();
  TextColumn get ingredientsJson => text()();
  TextColumn get recipeStepsJson => text()();
  TextColumn get notesJson => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('DishNoteRow')
class DishNotes extends Table {
  TextColumn get id => text()();
  TextColumn get dishId => text()();
  TextColumn get body => text()();
  IntColumn get position => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('SourcePhotoRow')
class SourcePhotos extends Table {
  TextColumn get id => text()();
  TextColumn get dishId => text()();
  TextColumn get url => text()();
  TextColumn get capturedLabel => text()();
  TextColumn get note => text().nullable()();
  TextColumn get confidenceLabel => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('CaptureItemRow')
class CaptureItems extends Table {
  TextColumn get id => text()();
  TextColumn get batchId => text().nullable()();
  IntColumn get ordinal => integer().withDefault(const Constant(0))();
  TextColumn get kind => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get localMediaRef => text().nullable()();
  TextColumn get remoteMediaRef => text().nullable()();
  TextColumn get ideaText => text().nullable()();
  TextColumn get appliedDishId => text().nullable()();
  TextColumn get failureReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('CaptureBatchRow')
class CaptureBatches extends Table {
  TextColumn get id => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get failureReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('PlannedMealRow')
class PlannedMeals extends Table {
  TextColumn get id => text()();
  TextColumn get dayKey => text()();
  TextColumn get dishId => text()();
  TextColumn get label => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('ReviewItemRow')
class ReviewItems extends Table {
  TextColumn get id => text()();
  TextColumn get summary => text()();
  TextColumn get suggestedDishIdsJson => text()();
  TextColumn get confidenceLabel => text()();
  TextColumn get imageRef => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('SyncOperationRow')
class SyncOperations extends Table {
  TextColumn get id => text()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get operationType => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('SyncMetadataRow')
class SyncMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

@DriftDatabase(
  tables: <Type>[
    Dishes,
    DishNotes,
    SourcePhotos,
    CaptureBatches,
    CaptureItems,
    PlannedMeals,
    ReviewItems,
    SyncOperations,
    SyncMetadata,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator migrator) => migrator.createAll(),
      onUpgrade: (Migrator migrator, int from, int to) async {
        if (from < 2) {
          await migrator.createTable(dishNotes);
          await migrator.createTable(syncMetadata);
          await _migrateJsonNotesToRows();
        }
        if (from < 3) {
          await migrator.createTable(captureBatches);
          await migrator.addColumn(captureItems, captureItems.batchId);
          await migrator.addColumn(captureItems, captureItems.ordinal);
          await migrator.addColumn(captureItems, captureItems.failureReason);
          await customStatement('''
            INSERT INTO capture_batches (
              id,
              status,
              created_at,
              updated_at,
              failure_reason
            )
            SELECT
              id,
              CASE status
                WHEN 'failed' THEN 'failed'
                WHEN 'applied' THEN 'applied'
                WHEN 'discarded' THEN 'discarded'
                WHEN 'classifying' THEN 'processing'
                ELSE 'pendingUpload'
              END,
              created_at,
              created_at,
              NULL
            FROM capture_items
          ''');
          await customStatement('UPDATE capture_items SET batch_id = id');
        }
      },
    );
  }

  Future<void> _migrateJsonNotesToRows() async {
    final List<DishRow> dishRows = await select(dishes).get();
    for (final DishRow dish in dishRows) {
      final Object? decoded = jsonDecode(dish.notesJson);
      if (decoded is! List<dynamic>) {
        continue;
      }
      for (int index = 0; index < decoded.length; index += 1) {
        final Object? value = decoded[index];
        if (value is! String || value.trim().isEmpty) {
          continue;
        }
        final DateTime now = DateTime.now();
        await into(dishNotes).insert(
          DishNotesCompanion.insert(
            id: '${dish.id}_note_$index',
            dishId: dish.id,
            body: value,
            position: index,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'mymenu');
}
