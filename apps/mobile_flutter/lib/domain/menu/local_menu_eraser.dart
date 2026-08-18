import 'dart:io';

import 'package:mymenu/core/database/app_database.dart';
import 'package:path_provider/path_provider.dart';

typedef LocalMenuDirectoryProvider = Future<Directory> Function();

class LocalMenuEraser {
  LocalMenuEraser({
    required this.database,
    LocalMenuDirectoryProvider? documentsDirectoryProvider,
    LocalMenuDirectoryProvider? supportDirectoryProvider,
  })  : _documentsDirectoryProvider =
            documentsDirectoryProvider ?? getApplicationDocumentsDirectory,
        _supportDirectoryProvider =
            supportDirectoryProvider ?? getApplicationSupportDirectory;

  final AppDatabase database;
  final LocalMenuDirectoryProvider _documentsDirectoryProvider;
  final LocalMenuDirectoryProvider _supportDirectoryProvider;

  Future<void> erase() async {
    await database.customStatement('PRAGMA secure_delete = ON');
    await database.transaction(() async {
      await database.delete(database.processingOutbox).go();
      await database.delete(database.processingConsents).go();
      await database.delete(database.captureCorrections).go();
      await database.delete(database.reviewItems).go();
      await database.delete(database.captureItems).go();
      await database.delete(database.captureBatches).go();
      await database.delete(database.plannedMeals).go();
      await database.delete(database.generatedCovers).go();
      await database.delete(database.sourcePhotos).go();
      await database.delete(database.dishNotes).go();
      await database.delete(database.dishes).go();
      await database.delete(database.localSettings).go();
    });
    await database.customStatement('VACUUM');

    final Directory documents = await _documentsDirectoryProvider();
    final Directory support = await _supportDirectoryProvider();
    for (final Directory directory in <Directory>[
      Directory('${documents.path}/captures'),
      Directory('${support.path}/menu_media'),
      Directory('${support.path}/generated-covers'),
      Directory('${support.path}/processing'),
      Directory('${support.path}/dish_image_cache'),
    ]) {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    }
  }
}
