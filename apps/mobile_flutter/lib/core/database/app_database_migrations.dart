part of 'app_database.dart';

Future<void> _migrateLocalFirstContractV19(AppDatabase database) async {
  final Set<String> tables = (await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table'",
          )
          .get())
      .map((QueryRow row) => row.read<String>('name'))
      .toSet();

  await _finishLocalMediaContraction(database, allowDownload: false);

  if (tables.contains('dish_notes')) {
    final Set<String> columns = await _tableColumns(database, 'dish_notes');
    if (columns.contains('deleted_at')) {
      await database.customStatement(
        'DELETE FROM dish_notes WHERE deleted_at IS NOT NULL',
      );
      await database.customStatement(
        'ALTER TABLE dish_notes DROP COLUMN deleted_at',
      );
    }
  }

  if (tables.contains('capture_corrections')) {
    await database.customStatement(
      "UPDATE capture_corrections SET status = 'applied' "
      "WHERE status IN ('pending', 'synced')",
    );
  }

  if (tables.contains('ai_jobs')) {
    await _preserveLegacyProcessingRequests(database);
  }
  await database.customStatement('DROP TABLE IF EXISTS ai_jobs');
  await database.customStatement('DROP TABLE IF EXISTS sync_operations');
  await database.customStatement('DROP TABLE IF EXISTS sync_metadata');
}

Future<void> _preserveLegacyProcessingRequests(AppDatabase database) async {
  final Set<String> columns = await _tableColumns(database, 'ai_jobs');
  const Set<String> required = <String>{
    'id',
    'job_type',
    'subject_id',
    'created_at',
    'updated_at',
  };
  if (!columns.containsAll(required)) {
    return;
  }
  await database.customStatement('''
    INSERT OR IGNORE INTO processing_outbox (
      id,
      request_kind,
      subject_id,
      payload_json,
      delivery_state,
      adoption_state,
      privacy_notice_version,
      idempotency_key,
      failure_code,
      created_at,
      updated_at
    )
    SELECT
      jobs.id,
      'capture_grouping',
      jobs.subject_id,
      json_object(
        'batchId', jobs.subject_id,
        'captureIds', json(
          coalesce(
            (
              SELECT json_group_array(items.id)
              FROM capture_items AS items
              WHERE items.batch_id = jobs.subject_id
            ),
            '[]'
          )
        )
      ),
      'failed',
      'awaitingProposal',
      NULL,
      jobs.id,
      'legacy_processing_replaced',
      jobs.created_at,
      jobs.updated_at
    FROM ai_jobs AS jobs
    WHERE jobs.job_type = 'batch_grouping'
  ''');
}

Future<void> _migrateDishOpenedV18(
  AppDatabase database,
  Migrator migrator,
) async {
  final Set<String> existingTables = (await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table'",
          )
          .get())
      .map((QueryRow row) => row.read<String>('name'))
      .toSet();
  if (!existingTables.contains('dishes')) {
    return;
  }
  final Set<String> columns = await _tableColumns(database, 'dishes');
  if (!columns.contains('opened_at')) {
    await migrator.addColumn(database.dishes, database.dishes.openedAt);
  }
}

Future<void> _migrateStandaloneNotesV16(AppDatabase database) async {
  final Set<String> columns = await _tableColumns(database, 'source_photos');
  if (columns.contains('note')) {
    await database
        .customStatement('ALTER TABLE source_photos DROP COLUMN note');
  }
}

Future<void> _migrateProgressivePreviewsV15(
  AppDatabase database,
  Migrator migrator,
) async {
  final Set<String> existingTables = (await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table'",
          )
          .get())
      .map((QueryRow row) => row.read<String>('name'))
      .toSet();
  if (existingTables.contains('dishes')) {
    final Set<String> columns = await _tableColumns(database, 'dishes');
    if (!columns.contains('hero_thumbnail_url')) {
      await migrator.addColumn(
        database.dishes,
        database.dishes.heroThumbnailUrl,
      );
    }
    if (!columns.contains('hero_placeholder_url')) {
      await migrator.addColumn(
        database.dishes,
        database.dishes.heroPlaceholderUrl,
      );
    }
  }
  if (existingTables.contains('source_photos')) {
    final Set<String> columns = await _tableColumns(database, 'source_photos');
    if (!columns.contains('thumbnail_url')) {
      await migrator.addColumn(
        database.sourcePhotos,
        database.sourcePhotos.thumbnailUrl,
      );
    }
    if (!columns.contains('placeholder_url')) {
      await migrator.addColumn(
        database.sourcePhotos,
        database.sourcePhotos.placeholderUrl,
      );
    }
  }
  if (existingTables.contains('capture_items')) {
    final Set<String> columns = await _tableColumns(database, 'capture_items');
    if (!columns.contains('local_thumbnail_ref')) {
      await migrator.addColumn(
        database.captureItems,
        database.captureItems.localThumbnailRef,
      );
    }
    if (!columns.contains('local_placeholder_ref')) {
      await migrator.addColumn(
        database.captureItems,
        database.captureItems.localPlaceholderRef,
      );
    }
  }
}

Future<Set<String>> _tableColumns(
  AppDatabase database,
  String tableName,
) async {
  return (await database.customSelect('PRAGMA table_info($tableName)').get())
      .map((QueryRow row) => row.read<String>('name'))
      .toSet();
}

Future<void> _migrateMediaPreviewsV14(
  AppDatabase database,
  Migrator migrator,
) async {
  final Set<String> existingTables = (await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table'",
          )
          .get())
      .map((QueryRow row) => row.read<String>('name'))
      .toSet();
  if (existingTables.contains('dishes')) {
    final Set<String> columns = (await database
            .customSelect(
              'PRAGMA table_info(dishes)',
            )
            .get())
        .map((QueryRow row) => row.read<String>('name'))
        .toSet();
    if (!columns.contains('hero_preview_url')) {
      await migrator.addColumn(database.dishes, database.dishes.heroPreviewUrl);
    }
  }
  if (existingTables.contains('source_photos')) {
    final Set<String> columns = (await database
            .customSelect(
              'PRAGMA table_info(source_photos)',
            )
            .get())
        .map((QueryRow row) => row.read<String>('name'))
        .toSet();
    if (!columns.contains('preview_url')) {
      await migrator.addColumn(
        database.sourcePhotos,
        database.sourcePhotos.previewUrl,
      );
    }
  }
  if (existingTables.contains('capture_items')) {
    final Set<String> columns = (await database
            .customSelect(
              'PRAGMA table_info(capture_items)',
            )
            .get())
        .map((QueryRow row) => row.read<String>('name'))
        .toSet();
    if (!columns.contains('local_preview_ref')) {
      await migrator.addColumn(
        database.captureItems,
        database.captureItems.localPreviewRef,
      );
    }
  }
}

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
