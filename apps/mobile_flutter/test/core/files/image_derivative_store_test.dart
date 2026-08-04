import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/files/image_derivative_store.dart';

void main() {
  group('ImageDerivativeStore', () {
    late Directory supportDirectory;
    late File source;
    late List<({int width, int height, int quality})> calls;
    late ImageDerivativeStore store;

    setUp(() async {
      supportDirectory = await Directory.systemTemp.createTemp(
        'mymenu_image_derivative_store_test_',
      );
      source = File('${supportDirectory.path}/source.png');
      await source.writeAsBytes(<int>[9, 8, 7]);
      calls = <({int width, int height, int quality})>[];
      store = ImageDerivativeStore(
        directoryProvider: () async => supportDirectory,
        compressor: ({
          required String sourcePath,
          required String targetPath,
          required int maxWidth,
          required int maxHeight,
          required int quality,
        }) async {
          calls.add((width: maxWidth, height: maxHeight, quality: quality));
          await File(targetPath).writeAsBytes(<int>[1, 2, 3, 4]);
          return targetPath;
        },
      );
    });

    tearDown(() async {
      await supportDirectory.delete(recursive: true);
    });

    test('creates and reuses one maximum-1600 JPEG derivative', () async {
      final String? first = await store.ensure(
        key: 'capture/source',
        sourcePath: source.path,
      );
      final String? second = await store.ensure(
        key: 'capture/source',
        sourcePath: source.path,
        existingRef: first,
      );

      expect(second, first);
      expect(calls, <({int width, int height, int quality})>[
        (width: 1600, height: 1600, quality: 85),
      ]);
      expect(first, endsWith('menu_media/previews/v1/capture_source.jpg'));
      expect(await File(first!).readAsBytes(), <int>[1, 2, 3, 4]);
      expect(File('$first.part').existsSync(), isFalse);
    });

    test('creates reusable processing, card, and tiny placeholder tiers',
        () async {
      final ImageDerivativeSet first = await store.ensureSet(
        key: 'capture/source',
        sourcePath: source.path,
      );
      final ImageDerivativeSet second = await store.ensureSet(
        key: 'capture/source',
        sourcePath: source.path,
        existingProcessingRef: first.processingRef,
        existingCardRef: first.cardRef,
        existingPlaceholderRef: first.placeholderRef,
      );

      expect(second.processingRef, first.processingRef);
      expect(second.cardRef, first.cardRef);
      expect(second.placeholderRef, first.placeholderRef);
      expect(calls, <({int width, int height, int quality})>[
        (width: 1600, height: 1600, quality: 85),
        (width: 640, height: 640, quality: 82),
        (width: 64, height: 64, quality: 55),
      ]);
      expect(first.cardRef, endsWith('capture_source_card.jpg'));
      expect(
        first.placeholderRef,
        endsWith('capture_source_placeholder.jpg'),
      );
    });

    test('regenerates an empty existing derivative', () async {
      final File empty = File('${supportDirectory.path}/empty.jpg');
      await empty.create();

      final String? result = await store.ensure(
        key: 'capture',
        sourcePath: source.path,
        existingRef: empty.path,
      );

      expect(result, isNot(empty.path));
      expect(calls, hasLength(1));
    });

    test('returns null and removes staging data when compression fails',
        () async {
      store = ImageDerivativeStore(
        directoryProvider: () async => supportDirectory,
        compressor: ({
          required String sourcePath,
          required String targetPath,
          required int maxWidth,
          required int maxHeight,
          required int quality,
        }) async {
          await File(targetPath).writeAsBytes(<int>[1]);
          throw StateError('codec failed');
        },
      );

      expect(
        await store.ensure(key: 'failed', sourcePath: source.path),
        isNull,
      );
      expect(
        File(
          '${supportDirectory.path}/menu_media/previews/v1/failed.jpg.part',
        ).existsSync(),
        isFalse,
      );
    });

    test('storage failures fall back without failing callers', () async {
      store = ImageDerivativeStore(
        directoryProvider: () => throw const FileSystemException('unavailable'),
      );

      expect(
        await store.ensure(key: 'failed-storage', sourcePath: source.path),
        isNull,
      );
      await store.remove(refs: const <String>['/preview.jpg']);
      await store.cleanup(referencedRefs: const <String>[]);
    });

    test('cleanup removes only unreferenced derivatives and staging files',
        () async {
      final String kept = (await store.ensure(
        key: 'kept',
        sourcePath: source.path,
      ))!;
      final String removed = (await store.ensure(
        key: 'removed',
        sourcePath: source.path,
      ))!;
      final File partial = File('$kept.part');
      await partial.writeAsBytes(<int>[5]);

      await store.cleanup(referencedRefs: <String>[kept]);

      expect(File(kept).existsSync(), isTrue);
      expect(File(removed).existsSync(), isFalse);
      expect(partial.existsSync(), isFalse);
    });
  });
}
