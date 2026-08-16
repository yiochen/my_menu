import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/files/dish_image_cache.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('schema 18 contracts replication state without losing local memory',
      () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_contract_migration_');
    addTearDown(() => temp.delete(recursive: true));
    final File localPhoto = File('${temp.path}/capture.jpg');
    await localPhoto.writeAsBytes(_validJpegBytes);
    final File databaseFile = File('${temp.path}/mymenu.sqlite');
    _createSchema18Fixture(databaseFile, localPhoto.path);

    final AppDatabase database = AppDatabase.forTesting(
      NativeDatabase(databaseFile),
      legacyMediaCache: DishImageCache(
        directoryProvider: () async => temp,
        downloader: (Uri _) async => _validJpegBytes,
      ),
    );
    addTearDown(database.close);
    expect(await database.resumeLegacyMediaContraction(), isTrue);

    final List<QueryRow> tables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table'",
        )
        .get();
    final Set<String> tableNames =
        tables.map((QueryRow row) => row.read<String>('name')).toSet();
    final Set<String> captureColumns = await _columns(
      database,
      'capture_items',
    );
    final Set<String> noteColumns = await _columns(database, 'dish_notes');
    final List<QueryRow> dishes =
        await database.customSelect('SELECT id, title FROM dishes').get();
    final List<QueryRow> notes = await database
        .customSelect('SELECT id, body FROM dish_notes ORDER BY id')
        .get();
    final List<QueryRow> captures = await database
        .customSelect(
          'SELECT id, local_media_ref FROM capture_items',
        )
        .get();
    final List<QueryRow> sourcePhotos =
        await database.customSelect('SELECT id, url FROM source_photos').get();
    final List<QueryRow> plans =
        await database.customSelect('SELECT id FROM planned_meals').get();
    final List<QueryRow> reviews =
        await database.customSelect('SELECT id FROM review_items').get();
    final List<QueryRow> corrections = await database
        .customSelect('SELECT id, status FROM capture_corrections')
        .get();
    final List<QueryRow> adoptedResults = await database
        .customSelect(
          'SELECT id, result_payload_json FROM processing_outbox '
          "WHERE adoption_state = 'adopted'",
        )
        .get();

    expect(database.schemaVersion, 19);
    expect(tableNames, isNot(contains('sync_operations')));
    expect(tableNames, isNot(contains('sync_metadata')));
    expect(tableNames, isNot(contains('ai_jobs')));
    expect(captureColumns, isNot(contains('remote_media_ref')));
    expect(noteColumns, isNot(contains('deleted_at')));
    expect(dishes.single.read<String>('title'), 'Preserved Dish');
    expect(
      notes.map((QueryRow row) => row.read<String>('id')),
      <String>['active_note'],
    );
    expect(captures.single.read<String>('local_media_ref'), localPhoto.path);
    expect(await isVerifiedLocalImage(localPhoto), isTrue);
    final String localizedHero = (await database
            .customSelect('SELECT hero_image_url FROM dishes')
            .getSingle())
        .read<String>('hero_image_url');
    final String localizedSource = sourcePhotos.single.read<String>('url');
    expect(localizedHero, isNot(startsWith('https://')));
    expect(localizedSource, isNot(startsWith('https://')));
    expect(await isVerifiedLocalImage(File(localizedHero)), isTrue);
    expect(await isVerifiedLocalImage(File(localizedSource)), isTrue);
    expect(plans.single.read<String>('id'), 'plan_1');
    expect(reviews.single.read<String>('id'), 'review_1');
    expect(corrections.single.read<String>('status'), 'applied');
    expect(
      adoptedResults.single.read<String>('result_payload_json'),
      '{"decisions":[]}',
    );
  });

  test('schema 18 opens offline and defers unavailable legacy media', () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_contract_offline_');
    addTearDown(() => temp.delete(recursive: true));
    final File databaseFile = File('${temp.path}/mymenu.sqlite');
    _createSchema18Fixture(databaseFile, '${temp.path}/missing.jpg');
    final AppDatabase database = AppDatabase.forTesting(
      NativeDatabase(databaseFile),
      legacyMediaCache: DishImageCache(
        directoryProvider: () async => temp,
        downloader: (Uri _) => throw const SocketException('offline'),
      ),
    );
    addTearDown(database.close);

    final String title = (await database.customSelect(
            'SELECT title FROM dishes WHERE id = ?',
            variables: <Variable<Object>>[
          const Variable<String>('dish_1'),
        ]).getSingle())
        .read<String>('title');
    final Set<String> captureColumns =
        await _columns(database, 'capture_items');

    expect(title, 'Preserved Dish');
    expect(captureColumns, contains('remote_media_ref'));
    expect(await database.resumeLegacyMediaContraction(), isFalse);
  });
}

