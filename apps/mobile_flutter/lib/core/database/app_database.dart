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
  TextColumn get kind => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get localMediaRef => text().nullable()();
  TextColumn get remoteMediaRef => text().nullable()();
  TextColumn get ideaText => text().nullable()();
  TextColumn get appliedDishId => text().nullable()();

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

@DriftDatabase(
  tables: <Type>[
    Dishes,
    SourcePhotos,
    CaptureItems,
    PlannedMeals,
    ReviewItems,
    SyncOperations,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'mymenu');
}
