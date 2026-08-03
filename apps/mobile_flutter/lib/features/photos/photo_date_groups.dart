import 'package:mymenu/domain/capture/captured_photo.dart';

Map<String, List<CapturedPhoto>> groupPhotosByDate(
  List<CapturedPhoto> photos,
) {
  final Map<String, List<CapturedPhoto>> groups =
      <String, List<CapturedPhoto>>{};
  for (final CapturedPhoto photo in photos) {
    groups.putIfAbsent(photo.dateKey, () => <CapturedPhoto>[]).add(photo);
  }
  return groups;
}

String photoDateLabel(String dateKey) {
  final DateTime? date = DateTime.tryParse(dateKey);
  if (date == null) {
    return dateKey;
  }
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime local = date.toLocal();
  final DateTime day = DateTime(local.year, local.month, local.day);
  if (day == today) {
    return 'Today';
  }
  if (day == today.subtract(const Duration(days: 1))) {
    return 'Yesterday';
  }
  return '${local.month}/${local.day}/${local.year}';
}
