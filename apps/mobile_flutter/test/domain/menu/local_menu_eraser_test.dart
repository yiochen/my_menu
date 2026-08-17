import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/domain/menu/local_menu_eraser.dart';

void main() {
  test('explicit local erase removes menu rows and media only', () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.into(database.dishes).insert(
          DishesCompanion.insert(
            id: 'dish-to-erase',
            title: 'Erase me',
            description: '',
            heroImageUrl: '',
            category: 'Ideas',
            prepMinutes: 0,
            difficulty: 'Draft',
            madeCount: 0,
            lastMadeLabel: 'Never',
            ingredientsJson: '[]',
            recipeStepsJson: '[]',
            notesJson: '[]',
          ),
        );
    await database.into(database.localSettings).insert(
          LocalSettingsCompanion.insert(key: 'menu-setting', value: 'yes'),
        );

    final Directory root =
        await Directory.systemTemp.createTemp('mymenu_local_erase_');
    addTearDown(() => root.delete(recursive: true));
    final Directory documents =
        await Directory('${root.path}/documents').create(recursive: true);
    final Directory support =
        await Directory('${root.path}/support').create(recursive: true);
    final List<Directory> menuDirectories = <Directory>[
      Directory('${documents.path}/captures'),
      Directory('${support.path}/menu_media'),
      Directory('${support.path}/generated-covers'),
      Directory('${support.path}/processing'),
      Directory('${support.path}/dish_image_cache'),
    ];
    for (final Directory directory in menuDirectories) {
      await directory.create(recursive: true);
      await File('${directory.path}/private.jpg').writeAsBytes(<int>[1, 2]);
    }
    final File serviceSession =
        await File('${support.path}/supabase-session.json').writeAsString(
      'keep-service-identity',
    );

    final LocalMenuEraser eraser = LocalMenuEraser(
      database: database,
      documentsDirectoryProvider: () async => documents,
      supportDirectoryProvider: () async => support,
    );
    await eraser.erase();

    expect(await database.select(database.dishes).get(), isEmpty);
    expect(await database.select(database.localSettings).get(), isEmpty);
    for (final Directory directory in menuDirectories) {
      expect(directory.existsSync(), isFalse);
    }
    expect(await serviceSession.readAsString(), 'keep-service-identity');
  });
}
