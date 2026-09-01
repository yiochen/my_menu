part of 'app_database.dart';

Future<void> _migrateCaptureIngestV20(AppDatabase database) async {
  final Set<String> tables = (await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table'",
          )
          .get())
      .map((QueryRow row) => row.read<String>('name'))
      .toSet();

  if (tables.contains('capture_items')) {
    final Set<String> columns = await _tableColumns(database, 'capture_items');
    if (columns.contains('batch_id') && !columns.contains('ingest_id')) {
      await database.customStatement(
        'ALTER TABLE capture_items RENAME COLUMN batch_id TO ingest_id',
      );
    }
    await database.customStatement(
      'UPDATE capture_items SET ingest_id = id WHERE ingest_id IS NULL',
    );
    if (tables.contains('capture_batches')) {
      await database.customStatement('''
        UPDATE capture_items
        SET failure_reason = coalesce(
          failure_reason,
          (
            SELECT capture_batches.failure_reason
            FROM capture_batches
            WHERE capture_batches.id = capture_items.ingest_id
          )
        )
        WHERE EXISTS (
          SELECT 1
          FROM capture_batches
          WHERE capture_batches.id = capture_items.ingest_id
            AND capture_batches.failure_reason IS NOT NULL
        )
      ''');
    }
  }

  if (tables.contains('capture_corrections')) {
    final Set<String> columns =
        await _tableColumns(database, 'capture_corrections');
    if (columns.contains('batch_id') && !columns.contains('ingest_id')) {
      await database.customStatement(
        'ALTER TABLE capture_corrections RENAME COLUMN batch_id TO ingest_id',
      );
    }
  }

  if (tables.contains('source_photos')) {
    final Set<String> columns = await _tableColumns(database, 'source_photos');
    if (columns.contains('cooking_occasion_id') &&
        !columns.contains('ingest_id')) {
      await database.customStatement(
        'ALTER TABLE source_photos '
        'RENAME COLUMN cooking_occasion_id TO ingest_id',
      );
    }
    await database.customStatement('''
      UPDATE source_photos
      SET ingest_id = (
        SELECT capture_items.ingest_id
        FROM capture_items
        WHERE capture_items.id = source_photos.capture_id
      )
    ''');
  }

  if (tables.contains('processing_outbox')) {
    await database.customStatement(r'''
      UPDATE processing_outbox
      SET payload_json = json_set(
        json_remove(payload_json, '$.batchId'),
        '$.ingestId',
        json_extract(payload_json, '$.batchId')
      )
      WHERE request_kind = 'capture_grouping'
        AND json_type(payload_json, '$.batchId') IS NOT NULL
    ''');
    await database.customStatement(r'''
      UPDATE processing_outbox
      SET payload_json = json_set(
        json_remove(payload_json, '$.automaticCaptureBatchId'),
        '$.automaticIngestId',
        json_extract(payload_json, '$.automaticCaptureBatchId')
      )
      WHERE request_kind = 'cover_generation'
        AND json_type(payload_json, '$.automaticCaptureBatchId') IS NOT NULL
    ''');
  }

  if (tables.contains('dishes')) {
    final Set<String> columns = await _tableColumns(database, 'dishes');
    if (columns.contains('made_count')) {
      await database.customStatement(
        'ALTER TABLE dishes DROP COLUMN made_count',
      );
    }
  }

  await database.customStatement('DROP TABLE IF EXISTS capture_batches');
}
