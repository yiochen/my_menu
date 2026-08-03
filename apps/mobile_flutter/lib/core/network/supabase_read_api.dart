part of 'my_menu_api_client.dart';

mixin SupabaseReadApi on MyMenuApiClient {
  Future<void> _ensureSession();

  Future<Map<String, Object?>> _invokeJson(
    String functionName,
    Map<String, Object?> body,
  );

  @override
  Future<List<ApiCapture>> getCaptures(List<String> ids) async {
    if (ids.isEmpty) {
      return const <ApiCapture>[];
    }
    await _ensureSession();

    final Map<String, Object?> data = await _invokeJson(
      'get-captures',
      <String, Object?>{'ids': ids},
    );
    return apiListValue(
      data,
      'items',
    ).map(apiCaptureFromJson).toList(growable: false);
  }

  @override
  Future<List<ApiDish>> getDishes(List<String> ids) async {
    if (ids.isEmpty) {
      return const <ApiDish>[];
    }
    await _ensureSession();

    final Map<String, Object?> data = await _invokeJson(
      'get-dishes',
      <String, Object?>{'ids': ids},
    );
    return apiListValue(
      data,
      'items',
    ).map(apiDishFromJson).toList(growable: false);
  }

  @override
  Future<List<ApiReviewItem>> getReviewItems(List<String> ids) async {
    if (ids.isEmpty) {
      return const <ApiReviewItem>[];
    }
    await _ensureSession();

    final Map<String, Object?> data = await _invokeJson(
      'get-review-items',
      <String, Object?>{'ids': ids},
    );
    return apiListValue(
      data,
      'items',
    ).map(apiReviewItemFromJson).toList(growable: false);
  }
}
