part of 'my_menu_api_client.dart';

class _FakeCaptureRecord {
  _FakeCaptureRecord({
    required this.id,
    required this.batchId,
    required this.ordinal,
    required this.kind,
    required this.status,
    required this.capturedAt,
    required this.capturedLocalDate,
    required this.captureDateSource,
    this.mediaRef,
    this.ideaText,
  });

  final String id;
  final String batchId;
  final int ordinal;
  final String kind;
  String status;
  final DateTime capturedAt;
  final String? capturedLocalDate;
  final String captureDateSource;
  final String? mediaRef;
  final String? ideaText;
  String? appliedDishId;

  ApiCapture toApi() {
    return ApiCapture(
      id: id,
      kind: kind,
      status: status,
      capturedAt: capturedAt,
      batchId: batchId,
      ordinal: ordinal,
      ideaText: ideaText,
      capturedLocalDate: capturedLocalDate,
      captureDateSource: captureDateSource,
      appliedDishId: appliedDishId,
      image: mediaRef == null
          ? null
          : ApiImage(
              id: 'fake-image-$id',
              kind: status == 'applied' ? 'source_photo' : 'capture_photo',
              mediaRef: mediaRef!,
            ),
    );
  }
}
