import 'dart:io';

import 'package:path_provider/path_provider.dart';

typedef DishImageCacheDirectoryProvider = Future<Directory> Function();
typedef DishImageDownloader = Future<List<int>> Function(Uri uri);

class DishImageCache {
  DishImageCache({
    DishImageCacheDirectoryProvider? directoryProvider,
    DishImageDownloader? downloader,
  })  : _directoryProvider =
            directoryProvider ?? getApplicationSupportDirectory,
        _downloader = downloader ?? _download;

  final DishImageCacheDirectoryProvider _directoryProvider;
  final DishImageDownloader _downloader;

  Future<String> resolve({
    required String cacheKey,
    required String remoteRef,
  }) async {
    final Uri? uri = Uri.tryParse(remoteRef);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return remoteRef;
    }

    try {
      final Directory supportDirectory = await _directoryProvider();
      final Directory cacheDirectory = Directory(
        '${supportDirectory.path}/dish_image_cache',
      );
      await cacheDirectory.create(recursive: true);
      final String safeKey = _safeKey(cacheKey);
      final File cachedFile = File('${cacheDirectory.path}/$safeKey.image');
      if (cachedFile.existsSync() && cachedFile.lengthSync() > 0) {
        return cachedFile.path;
      }

      final List<int> bytes = await _downloader(uri);
      if (bytes.isEmpty) {
        return remoteRef;
      }
      final File partialFile = File('${cachedFile.path}.part');
      await partialFile.writeAsBytes(bytes, flush: true);
      if (cachedFile.existsSync()) {
        cachedFile.deleteSync();
      }
      await partialFile.rename(cachedFile.path);
      return cachedFile.path;
    } on Object {
      return remoteRef;
    }
  }

  Future<void> remove({
    Iterable<String> cacheKeys = const <String>[],
    Iterable<String> localRefs = const <String>[],
  }) async {
    try {
      final Directory supportDirectory = await _directoryProvider();
      final Directory cacheDirectory = Directory(
        '${supportDirectory.path}/dish_image_cache',
      );
      if (!cacheDirectory.existsSync()) {
        return;
      }

      final String cachePrefix =
          '${cacheDirectory.absolute.path}${Platform.pathSeparator}';
      final Set<String> paths = <String>{
        for (final String key in cacheKeys)
          '${cacheDirectory.path}/${_safeKey(key)}.image',
        for (final String ref in localRefs)
          if (_isInsideCache(ref, cachePrefix)) File(ref).absolute.path,
      };
      for (final String path in paths) {
        await _deleteIfPresent(File(path));
        await _deleteIfPresent(File('$path.part'));
      }
    } on Object {
      // Cache cleanup is best-effort and must not block authoritative data
      // removal when platform storage is temporarily unavailable.
    }
  }

  String _safeKey(String cacheKey) {
    return cacheKey.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }

  bool _isInsideCache(String ref, String cachePrefix) {
    if (ref.trim().isEmpty) {
      return false;
    }
    final Uri? uri = Uri.tryParse(ref);
    final File file = uri?.scheme == 'file' ? File.fromUri(uri!) : File(ref);
    return file.absolute.path.startsWith(cachePrefix);
  }

  Future<void> _deleteIfPresent(File file) async {
    if (file.existsSync()) {
      await file.delete();
    }
  }

  static Future<List<int>> _download(Uri uri) async {
    final HttpClient client = HttpClient();
    try {
      final HttpClientRequest request = await client.getUrl(uri);
      final HttpClientResponse response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Image download failed with status ${response.statusCode}.',
          uri: uri,
        );
      }
      final List<int> bytes = <int>[];
      await for (final List<int> chunk in response) {
        bytes.addAll(chunk);
      }
      return bytes;
    } finally {
      client.close(force: true);
    }
  }
}
