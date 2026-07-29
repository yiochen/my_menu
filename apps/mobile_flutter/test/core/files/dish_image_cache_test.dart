import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/files/dish_image_cache.dart';

void main() {
  group('DishImageCache', () {
    late Directory supportDirectory;

    setUp(() async {
      supportDirectory = await Directory.systemTemp.createTemp(
        'mymenu_dish_image_cache_test_',
      );
    });

    tearDown(() async {
      await supportDirectory.delete(recursive: true);
    });

    test('downloads a remote image once and reuses the local file', () async {
      var downloadCount = 0;
      final DishImageCache cache = DishImageCache(
        directoryProvider: () async => supportDirectory,
        downloader: (Uri uri) async {
          downloadCount += 1;
          expect(uri.host, 'example.test');
          return <int>[1, 2, 3, 4];
        },
      );

      final String first = await cache.resolve(
        cacheKey: 'source/photo',
        remoteRef: 'https://example.test/signed/photo?token=first',
      );
      final String second = await cache.resolve(
        cacheKey: 'source/photo',
        remoteRef: 'https://example.test/signed/photo?token=renewed',
      );

      expect(first, second);
      expect(downloadCount, 1);
      expect(await File(first).readAsBytes(), <int>[1, 2, 3, 4]);
      expect(first, contains('dish_image_cache/source_photo.image'));
    });

    test('keeps the remote reference when downloading fails', () async {
      final DishImageCache cache = DishImageCache(
        directoryProvider: () async => supportDirectory,
        downloader: (Uri uri) => throw const SocketException('offline'),
      );
      const String remoteRef = 'https://example.test/photo';

      expect(
        await cache.resolve(cacheKey: 'photo', remoteRef: remoteRef),
        remoteRef,
      );
    });

    test('leaves non-network references unchanged', () async {
      final DishImageCache cache = DishImageCache(
        directoryProvider: () async => supportDirectory,
      );

      expect(
        await cache.resolve(cacheKey: 'photo', remoteRef: '/local/photo.jpg'),
        '/local/photo.jpg',
      );
    });

    test('removes only requested cached files', () async {
      final DishImageCache cache = DishImageCache(
        directoryProvider: () async => supportDirectory,
        downloader: (_) async => <int>[1, 2, 3],
      );
      final String removedPath = await cache.resolve(
        cacheKey: 'dish/remove',
        remoteRef: 'https://example.test/remove.jpg',
      );
      final String keptPath = await cache.resolve(
        cacheKey: 'dish/keep',
        remoteRef: 'https://example.test/keep.jpg',
      );
      final File externalFile = File('${supportDirectory.path}/external.jpg');
      await externalFile.writeAsBytes(<int>[9, 9, 9]);

      await cache.remove(
        cacheKeys: const <String>['dish/remove'],
        localRefs: <String>[externalFile.path],
      );

      expect(File(removedPath).existsSync(), isFalse);
      expect(File(keptPath).existsSync(), isTrue);
      expect(externalFile.existsSync(), isTrue);
    });
  });
}
