import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/capture/capture_media_service.dart';
import 'package:mymenu/features/capture/capture_sheet.dart';

void main() {
  testWidgets('shows capture-first actions without mock labels', (
    WidgetTester tester,
  ) async {
    final MyMenuState state = MyMenuState();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => showCaptureSheet(
                    context,
                    state,
                    _FakeCaptureMediaService(),
                  ),
                  child: const Text('Open capture'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open capture'));
    await tester.pumpAndSettle();

    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Import Photos'), findsOneWidget);
    expect(find.text('Add Idea'), findsOneWidget);
    expect(find.text('Mock photo capture'), findsNothing);
    expect(find.text('Add dish idea'), findsNothing);
  });

  testWidgets('take photo action saves a review item', (
    WidgetTester tester,
  ) async {
    final MyMenuState state = MyMenuState();
    final _FakeCaptureMediaService mediaService = _FakeCaptureMediaService(
      cameraRefs: const <String>['/tmp/mymenu/camera.jpg'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => showCaptureSheet(
                    context,
                    state,
                    mediaService,
                  ),
                  child: const Text('Open capture'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open capture'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take Photo'));
    await tester.pumpAndSettle();

    expect(state.reviewItems.first.imageRef, '/tmp/mymenu/camera.jpg');
  });
}

class _FakeCaptureMediaService implements CaptureMediaService {
  _FakeCaptureMediaService({
    this.cameraRefs = const <String>[],
  });

  final List<String> cameraRefs;

  @override
  Future<List<String>> takePhoto() async => cameraRefs;

  @override
  Future<List<String>> importPhotos() async => const <String>[];
}
