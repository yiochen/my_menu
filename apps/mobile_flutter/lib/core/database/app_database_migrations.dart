part of 'app_database.dart';

Future<void> _migrateProcessingOutboxV13(
  AppDatabase database,
  Migrator migrator,
) async {
  final Set<String> processingColumns = (await database
          .customSelect(
            'PRAGMA table_info(processing_outbox)',
          )
          .get())
      .map((QueryRow row) => row.read<String>('name'))
      .toSet();
  if (!processingColumns.contains('idempotency_key')) {
    await migrator.addColumn(
      database.processingOutbox,
      database.processingOutbox.idempotencyKey,
    );
    await migrator.addColumn(
      database.processingOutbox,
      database.processingOutbox.serverJobId,
    );
    await migrator.addColumn(
      database.processingOutbox,
      database.processingOutbox.serverExpiresAt,
    );
    await migrator.addColumn(
      database.processingOutbox,
      database.processingOutbox.uploadedAssetIdsJson,
    );
    await migrator.addColumn(
      database.processingOutbox,
      database.processingOutbox.resultPayloadJson,
    );
    await migrator.addColumn(
      database.processingOutbox,
      database.processingOutbox.resultSchemaVersion,
    );
    await migrator.addColumn(
      database.processingOutbox,
      database.processingOutbox.attemptCount,
    );
    await migrator.addColumn(
      database.processingOutbox,
      database.processingOutbox.nextRetryAt,
    );
    await migrator.addColumn(
      database.processingOutbox,
      database.processingOutbox.failureCode,
    );
  }
  await database.customStatement(
    'UPDATE processing_outbox SET idempotency_key = id '
    "WHERE idempotency_key = ''",
  );
}

Future<void> _migrateJsonNotesToRows(AppDatabase database) async {
  final List<DishRow> dishRows = await database.select(database.dishes).get();
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
      await database.into(database.dishNotes).insert(
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