const List<int> _validJpegBytes = <int>[
  0xff,
  0xd8,
  0xff,
  0xc0,
  0x00,
  0x0b,
  0x08,
  0x00,
  0x01,
  0x00,
  0x01,
  0x01,
  0x01,
  0x11,
  0x00,
  0xff,
  0xda,
  0x00,
  0x08,
  0x01,
  0x01,
  0x00,
  0x00,
  0x3f,
  0x00,
  0x00,
  0xff,
  0xd9,
];

Future<Set<String>> _columns(AppDatabase database, String tableName) async {
  return (await database.customSelect('PRAGMA table_info($tableName)').get())
      .map((QueryRow row) => row.read<String>('name'))
      .toSet();
}

void _createSchema18Fixture(File databaseFile, String localPhotoPath) {
  sqlite.sqlite3.open(databaseFile.path)
    ..execute('''
      CREATE TABLE dishes (
        id TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        hero_image_url TEXT NOT NULL,
        hero_preview_url TEXT,
        hero_thumbnail_url TEXT,
        hero_placeholder_url TEXT,
        category TEXT NOT NULL,
        prep_minutes INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        made_count INTEGER NOT NULL,
        last_made_label TEXT NOT NULL,
        ingredients_json TEXT NOT NULL,
        recipe_steps_json TEXT NOT NULL,
        notes_json TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER,
        opened_at INTEGER
      )
    ''')
    ..execute('''
      CREATE TABLE dish_notes (
        id TEXT NOT NULL PRIMARY KEY,
        dish_id TEXT NOT NULL,
        body TEXT NOT NULL,
        position INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''')
    ..execute('''
      CREATE TABLE source_photos (
        id TEXT NOT NULL PRIMARY KEY,
        dish_id TEXT NOT NULL,
        url TEXT NOT NULL,
        preview_url TEXT,
        thumbnail_url TEXT,
        placeholder_url TEXT,
        captured_label TEXT NOT NULL,
        confidence_label TEXT,
        capture_id TEXT,
        cooking_occasion_id TEXT,
        captured_at INTEGER
      )
    ''')
    ..execute('''
      CREATE TABLE capture_items (
        id TEXT NOT NULL PRIMARY KEY,
        batch_id TEXT,
        ordinal INTEGER NOT NULL DEFAULT 0,
        kind TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        local_media_ref TEXT,
        local_preview_ref TEXT,
        local_thumbnail_ref TEXT,
        local_placeholder_ref TEXT,
        remote_media_ref TEXT,
        idea_text TEXT,
        captured_at INTEGER,
        captured_local_date TEXT,
        capture_date_source TEXT,
        applied_dish_id TEXT,
        failure_reason TEXT
      )
    ''')
    ..execute('''
      CREATE TABLE capture_batches (
        id TEXT NOT NULL PRIMARY KEY,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        failure_reason TEXT
      )
    ''')
    ..execute('''
      CREATE TABLE capture_corrections (
        id TEXT NOT NULL PRIMARY KEY,
        batch_id TEXT NOT NULL,
        action_type TEXT NOT NULL,
        capture_ids_json TEXT NOT NULL,
        previous_dish_ids_json TEXT NOT NULL,
        target_dish_id TEXT NOT NULL,
        created_dish_id TEXT,
        status TEXT NOT NULL,
        error TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        undone_at INTEGER
      )
    ''')
    ..execute('''
      CREATE TABLE planned_meals (
        id TEXT NOT NULL PRIMARY KEY,
        day_key TEXT NOT NULL,
        dish_id TEXT NOT NULL,
        label TEXT,
        position INTEGER NOT NULL DEFAULT 0
      )
    ''')
    ..execute('''
      CREATE TABLE review_items (
        id TEXT NOT NULL PRIMARY KEY,
        capture_id TEXT,
        summary TEXT NOT NULL,
        suggested_dish_ids_json TEXT NOT NULL,
        confidence_label TEXT NOT NULL,
        image_ref TEXT
      )
    ''')
    ..execute('''
      CREATE TABLE processing_outbox (
        id TEXT NOT NULL PRIMARY KEY,
        request_kind TEXT NOT NULL,
        subject_id TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        delivery_state TEXT NOT NULL,
        adoption_state TEXT NOT NULL,
        privacy_notice_version TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        idempotency_key TEXT NOT NULL DEFAULT '',
        server_job_id TEXT,
        server_expires_at INTEGER,
        uploaded_asset_ids_json TEXT NOT NULL DEFAULT '[]',
        result_payload_json TEXT,
        result_schema_version TEXT,
        attempt_count INTEGER NOT NULL DEFAULT 0,
        next_retry_at INTEGER,
        failure_code TEXT,
        UNIQUE(request_kind, subject_id)
      )
    ''')
    ..execute('''
      CREATE TABLE sync_operations (
        id TEXT NOT NULL PRIMARY KEY,
        entity TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation_type TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        completed_at INTEGER
      )
    ''')
    ..execute('CREATE TABLE sync_metadata (key TEXT PRIMARY KEY, value TEXT)')
    ..execute('CREATE TABLE ai_jobs (id TEXT PRIMARY KEY)')
    ..execute('''
      INSERT INTO dishes VALUES (
        'dish_1', 'Preserved Dish', '', ?, NULL, NULL, NULL, 'Dinner', 30,
        'Easy', 1, 'Today', '[]', '[]', '[]', 0, NULL, NULL
      )
    ''', <Object?>['https://legacy.example/hero.jpg'])
    ..execute('''
      INSERT INTO dish_notes VALUES
        ('active_note', 'dish_1', 'Keep this', 0, 1, 1, NULL),
        ('deleted_note', 'dish_1', 'Remove tombstone', 1, 1, 1, 2)
    ''')
    ..execute(
      '''
        INSERT INTO capture_items (
          id, batch_id, kind, status, created_at, local_media_ref,
          remote_media_ref
        ) VALUES ('capture_1', 'batch_1', 'photo', 'applied', 1, ?, ?)
      ''',
      <Object?>[localPhotoPath, 'https://legacy.example/capture.jpg'],
    )
    ..execute(
      "INSERT INTO capture_batches VALUES ('batch_1', 'applied', 1, 1, NULL)",
    )
    ..execute('''
      INSERT INTO source_photos VALUES (
        'source_1', 'dish_1', 'https://legacy.example/source.jpg', NULL, NULL,
        NULL, 'Today', NULL, 'capture_1', NULL, 1
      )
    ''')
    ..execute(
      "INSERT INTO planned_meals VALUES ('plan_1', '2026-08-16', 'dish_1', NULL, 0)",
    )
    ..execute('''
      INSERT INTO review_items VALUES (
        'review_1', 'capture_1', 'Check grouping', '[]', 'Low', ?
      )
    ''', <Object?>[localPhotoPath])
    ..execute('''
      INSERT INTO capture_corrections VALUES (
        'correction_1', 'batch_1', 'move', '["capture_1"]', '{}', 'dish_1',
        NULL, 'synced', NULL, 1, 1, NULL
      )
    ''')
    ..execute('''
      INSERT INTO processing_outbox (
        id, request_kind, subject_id, payload_json, delivery_state,
        adoption_state, privacy_notice_version, created_at, updated_at,
        idempotency_key, result_payload_json, result_schema_version
      ) VALUES (
        'adopted_1', 'capture_grouping', 'batch_1', '{}', 'acknowledged',
        'adopted', '2026-08-01', 1, 1, 'adopted_1', '{"decisions":[]}',
        'capture-grouping-result-v2'
      )
    ''')
    ..execute(
      "INSERT INTO sync_metadata VALUES ('capture_sync_cursor', '42')",
    )
    ..execute('''
      INSERT INTO sync_operations VALUES (
        'operation_1', 'dish', 'dish_1', 'update', '{}', 1, NULL
      )
    ''')
    ..execute('PRAGMA user_version = 18')
    ..close();
}
