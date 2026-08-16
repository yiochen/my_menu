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
      if (await isVerifiedLocalImage(cachedFile)) {
        return cachedFile.path;
      }

      final List<int> bytes = await _downloader(uri);
      if (!hasVerifiedImageBytes(bytes)) {
        return remoteRef;
      }
      final File partialFile = File('${cachedFile.path}.part');
      await partialFile.writeAsBytes(bytes, flush: true);
      if (cachedFile.existsSync()) {
        cachedFile.deleteSync();
      }
      final File committed = await partialFile.rename(cachedFile.path);
      return await isVerifiedLocalImage(committed) ? committed.path : remoteRef;
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

Future<bool> isVerifiedLocalImage(File file) async {
  try {
    if (!file.existsSync()) return false;
    return hasVerifiedImageBytes(file.readAsBytesSync());
  } on FileSystemException {
    return false;
  }
}

bool hasVerifiedImageBytes(List<int> bytes) {
  if (_hasCompleteJpegStructure(bytes)) {
    return true;
  }
  if (_hasCompletePngStructure(bytes)) {
    return true;
  }
  if (_hasCompleteWebpStructure(bytes)) return true;
  return _hasCompleteIsoMediaBoxes(bytes);
}

bool _hasCompletePngStructure(List<int> bytes) {
  const List<int> signature = <int>[
    0x89,
    0x50,
    0x4e,
    0x47,
    0x0d,
    0x0a,
    0x1a,
    0x0a,
  ];
  if (bytes.length < 45 || !_bytesEqual(bytes, 0, signature)) return false;
  var offset = 8;
  var hasHeader = false;
  var hasImageData = false;
  while (offset + 12 <= bytes.length) {
    final int dataLength = _bigEndianInt(bytes, offset, 4);
    final int chunkEnd = offset + 12 + dataLength;
    if (chunkEnd > bytes.length) return false;
    final String type = String.fromCharCodes(
      bytes.sublist(offset + 4, offset + 8),
    );
    if (!hasHeader) {
      if (type != 'IHDR' || dataLength != 13) return false;
      final int width = _bigEndianInt(bytes, offset + 8, 4);
      final int height = _bigEndianInt(bytes, offset + 12, 4);
      if (width == 0 || height == 0) return false;
      hasHeader = true;
    } else if (type == 'IDAT') {
      hasImageData = hasImageData || dataLength > 0;
    } else if (type == 'IEND') {
      return dataLength == 0 && hasImageData && chunkEnd == bytes.length;
    }
    offset = chunkEnd;
  }
  return false;
}

bool _hasCompleteWebpStructure(List<int> bytes) {
  if (bytes.length < 30 ||
      !_bytesEqual(bytes, 0, const <int>[0x52, 0x49, 0x46, 0x46]) ||
      !_bytesEqual(bytes, 8, const <int>[0x57, 0x45, 0x42, 0x50])) {
    return false;
  }
  if (_littleEndianInt(bytes, 4, 4) + 8 != bytes.length) return false;
  var offset = 12;
  var hasImageChunk = false;
  while (offset + 8 <= bytes.length) {
    final String type = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    final int dataLength = _littleEndianInt(bytes, offset + 4, 4);
    final int dataStart = offset + 8;
    final int chunkEnd = dataStart + dataLength;
    if (chunkEnd > bytes.length) return false;
    if (type == 'VP8X' && dataLength >= 10) {
      final int width = _littleEndianInt(bytes, dataStart + 4, 3) + 1;
      final int height = _littleEndianInt(bytes, dataStart + 7, 3) + 1;
      hasImageChunk = width > 0 && height > 0;
    } else if (type == 'VP8L' && dataLength >= 5 && bytes[dataStart] == 0x2f) {
      hasImageChunk = true;
    } else if (type == 'VP8 ' &&
        dataLength >= 10 &&
        bytes[dataStart + 3] == 0x9d &&
        bytes[dataStart + 4] == 0x01 &&
        bytes[dataStart + 5] == 0x2a) {
      final int width = _littleEndianInt(bytes, dataStart + 6, 2) & 0x3fff;
      final int height = _littleEndianInt(bytes, dataStart + 8, 2) & 0x3fff;
      hasImageChunk = width > 0 && height > 0;
    }
    offset = chunkEnd + (dataLength.isOdd ? 1 : 0);
  }
  return hasImageChunk && offset == bytes.length;
}

