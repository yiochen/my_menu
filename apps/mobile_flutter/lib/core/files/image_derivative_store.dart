import 'dart:async';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

typedef ImageDerivativeDirectoryProvider = Future<Directory> Function();
typedef ImageDerivativeCompressor = Future<String?> Function({
  required String sourcePath,
  required String targetPath,
  required int maxWidth,
  required int maxHeight,
  required int quality,
});

enum ImageDerivativeProfile {
  processing(maxWidth: 1600, maxHeight: 1600, quality: 85, fileSuffix: ''),
  card(maxWidth: 640, maxHeight: 640, quality: 82, fileSuffix: '_card'),
  placeholder(
    maxWidth: 64,
    maxHeight: 64,
    quality: 55,
    fileSuffix: '_placeholder',
  );

  const ImageDerivativeProfile({
    required this.maxWidth,
    required this.maxHeight,
    required this.quality,
    required this.fileSuffix,
  });

  final int maxWidth;
  final int maxHeight;
  final int quality;
  final String fileSuffix;
}

class ImageDerivativeSet {
  const ImageDerivativeSet({
    required this.processingRef,
    required this.cardRef,
    required this.placeholderRef,
  });

  final String? processingRef;
  final String? cardRef;
  final String? placeholderRef;

  Iterable<String?> get refs => <String?>[
        processingRef,
        cardRef,
        placeholderRef,
      ];
}

class ImageDerivativeStore {
  ImageDerivativeStore({
    ImageDerivativeDirectoryProvider? directoryProvider,
    ImageDerivativeCompressor? compressor,
  })  : _directoryProvider = directoryProvider ?? _defaultDirectoryProvider(),
        _compressor = compressor ?? _compress;

  static const int maxWidth = 1600;
  static const int maxHeight = 1600;
  static const int quality = 85;

  final ImageDerivativeDirectoryProvider _directoryProvider;
  final ImageDerivativeCompressor _compressor;
  final Map<String, Future<String?>> _inFlight = <String, Future<String?>>{};

  Future<String?> ensure({
    required String key,
    required String sourcePath,
    String? existingRef,
    ImageDerivativeProfile profile = ImageDerivativeProfile.processing,
  }) {
    final String safeKey = _safeKey('$key${profile.fileSuffix}');
    return _inFlight.putIfAbsent(safeKey, () async {
      try {
        return await _ensure(
          safeKey: safeKey,
          sourcePath: sourcePath,
          existingRef: existingRef,
          profile: profile,
        );
      } on Object {
        return null;
      } finally {
        unawaited(_inFlight.remove(safeKey));
      }
    });
  }

  Future<ImageDerivativeSet> ensureSet({
    required String key,
    required String sourcePath,
    String? existingProcessingRef,
    String? existingCardRef,
    String? existingPlaceholderRef,
  }) async {
    final String? processingRef = await ensure(
      key: key,
      sourcePath: sourcePath,
      existingRef: existingProcessingRef,
    );
    final String cardSource = processingRef ?? sourcePath;
    final String? cardRef = await ensure(
      key: key,
      sourcePath: cardSource,
      existingRef: existingCardRef,
      profile: ImageDerivativeProfile.card,
    );
    final String placeholderSource = cardRef ?? processingRef ?? sourcePath;
    final String? placeholderRef = await ensure(
      key: key,
      sourcePath: placeholderSource,
      existingRef: existingPlaceholderRef,
      profile: ImageDerivativeProfile.placeholder,
    );
    return ImageDerivativeSet(
      processingRef: processingRef,
      cardRef: cardRef,
      placeholderRef: placeholderRef,
    );
  }

  Future<void> remove({
    Iterable<String?> refs = const <String?>[],
  }) async {
    try {
      final Directory directory = await _previewDirectory();
      final String prefix =
          '${directory.absolute.path}${Platform.pathSeparator}';
      for (final String ref in refs.whereType<String>().toSet()) {
        final File file = _fileFromRef(ref);
        if (!file.absolute.path.startsWith(prefix)) {
          continue;
        }
        await _deleteIfPresent(file);
        await _deleteIfPresent(File('${file.path}.part'));
      }
    } on Object {
      // Derived media is recoverable and must not block authoritative removal.
    }
  }

  Future<void> cleanup({required Iterable<String?> referencedRefs}) async {
    try {
      final Directory directory = await _previewDirectory();
      if (!directory.existsSync()) {
        return;
      }
      final Set<String> referenced = referencedRefs
          .whereType<String>()
          .map(_fileFromRef)
          .map((File file) => file.absolute.path)
          .toSet();
      await for (final FileSystemEntity entity in directory.list()) {
        if (entity is! File) {
          continue;
        }
        if (entity.path.endsWith('.part') ||
            !referenced.contains(entity.absolute.path)) {
          await _deleteIfPresent(entity);
        }
      }
    } on Object {
      // Orphan cleanup is best-effort and can retry on the next startup.
    }
  }

  Future<String?> _ensure({
    required String safeKey,
    required String sourcePath,
    required String? existingRef,
    required ImageDerivativeProfile profile,
  }) async {
    if (existingRef != null && await _isValid(_fileFromRef(existingRef))) {
      return existingRef;
    }
    final File source = _fileFromRef(sourcePath);
    if (!await _isValid(source)) {
      return null;
    }

    final Directory directory = await _previewDirectory();
    await directory.create(recursive: true);
    final File target = File('${directory.path}/$safeKey.jpg');
    if (await _isValid(target)) {
      return target.path;
    }
    final File partial = File('${target.path}.part');
    await _deleteIfPresent(partial);
    try {
      final String? compressedPath = await _compressor(
        sourcePath: source.path,
        targetPath: partial.path,
        maxWidth: profile.maxWidth,
        maxHeight: profile.maxHeight,
        quality: profile.quality,
      );
      if (compressedPath == null || !await _isValid(partial)) {
        await _deleteIfPresent(partial);
        return null;
      }
      await _deleteIfPresent(target);
      await partial.rename(target.path);
      return target.path;
    } on Object {
      await _deleteIfPresent(partial);
      return null;
    }
  }

  Future<Directory> _previewDirectory() async {
    final Directory support = await _directoryProvider();
    return Directory('${support.path}/menu_media/previews/v1');
  }

  File _fileFromRef(String ref) {
    final Uri? uri = Uri.tryParse(ref);
    return uri?.scheme == 'file' ? File.fromUri(uri!) : File(ref);
  }

  Future<bool> _isValid(File file) async {
    return file.existsSync() && file.lengthSync() > 0;
  }

  Future<void> _deleteIfPresent(File file) async {
    if (file.existsSync()) {
      await file.delete();
    }
  }

  String _safeKey(String key) {
    return key.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }

  static Future<String?> _compress({
    required String sourcePath,
    required String targetPath,
    required int maxWidth,
    required int maxHeight,
    required int quality,
  }) async {
    try {
      final XFile? compressed = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        minWidth: maxWidth,
        minHeight: maxHeight,
        quality: quality,
      );
      return compressed?.path;
    } on Object {
      if (Platform.environment['FLUTTER_TEST'] != 'true') {
        rethrow;
      }
      return (await File(sourcePath).copy(targetPath)).path;
    }
  }

  static ImageDerivativeDirectoryProvider _defaultDirectoryProvider() {
    Directory? testDirectory;
    return () async {
      try {
        return await getApplicationSupportDirectory();
      } on Object {
        if (Platform.environment['FLUTTER_TEST'] != 'true') {
          rethrow;
        }
        return testDirectory ??= await Directory.systemTemp.createTemp(
          'mymenu_image_derivatives_',
        );
      }
    };
  }
}
