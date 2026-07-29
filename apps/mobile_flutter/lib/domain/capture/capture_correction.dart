enum CaptureCorrectionType { move, split, assign, assignSplit }

enum CaptureCorrectionStatus { pending, synced, failed, undone }

class CaptureCorrection {
  const CaptureCorrection({
    required this.id,
    required this.batchId,
    required this.type,
    required this.captureIds,
    required this.previousDishIds,
    required this.targetDishId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.createdDishId,
    this.error,
    this.undoneAt,
    this.previouslyUnclassifiedCaptureIds = const <String>{},
    this.previousFailureReasons = const <String, String?>{},
  });

  final String id;
  final String batchId;
  final CaptureCorrectionType type;
  final List<String> captureIds;
  final Map<String, String> previousDishIds;
  final Set<String> previouslyUnclassifiedCaptureIds;
  final Map<String, String?> previousFailureReasons;
  final String targetDishId;
  final String? createdDishId;
  final CaptureCorrectionStatus status;
  final String? error;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? undoneAt;

  bool get isUserAuthored => true;
  bool get canUndo =>
      status == CaptureCorrectionStatus.pending ||
      status == CaptureCorrectionStatus.synced;
}
