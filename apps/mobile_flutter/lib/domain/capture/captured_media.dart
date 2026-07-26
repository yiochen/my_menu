enum CaptureDateSource {
  camera('camera'),
  exifOriginal('exif_original'),
  unknown('unknown');

  const CaptureDateSource(this.apiValue);

  final String apiValue;
}

class CapturedMedia {
  const CapturedMedia({
    required this.path,
    required this.capturedAt,
    required this.capturedLocalDate,
    required this.dateSource,
  });

  final String path;
  final DateTime capturedAt;
  final String? capturedLocalDate;
  final CaptureDateSource dateSource;
}
