import 'dart:convert';
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
          return _validJpegBytes;
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
      expect(
        await File(first).readAsBytes(),
        _validJpegBytes,
      );
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
        downloader: (_) async => _validJpegBytes,
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

    test('rejects an incomplete image download', () async {
      final DishImageCache cache = DishImageCache(
        directoryProvider: () async => supportDirectory,
        downloader: (_) async => <int>[0xff, 0xd8, 0x01, 0x02],
      );
      const String remoteRef = 'https://example.test/incomplete.jpg';

      expect(
        await cache.resolve(cacheKey: 'incomplete', remoteRef: remoteRef),
        remoteRef,
      );
    });

    test('requires complete PNG and WebP image chunks', () {
      final List<int> png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      );
      const List<int> webp = <int>[
        0x52,
        0x49,
        0x46,
        0x46,
        0x16,
        0x00,
        0x00,
        0x00,
        0x57,
        0x45,
        0x42,
        0x50,
        0x56,
        0x50,
        0x38,
        0x58,
        0x0a,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
      ];

      expect(hasVerifiedImageBytes(png), isTrue);
      expect(hasVerifiedImageBytes(webp), isTrue);
      expect(
        hasVerifiedImageBytes(
          const <int>[0x89, 0x50, 0x4e, 0x47, 0x49, 0x45, 0x4e, 0x44],
        ),
        isFalse,
      );
      expect(
        hasVerifiedImageBytes(
          const <int>[
            0x52,
            0x49,
            0x46,
            0x46,
            0x04,
            0x00,
            0x00,
            0x00,
            0x57,
            0x45,
            0x42,
            0x50,
          ],
        ),
        isFalse,
      );
    });
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
