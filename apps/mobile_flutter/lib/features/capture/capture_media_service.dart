import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

abstract class CaptureMediaService {
  Future<List<String>> takePhoto();

  Future<List<String>> importPhotos();
}

class ImagePickerCaptureMediaService implements CaptureMediaService {
  ImagePickerCaptureMediaService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<List<String>> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
    );
    if (photo == null) {
      return const <String>[];
    }

    return <String>[await _persist(photo)];
  }

  @override
  Future<List<String>> importPhotos() async {
    final List<XFile> photos = await _picker.pickMultiImage(imageQuality: 92);
    if (photos.isEmpty) {
      return const <String>[];
    }

    final List<String> paths = <String>[];
    for (final XFile photo in photos) {
      paths.add(await _persist(photo));
    }
    return paths;
  }

  Future<String> _persist(XFile photo) async {
    final Directory documents = await getApplicationDocumentsDirectory();
    final Directory captureDirectory =
        await Directory('${documents.path}/captures').create(recursive: true);
    final String extension = _extensionFor(photo.name);
    final String fileName =
        'capture_${DateTime.now().microsecondsSinceEpoch}$extension';
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
