import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

abstract class CaptureMediaService {
  Future<String?> takePhoto();

  Future<List<String>> importPhotos();
}

class ImagePickerCaptureMediaService implements CaptureMediaService {
  ImagePickerCaptureMediaService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  final Uuid _uuid = const Uuid();

  @override
  Future<String?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
    );
    if (photo == null) {
      return null;
    }

    return _persist(photo);
  }

  @override
  Future<List<String>> importPhotos() async {
    final List<XFile> photos = await _picker.pickMultiImage(
      imageQuality: 92,
      limit: 9,
    );
    if (photos.isEmpty) {
      return const <String>[];
    }

    final List<String> paths = <String>[];
    for (final XFile photo in photos.take(9)) {
      paths.add(await _persist(photo));
    }
    return paths;
  }

  Future<String> _persist(XFile photo) async {
    final Directory documents = await getApplicationDocumentsDirectory();
    final Directory captureDirectory =
        await Directory('${documents.path}/captures').create(recursive: true);
    final String extension = _extensionFor(photo.name);
    final String fileName = 'capture_${_uuid.v4()}$extension';
    final File copied = await File(photo.path).copy(
      '${captureDirectory.path}/$fileName',
    );
    return copied.path;
  }

  String _extensionFor(String name) {
    final int dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == name.length - 1) {
      return '.jpg';
    }
    return name.substring(dotIndex);
  }
}
