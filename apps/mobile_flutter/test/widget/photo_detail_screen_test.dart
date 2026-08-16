import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/capture/captured_photo.dart';
import 'package:mymenu/features/photos/photo_detail_screen.dart';
import 'package:mymenu/shared/theme/app_theme.dart';

void main() {
  testWidgets('failed photo explains an exhausted organization allowance',
      (WidgetTester tester) async {
    final CapturedPhoto photo = _quotaPhoto();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.data,
        home: PhotoDetailScreen(
          photo: photo,
          dishes: const [],
          batchSiblingCount: 2,
          canUndo: false,
        ),
      ),
    );

    expect(
      find.textContaining('all 10 free AI organizations'),
      findsOneWidget,
    );
    expect(find.textContaining('last 30 days'), findsOneWidget);
    expect(find.text('Add to a dish'), findsOneWidget);
    expect(find.text('Create a new dish'), findsOneWidget);
    expect(find.text('Try organizing again'), findsOneWidget);
  });

  testWidgets('failed retry immediately shows the failure reason',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => FilledButton(
              onPressed: () => showPhotoRetryFailure(context, _quotaPhoto()),
              child: const Text('Show retry result'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show retry result'));
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('photo_retry_failure_message')),
      findsOneWidget,
    );
    expect(
      find.textContaining('all 10 free AI organizations'),
      findsOneWidget,
    );
  });
}

CapturedPhoto _quotaPhoto() => CapturedPhoto(
      item: CaptureItem(
        id: 'capture-quota',
        batchId: 'batch-quota',
        kind: CaptureItemKind.photo,
        status: CaptureItemStatus.failed,
        createdAt: DateTime(2026, 8, 11),
        failureReason: 'The free processing allowance is used.',
      ),
      state: CapturedPhotoState.failed,
      dateKey: '2026-08-11',
      processingFailureCode: 'free_allowance_exhausted',
    );
