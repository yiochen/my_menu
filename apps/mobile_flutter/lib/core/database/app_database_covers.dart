import 'package:drift/drift.dart';

@DataClassName('GeneratedCoverRow')
class GeneratedCovers extends Table {
  TextColumn get id => text()();
  TextColumn get dishId => text()();
  TextColumn get localPath => text()();
  TextColumn get previewPath => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  TextColumn get placeholderPath => text().nullable()();
  TextColumn get origin => text()();
  TextColumn get grounding => text()();
  TextColumn get selectedSourceIdsJson => text()();
  TextColumn get look => text()();
  TextColumn get view => text()();
  TextColumn get finish => text()();
  TextColumn get contractVersion => text()();
  TextColumn get proposalId => text()();
  TextColumn get state => text()();
  BoolColumn get automaticAcknowledged =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get automaticUndoAvailable =>
      boolean().withDefault(const Constant(false))();
  TextColumn get previousCoverJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
