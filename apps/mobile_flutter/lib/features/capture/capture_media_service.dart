import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymenu/core/debug/debug_controls.dart';
import 'package:mymenu/domain/capture/captured_media.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

abstract class CaptureMediaService {
  Future<CapturedMedia?> takePhoto();

  Future<List<CapturedMedia>> importPhotos();
}

class DebugGatedCaptureMediaService implements CaptureMediaService {
  const DebugGatedCaptureMediaService(this._delegate, this._controls);

  final CaptureMediaService _delegate;
  final DebugControlsController _controls;

  @override
  Future<CapturedMedia?> takePhoto() {
    if (!_controls.cameraAccessEnabled) {
      throw PlatformException(
        code: 'debug_camera_access_disabled',
        message: 'Camera access disabled by debug controls.',
      );
    }
    return _delegate.takePhoto();
  }

  @override
  Future<List<CapturedMedia>> importPhotos() => _delegate.importPhotos();
}

class ImagePickerCaptureMediaService implements CaptureMediaService {
  ImagePickerCaptureMediaService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  final Uuid _uuid = const Uuid();

  @override
  Future<CapturedMedia?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (photo == null) {
      return null;
    }

    final DateTime now = DateTime.now();
    return CapturedMedia(
      path: await _persist(photo),
      capturedAt: now,
      capturedLocalDate: _dateKey(now),
      dateSource: CaptureDateSource.camera,
    );
  }

  @override
  Future<List<CapturedMedia>> importPhotos() async {
    final List<XFile> photos = await _picker.pickMultiImage(
      limit: 9,
    );
    if (photos.isEmpty) {
      return const <CapturedMedia>[];
    }

    final List<CapturedMedia> media = <CapturedMedia>[];
    for (final XFile photo in photos.take(9)) {
      final DateTime? originalDate = await _originalDate(photo.path);
      media.add(
        CapturedMedia(
          path: await _persist(photo),
          capturedAt: originalDate ?? DateTime.now(),
          capturedLocalDate:
              originalDate == null ? null : _dateKey(originalDate),
          dateSource: originalDate == null
              ? CaptureDateSource.unknown
              : CaptureDateSource.exifOriginal,
        ),
      );
    }
    return media;
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

  Future<DateTime?> _originalDate(String path) async {
    Exif? exif;
    try {
      exif = await Exif.fromPath(path);
      return await exif.getOriginalDate();
    } on Object {
      return null;
    } finally {
      await exif?.close();
    }
  }

  String _dateKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _extensionFor(String name) {
    final int dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == name.length - 1) {
      return '.jpg';
    }
    return name.substring(dotIndex);
  }
}
