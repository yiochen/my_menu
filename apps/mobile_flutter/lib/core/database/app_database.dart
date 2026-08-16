import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:mymenu/core/database/app_database_covers.dart';
import 'package:mymenu/core/database/app_database_local.dart';
import 'package:mymenu/core/database/app_database_processing.dart';
export 'package:mymenu/core/database/app_database_covers.dart';
export 'package:mymenu/core/database/app_database_local.dart';
export 'package:mymenu/core/database/app_database_processing.dart';

part 'app_database.g.dart';
part 'app_database_migrations.dart';

@DataClassName('DishRow')
class Dishes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get heroImageUrl => text()();
  TextColumn get heroPreviewUrl => text().nullable()();
  TextColumn get heroThumbnailUrl => text().nullable()();
  TextColumn get heroPlaceholderUrl => text().nullable()();
  TextColumn get category => text()();
  IntColumn get prepMinutes => integer()();
  TextColumn get difficulty => text()();
  IntColumn get madeCount => integer()();
  TextColumn get lastMadeLabel => text()();
  TextColumn get ingredientsJson => text()();
  TextColumn get recipeStepsJson => text()();
  TextColumn get notesJson => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get openedAt => dateTime().nullable()();

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
  TextColumn get previewUrl => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get placeholderUrl => text().nullable()();
  TextColumn get capturedLabel => text()();
  TextColumn get confidenceLabel => text().nullable()();
  TextColumn get captureId => text().nullable()();
  TextColumn get cookingOccasionId => text().nullable()();
  DateTimeColumn get capturedAt => dateTime().nullable()();

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
  TextColumn get localPreviewRef => text().nullable()();
  TextColumn get localThumbnailRef => text().nullable()();
  TextColumn get localPlaceholderRef => text().nullable()();
  TextColumn get remoteMediaRef => text().nullable()();
  TextColumn get ideaText => text().nullable()();
  DateTimeColumn get capturedAt => dateTime().nullable()();
  TextColumn get capturedLocalDate => text().nullable()();
  TextColumn get captureDateSource => text().nullable()();
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

