import 'package:drift/drift.dart';

@DataClassName('ProcessingOutboxRow')
class ProcessingOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get requestKind => text()();
  TextColumn get subjectId => text()();
  TextColumn get payloadJson => text()();
  TextColumn get deliveryState => text()();
  TextColumn get adoptionState => text()();
  TextColumn get privacyNoticeVersion => text().nullable()();
  TextColumn get idempotencyKey => text().withDefault(const Constant(''))();
  TextColumn get serverJobId => text().nullable()();
  DateTimeColumn get serverExpiresAt => dateTime().nullable()();
  TextColumn get uploadedAssetIdsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get resultPayloadJson => text().nullable()();
  TextColumn get resultSchemaVersion => text().nullable()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  TextColumn get failureCode => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
        <Column<Object>>{requestKind, subjectId},
      ];
}

@DataClassName('ProcessingConsentRow')
class ProcessingConsents extends Table {
  TextColumn get noticeVersion => text()();
  TextColumn get decision => text()();
  DateTimeColumn get decidedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{noticeVersion};
}
