import 'package:drift/drift.dart';

const String localSeedDataInitializedKey = 'sample_data_initialized';

@DataClassName('PlannedMealRow')
class PlannedMeals extends Table {
  TextColumn get id => text()();
  TextColumn get dayKey => text()();
  TextColumn get dishId => text()();
  TextColumn get label => text().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('LocalSettingRow')
class LocalSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}