@DataClassName('CaptureCorrectionRow')
class CaptureCorrections extends Table {
  TextColumn get id => text()();
  TextColumn get batchId => text()();
  TextColumn get actionType => text()();
  TextColumn get captureIdsJson => text()();
  TextColumn get previousDishIdsJson => text()();
  TextColumn get targetDishId => text()();
  TextColumn get createdDishId => text().nullable()();
  TextColumn get status => text()();
  TextColumn get error => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get undoneAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('ReviewItemRow')
class ReviewItems extends Table {
  TextColumn get id => text()();
  TextColumn get captureId => text().nullable()();
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

@DataClassName('AiJobRow')
class AiJobs extends Table {
  TextColumn get id => text()();
  TextColumn get jobType => text()();
  TextColumn get subjectId => text()();
  TextColumn get status => text()();
  TextColumn get idempotencyKey => text()();
  TextColumn get inputHash => text()();
  TextColumn get inputVersion => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  IntColumn get maxAttempts => integer().withDefault(const Constant(3))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  TextColumn get promptVersion => text().withDefault(const Constant('1'))();
  TextColumn get modelVersion =>
      text().withDefault(const Constant('default'))();
  TextColumn get schemaVersion => text().withDefault(const Constant('1'))();
  TextColumn get resultJson => text().nullable()();
  TextColumn get errorJson => text().nullable()();
  TextColumn get pendingAction => text().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get dismissedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
        <Column<Object>>{idempotencyKey},
      ];
}

@DriftDatabase(
  tables: <Type>[
    Dishes,
    DishNotes,
    SourcePhotos,
    GeneratedCovers,
    CaptureBatches,
    CaptureItems,
    CaptureCorrections,
    PlannedMeals,
    ReviewItems,
    SyncOperations,
    SyncMetadata,
    LocalSettings,
    AiJobs,
    ProcessingOutbox,
    ProcessingConsents,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'mymenu'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 18;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator migrator) => migrator.createAll(),
      onUpgrade: (Migrator migrator, int from, int to) async {
        if (from < 2) {
          await migrator.createTable(dishNotes);
          await migrator.createTable(syncMetadata);
          await _migrateJsonNotesToRows(this);
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
        if (from < 4) {
          await migrator.createTable(aiJobs);
        }
        if (from < 5) {
          await migrator.addColumn(captureItems, captureItems.capturedAt);
          await migrator.addColumn(
            captureItems,
            captureItems.capturedLocalDate,
          );
          await migrator.addColumn(
            captureItems,
            captureItems.captureDateSource,
          );
        }
        if (from < 6) {
          await migrator.createTable(captureCorrections);
        }
        if (from < 7) {
          final Set<String> existingTables = (await customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table'",
          ).get())
              .map((QueryRow row) => row.read<String>('name'))
              .toSet();
          if (existingTables.contains('dishes')) {
            await migrator.addColumn(dishes, dishes.createdAt);
          }
          if (existingTables.contains('source_photos')) {
            await migrator.addColumn(sourcePhotos, sourcePhotos.captureId);
            await migrator.addColumn(
              sourcePhotos,
              sourcePhotos.cookingOccasionId,
            );
            await migrator.addColumn(sourcePhotos, sourcePhotos.capturedAt);
          }
        }
        if (from < 8) {
          final Set<String> existingTables = (await customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table'",
          ).get())
              .map((QueryRow row) => row.read<String>('name'))
              .toSet();
          if (existingTables.contains('review_items')) {
            await migrator.addColumn(reviewItems, reviewItems.captureId);
          }
        }
        if (from < 9) {
          await migrator.createTable(processingOutbox);
          final Set<String> existingTables = (await customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table'",
          ).get())
              .map((QueryRow row) => row.read<String>('name'))
              .toSet();
          if (existingTables.contains('ai_jobs') &&
              existingTables.contains('capture_batches')) {
            await customStatement('''
            INSERT OR IGNORE INTO processing_outbox (
              id,
              request_kind,
              subject_id,
              payload_json,
              delivery_state,
              adoption_state,
              privacy_notice_version,
              created_at,
              updated_at
            )
            SELECT
              jobs.id,
              'capture_grouping',
              jobs.subject_id,
              '{"batchId":"' || jobs.subject_id || '","captureIds":[]}',
              CASE jobs.status
                WHEN 'pending_offline' THEN 'waitingForConsent'
                WHEN 'canceled' THEN 'canceled'
                WHEN 'failed' THEN 'failed'
                ELSE 'submitted'
              END,
              CASE
                WHEN batches.status = 'applied' THEN 'adopted'
                WHEN jobs.status = 'succeeded' THEN 'readyForAdoption'
                ELSE 'awaitingProposal'
              END,
              NULL,
              jobs.created_at,
              jobs.updated_at
            FROM ai_jobs AS jobs
            INNER JOIN capture_batches AS batches
              ON batches.id = jobs.subject_id
            WHERE jobs.job_type = 'batch_grouping'
            ''');
          }
        }
        if (from < 10) {
          await migrator.createTable(processingConsents);
        }
        if (from < 11) {
          final List<QueryRow> columns =
              await customSelect('PRAGMA table_info(planned_meals)').get();
          final bool needsPosition = columns.isNotEmpty &&
              !columns.any(
                (QueryRow row) => row.read<String>('name') == 'position',
              );
          if (needsPosition) {
            await migrator.addColumn(plannedMeals, plannedMeals.position);
            await customStatement(
              'UPDATE planned_meals SET position = rowid',
            );
          }
        }
        if (from < 13) {
          await _migrateProcessingOutboxV13(this, migrator);
        }
        if (from < 12) {
          final Set<String> existingTables = (await customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table'",
          ).get())
              .map((QueryRow row) => row.read<String>('name'))
              .toSet();
          if (!existingTables.contains('local_settings')) {
            await migrator.createTable(localSettings);
          }
          await into(localSettings).insertOnConflictUpdate(
            LocalSettingsCompanion.insert(
              key: localSeedDataInitializedKey,
              value: 'true',
            ),
          );
        }
        if (from < 14) {
          await _migrateMediaPreviewsV14(this, migrator);
        }
        if (from < 15) {
          await _migrateProgressivePreviewsV15(this, migrator);
        }
        if (from < 16) {
          await _migrateStandaloneNotesV16(this);
        }
        if (from < 17) {
          await migrator.createTable(generatedCovers);
        }
        if (from < 18) await _migrateDishOpenedV18(this, migrator);
      },
    );
  }
}
