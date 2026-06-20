import 'dart:async';
import 'dart:math';

class ApiCaptureResult {
  const ApiCaptureResult({
    required this.captureId,
    required this.dishId,
    required this.title,
    required this.description,
    required this.mediaRef,
    required this.category,
  });

  final String captureId;
  final String dishId;
  final String title;
  final String description;
  final String mediaRef;
  final String category;
}

abstract class MyMenuApiClient {
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String localMediaRef,
  });

  Future<ApiCaptureResult> classifyCapture({
    required String captureId,
    required String? remoteMediaRef,
    required String? ideaText,
  });
}

class FakeMyMenuApiClient implements MyMenuApiClient {
  FakeMyMenuApiClient({Random? random}) : _random = random ?? Random(7);

  final Random _random;

  static const List<String> _dishNames = <String>[
    'Golden Garlic Noodles',
    'Miso Market Bowl',
    'Sunday Pepper Chicken',
    'Bright Herb Rice',
    'Sesame Garden Pasta',
    'Tomato Butter Beans',
  ];

  @override
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String localMediaRef,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return 'fake://captures/$captureId';
  }

  @override
  Future<ApiCaptureResult> classifyCapture({
    required String captureId,
    required String? remoteMediaRef,
    required String? ideaText,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final String title = ideaText == null || ideaText.trim().isEmpty
        ? _dishNames[_random.nextInt(_dishNames.length)]
        : _titleCase(ideaText);
    return ApiCaptureResult(
      captureId: captureId,
      dishId: 'dish_$captureId',
      title: title,
      description: 'Created from a synced capture.',
      mediaRef: remoteMediaRef ?? '',
      category: 'Mains',
    );
  }

  String _titleCase(String input) {
    return input
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
