import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/domain/ai/ai_job.dart';
import 'package:mymenu/features/ai/ai_job_status_card.dart';

void main() {
  testWidgets('renders every durable AI job status',
      (WidgetTester tester) async {
    const Map<AiJobStatus, String> labels = <AiJobStatus, String>{
      AiJobStatus.pendingOffline: 'Saved offline',
      AiJobStatus.queued: 'Queued',
      AiJobStatus.running: 'Processing',
      AiJobStatus.retrying: 'Retrying',
      AiJobStatus.succeeded: 'Completed',
      AiJobStatus.failed: 'Failed',
      AiJobStatus.canceled: 'Canceled',
    };

    for (final MapEntry<AiJobStatus, String> entry in labels.entries) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AiJobStatusCard(job: _job(entry.key))),
        ),
      );

      expect(find.text(entry.value), findsOneWidget);
    }
  });

  testWidgets('failed jobs keep source usable and offer explicit retry',
      (WidgetTester tester) async {
    var retryCount = 0;
    var dismissCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiJobStatusCard(
            job: _job(AiJobStatus.failed),
            onRetry: () => retryCount += 1,
            onDismiss: () => dismissCount += 1,
          ),
        ),
      ),
    );

    expect(
      find.text(
        'The original item is still available. Retry when you are ready.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Retry'));
    await tester.tap(find.text('Dismiss'));

    expect(retryCount, 1);
    expect(dismissCount, 1);
  });

  testWidgets('queued jobs can cancel without blocking the app',
      (WidgetTester tester) async {
    var cancelCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AiJobStatusCard(
            job: _job(AiJobStatus.queued),
            onCancel: () => cancelCount += 1,
          ),
        ),
      ),
    );

    expect(
      find.text('Waiting for AI processing to start.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    expect(cancelCount, 1);
  });
}

AiJob _job(AiJobStatus status) {
  final DateTime now = DateTime.utc(2026, 7, 25, 12);
  return AiJob(
    id: 'job_${status.name}',
    type: AiJobType.recipeEnrichment,
    subjectId: 'dish_1',
    status: status,
    idempotencyKey: 'recipe:dish_1:1',
    inputHash: 'hash',
    inputVersion: '1',
    attemptCount: status == AiJobStatus.pendingOffline ? 0 : 1,
    maxAttempts: 3,
    promptVersion: '1',
    modelVersion: 'default',
    schemaVersion: '1',
    createdAt: now,
    updatedAt: now,
    normalizedError: status == AiJobStatus.failed
        ? const <String, Object?>{'code': 'provider_timeout'}
        : null,
  );
}