bool _bytesEqual(List<int> bytes, int offset, List<int> expected) {
  if (offset + expected.length > bytes.length) return false;
  for (var index = 0; index < expected.length; index += 1) {
    if (bytes[offset + index] != expected[index]) return false;
  }
  return true;
}

int _littleEndianInt(List<int> bytes, int offset, int length) {
  var value = 0;
  for (var index = 0; index < length; index += 1) {
    value |= bytes[offset + index] << (index * 8);
  }
  return value;
}

bool _hasCompleteJpegStructure(List<int> bytes) {
  if (bytes.length < 16 || bytes[0] != 0xff || bytes[1] != 0xd8) {
    return false;
  }
  var offset = 2;
  var hasDimensions = false;
  var hasScan = false;
  while (offset + 1 < bytes.length) {
    if (bytes[offset] != 0xff) return false;
    while (offset < bytes.length && bytes[offset] == 0xff) {
      offset += 1;
    }
    if (offset >= bytes.length) return false;
    final int marker = bytes[offset++];
    if (marker == 0xd9) {
      return hasDimensions && hasScan && offset == bytes.length;
    }
    if (marker == 0xda) {
      if (offset + 2 > bytes.length) return false;
      final int scanHeaderLength = _bigEndianInt(bytes, offset, 2);
      if (scanHeaderLength < 2 || offset + scanHeaderLength > bytes.length) {
        return false;
      }
      hasScan = true;
      offset += scanHeaderLength;
      while (offset + 1 < bytes.length) {
        if (bytes[offset] != 0xff) {
          offset += 1;
          continue;
        }
        if (bytes[offset + 1] == 0x00) {
          offset += 2;
          continue;
        }
        break;
      }
      continue;
    }
    if (marker == 0x01 || (marker >= 0xd0 && marker <= 0xd7)) continue;
    if (offset + 2 > bytes.length) return false;
    final int segmentLength = _bigEndianInt(bytes, offset, 2);
    if (segmentLength < 2 || offset + segmentLength > bytes.length) {
      return false;
    }
    final bool isStartOfFrame = <int>{
      0xc0,
      0xc1,
      0xc2,
      0xc3,
      0xc5,
      0xc6,
      0xc7,
      0xc9,
      0xca,
      0xcb,
      0xcd,
      0xce,
      0xcf,
    }.contains(marker);
    if (isStartOfFrame) {
      if (segmentLength < 8) return false;
      final int height = _bigEndianInt(bytes, offset + 3, 2);
      final int width = _bigEndianInt(bytes, offset + 5, 2);
      hasDimensions = width > 0 && height > 0;
    }
    offset += segmentLength;
  }
  return false;
}

bool _hasCompleteIsoMediaBoxes(List<int> bytes) {
  if (bytes.length < 16 ||
      bytes[4] != 0x66 ||
      bytes[5] != 0x74 ||
      bytes[6] != 0x79 ||
      bytes[7] != 0x70) {
    return false;
  }
  var offset = 0;
  var hasMediaBox = false;
  while (offset < bytes.length) {
    if (offset + 8 > bytes.length) return false;
    var boxSize = _bigEndianInt(bytes, offset, 4);
    var headerSize = 8;
    if (boxSize == 1) {
      if (offset + 16 > bytes.length) return false;
      boxSize = _bigEndianInt(bytes, offset + 8, 8);
      headerSize = 16;
    } else if (boxSize == 0) {
      boxSize = bytes.length - offset;
    }
    if (boxSize < headerSize || offset + boxSize > bytes.length) return false;
    final String type =
        String.fromCharCodes(bytes.sublist(offset + 4, offset + 8));
    hasMediaBox = hasMediaBox || type == 'meta' || type == 'mdat';
    offset += boxSize;
  }
  return offset == bytes.length && hasMediaBox;
}

int _bigEndianInt(List<int> bytes, int offset, int length) {
  var value = 0;
  for (var index = 0; index < length; index += 1) {
    value = (value << 8) | bytes[offset + index];
  }
  return value;
}
