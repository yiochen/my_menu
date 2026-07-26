import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/domain/sync/repositories.dart';
import 'package:mymenu/features/capture/capture_media_service.dart';
import 'package:mymenu/features/capture/capture_sheet.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

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
    await tester.tap(find.text('Done'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(state.reviewItems.first.imageRef, '/tmp/mymenu/camera.jpg');
  });

  testWidgets('camera collects three sequential photos before done', (
    WidgetTester tester,
  ) async {
    final (MyMenuState, AppDatabase) fixture = _persistentState();
    final MyMenuState state = fixture.$1;
    addTearDown(fixture.$2.close);
    final _FakeCaptureMediaService mediaService = _FakeCaptureMediaService(
      cameraRefs: const <String>[
        '/tmp/mymenu/one.jpg',
        '/tmp/mymenu/two.jpg',
        '/tmp/mymenu/three.jpg',
      ],
    );

    await tester.pumpWidget(
      _CaptureTestApp(state: state, mediaService: mediaService),
    );
    await tester.tap(find.text('Open capture'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take Photo'));
    await tester.pumpAndSettle();

    expect(find.text('1 of 9'), findsOneWidget);
    await tester.tap(find.text('Take another'));
    await tester.pumpAndSettle();
    expect(find.text('2 of 9'), findsOneWidget);
    await tester.tap(find.text('Take another'));
    await tester.pumpAndSettle();
    expect(find.text('3 of 9'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pump(const Duration(milliseconds: 500));

    final CaptureBatch batch = state.captureBatches.single;
    expect(
      batch.items.map((item) => item.localMediaRef).toList(growable: false),
      <String>[
        '/tmp/mymenu/one.jpg',
        '/tmp/mymenu/two.jpg',
        '/tmp/mymenu/three.jpg',
      ],
    );
    expect(
      batch.items.map((item) => item.ordinal).toList(growable: false),
      <int>[0, 1, 2],
    );
    expect(find.textContaining('All 3 photos'), findsOneWidget);
    state.dispose();
  });

  testWidgets('import keeps the picker-provided order in one intent', (
    WidgetTester tester,
  ) async {
    final (MyMenuState, AppDatabase) fixture = _persistentState();
    final MyMenuState state = fixture.$1;
    addTearDown(fixture.$2.close);
    final _FakeCaptureMediaService mediaService = _FakeCaptureMediaService(
      importRefs: const <String>[
        '/tmp/mymenu/a.jpg',
        '/tmp/mymenu/b.jpg',
        '/tmp/mymenu/c.jpg',
        '/tmp/mymenu/d.jpg',
      ],
    );

    await tester.pumpWidget(
      _CaptureTestApp(state: state, mediaService: mediaService),
    );
    await tester.tap(find.text('Open capture'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import Photos'));
    await tester.pump(const Duration(milliseconds: 500));

    final CaptureBatch batch = state.captureBatches.single;
    expect(
      batch.items.map((item) => item.localMediaRef).toList(growable: false),
      mediaService.importRefs,
    );
    expect(
      batch.items.map((item) => item.ordinal).toList(growable: false),
      <int>[0, 1, 2, 3],
    );
    expect(find.textContaining('All 4 photos'), findsOneWidget);
    state.dispose();
  });
}

(MyMenuState, AppDatabase) _persistentState() {
  final AppDatabase database = AppDatabase.forTesting(NativeDatabase.memory());
  final AppRepositories repositories = AppRepositories(
    database: database,
    apiClient: _ImmediateCaptureApiClient(),
  );
  return (MyMenuState(repositories: repositories), database);
}

class _ImmediateCaptureApiClient extends FakeMyMenuApiClient {
  @override
  Future<String> uploadCaptureMedia({
    required String captureId,
    required String batchId,
    required int ordinal,
    required String localMediaRef,
  }) async {
    return 'fake://captures/$captureId';
  }
}

class _FakeCaptureMediaService implements CaptureMediaService {
  _FakeCaptureMediaService({
    this.cameraRefs = const <String>[],
    this.importRefs = const <String>[],
  });

  final List<String> cameraRefs;
  final List<String> importRefs;
  int _cameraIndex = 0;

  @override
  Future<String?> takePhoto() async {
    if (_cameraIndex >= cameraRefs.length) {
      return null;
    }
    final String result = cameraRefs[_cameraIndex];
    _cameraIndex += 1;
    return result;
  }

  @override
  Future<List<String>> importPhotos() async => importRefs;
}

class _CaptureTestApp extends StatelessWidget {
  const _CaptureTestApp({required this.state, required this.mediaService});

  final MyMenuState state;
  final CaptureMediaService mediaService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showCaptureSheet(context, state, mediaService),
                child: const Text('Open capture'),
              ),
            ),
          );
        },
      ),
    );
  }
}
