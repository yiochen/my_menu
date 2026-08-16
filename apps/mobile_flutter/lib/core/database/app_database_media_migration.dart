part of 'app_database.dart';

Future<bool> _finishLocalMediaContraction(
  AppDatabase database, {
  required bool allowDownload,
}) async {
  final Set<String> captureColumns =
      await _tableColumns(database, 'capture_items');
  if (!captureColumns.contains('remote_media_ref')) return true;
  final bool capturesLocalized = await _localizeCaptureMedia(
    database,
    allowDownload: allowDownload,
  );
  final List<bool> domainMediaLocalized = await Future.wait(<Future<bool>>[
    _localizeMediaColumns(
      database,
      table: 'dishes',
      idColumn: 'id',
      mediaColumns: const <String>[
        'hero_image_url',
        'hero_preview_url',
        'hero_thumbnail_url',
        'hero_placeholder_url',
      ],
      allowDownload: allowDownload,
    ),
    _localizeMediaColumns(
      database,
      table: 'source_photos',
      idColumn: 'id',
      mediaColumns: const <String>[
        'url',
        'preview_url',
        'thumbnail_url',
        'placeholder_url',
      ],
      allowDownload: allowDownload,
    ),
    _localizeMediaColumns(
      database,
      table: 'review_items',
      idColumn: 'id',
      mediaColumns: const <String>['image_ref'],
      allowDownload: allowDownload,
    ),
  ]);
  final bool allLocalized =
      capturesLocalized && domainMediaLocalized.every((bool value) => value);
  if (allLocalized) {
    await database.customStatement(
      'ALTER TABLE capture_items DROP COLUMN remote_media_ref',
    );
  }
  return allLocalized;
}

Future<bool> _localizeCaptureMedia(
  AppDatabase database, {
  required bool allowDownload,
}) async {
  final List<QueryRow> rows = await database.customSelect('''
    SELECT id, local_media_ref, remote_media_ref
    FROM capture_items
    WHERE remote_media_ref IS NOT NULL AND trim(remote_media_ref) <> ''
  ''').get();
  for (final QueryRow row in rows) {
    final String captureId = row.read<String>('id');
    String? localRef = row.readNullable<String>('local_media_ref');
    if (allowDownload && !await _verifiedLocalMediaRef(localRef)) {
      localRef = await _localizedMediaRef(
        database,
        cacheKey: 'legacy_capture_$captureId',
        mediaRef: row.read<String>('remote_media_ref'),
      );
      if (localRef != null) {
        await database.customStatement(
          'UPDATE capture_items SET local_media_ref = ? WHERE id = ?',
          <Object?>[localRef, captureId],
        );
      }
    }
    if (!await _verifiedLocalMediaRef(localRef)) return false;
  }
  return true;
}

Future<bool> _localizeMediaColumns(
  AppDatabase database, {
  required String table,
  required String idColumn,
  required List<String> mediaColumns,
  required bool allowDownload,
}) async {
  final Set<String> tables = (await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table'",
          )
          .get())
      .map((QueryRow row) => row.read<String>('name'))
      .toSet();
  if (!tables.contains(table)) return true;
  final Set<String> columns = await _tableColumns(database, table);
  for (final String mediaColumn in mediaColumns) {
    if (!columns.contains(mediaColumn)) continue;
    final List<QueryRow> rows = await database.customSelect('''
      SELECT $idColumn AS row_id, $mediaColumn AS media_ref
      FROM $table
      WHERE $mediaColumn LIKE 'http://%' OR $mediaColumn LIKE 'https://%'
    ''').get();
    for (final QueryRow row in rows) {
      final String rowId = row.read<String>('row_id');
      final String remoteRef = row.read<String>('media_ref');
      if (!allowDownload) return false;
      final String? localRef = await _localizedMediaRef(
        database,
        cacheKey: 'legacy_${table}_${rowId}_$mediaColumn',
        mediaRef: remoteRef,
      );
      if (localRef == null) return false;
      await database.customStatement(
        'UPDATE $table SET $mediaColumn = ? WHERE $idColumn = ?',
        <Object?>[localRef, rowId],
      );
    }
  }
  return true;
}

Future<String?> _localizedMediaRef(
  AppDatabase database, {
  required String cacheKey,
  required String mediaRef,
}) async {
  if (await _verifiedLocalMediaRef(mediaRef)) return mediaRef;
  final String localized = await database._legacyMediaCache.resolve(
    cacheKey: cacheKey,
    remoteRef: mediaRef,
  );
  return await _verifiedLocalMediaRef(localized) ? localized : null;
}

Future<bool> _verifiedLocalMediaRef(String? ref) async {
  final String value = ref?.trim() ?? '';
  if (value.isEmpty) return false;
  final Uri? uri = Uri.tryParse(value);
  if (uri != null && uri.scheme.isNotEmpty && uri.scheme != 'file') {
    return false;
  }
  final File file = uri?.scheme == 'file' ? File.fromUri(uri!) : File(value);
  return isVerifiedLocalImage(file);
}
