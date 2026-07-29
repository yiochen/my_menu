import 'package:flutter/material.dart';
import 'package:mymenu/domain/ai/ai_job.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

class AiJobStatusCard extends StatelessWidget {
  const AiJobStatusCard({
    required this.job,
    this.onRetry,
    this.onCancel,
    this.onDismiss,
    this.onOpenResult,
    super.key,
  });

  final AiJob job;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;
  final VoidCallback? onDismiss;
  final VoidCallback? onOpenResult;

  @override
  Widget build(BuildContext context) {
    final _AiJobDisplay display = _displayFor(job.status);
    return Card(
      key: ValueKey<String>('ai_job_${job.id}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpenResult,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(display.icon, size: 20, color: display.foreground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job.type.displayLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _StatusPill(display: display),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                onOpenResult == null
                    ? _detailLabel(job)
                    : 'The result is ready. Tap to review or correct it.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (job.modelVersion != 'default' &&
                  job.modelVersion != 'server-selected') ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  job.runtimeLabel,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
              if (job.errorMessage case final String errorMessage) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  errorMessage,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.red.shade800),
                ),
              ],
              if (onOpenResult != null) ...<Widget>[
                const SizedBox(height: 10),
                const _OpenResultLink(),
              ],
              if (_hasAction(job)) ...<Widget>[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    if (job.status.canRetry && onRetry != null)
                      FilledButton.icon(
                        key: ValueKey<String>('retry_ai_job_${job.id}'),
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    if (job.status.canCancel && onCancel != null)
                      TextButton(
                        key: ValueKey<String>('cancel_ai_job_${job.id}'),
                        onPressed: onCancel,
                        child: const Text('Cancel'),
                      ),
                    if (job.status.canDismiss && onDismiss != null)
                      TextButton(
                        key: ValueKey<String>('dismiss_ai_job_${job.id}'),
                        onPressed: onDismiss,
                        child: const Text('Dismiss'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _hasAction(AiJob job) {
    return (job.status.canRetry && onRetry != null) ||
        (job.status.canCancel && onCancel != null) ||
        (job.status.canDismiss && onDismiss != null);
  }
}

class _OpenResultLink extends StatelessWidget {
  const _OpenResultLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          'Open result',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: MyMenuColors.orangeDark,
              ),
        ),
        const Spacer(),
        const Icon(
          Icons.chevron_right_rounded,
          color: MyMenuColors.orangeDark,
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.display});

  final _AiJobDisplay display;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: display.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          display.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: display.foreground,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class _AiJobDisplay {
  const _AiJobDisplay(this.label, this.icon, this.foreground, this.background);

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
}

_AiJobDisplay _displayFor(AiJobStatus status) {
  return switch (status) {
    AiJobStatus.pendingOffline => const _AiJobDisplay(
        'Saved offline',
        Icons.cloud_off_outlined,
        MyMenuColors.orangeDark,
        MyMenuColors.orangeSoft,
      ),
    AiJobStatus.queued => const _AiJobDisplay(
        'Queued',
        Icons.schedule_rounded,
        MyMenuColors.orangeDark,
        MyMenuColors.orangeSoft,
      ),
    AiJobStatus.running => const _AiJobDisplay(
        'Processing',
        Icons.auto_awesome,
        MyMenuColors.orangeDark,
        MyMenuColors.orangeSoft,
      ),
    AiJobStatus.retrying => const _AiJobDisplay(
        'Retrying',
        Icons.sync_rounded,
        MyMenuColors.orangeDark,
        MyMenuColors.orangeSoft,
      ),
    AiJobStatus.succeeded => const _AiJobDisplay(
        'Completed',
        Icons.check_circle_outline_rounded,
        MyMenuColors.green,
        MyMenuColors.greenSoft,
      ),
    AiJobStatus.failed => _AiJobDisplay(
        'Failed',
        Icons.error_outline_rounded,
        Colors.red.shade800,
        Colors.red.shade50,
      ),
    AiJobStatus.canceled => const _AiJobDisplay(
        'Canceled',
        Icons.cancel_outlined,
        MyMenuColors.muted,
        MyMenuColors.oat,
      ),
  };
}

String _detailLabel(AiJob job) {
  return switch (job.status) {
    AiJobStatus.pendingOffline =>
      'Saved on this device. It will start when a connection is available.',
    AiJobStatus.queued => 'Waiting for AI processing to start.',
    AiJobStatus.running =>
      'AI is working in the background. You can keep using MyMenu.',
    AiJobStatus.retrying => job.nextRetryAt == null
        ? 'A temporary problem occurred. Retrying automatically.'
        : 'A temporary problem occurred. The next attempt is scheduled.',
    AiJobStatus.succeeded => 'The result is saved and ready to use.',
    AiJobStatus.failed =>
      'The original item is still available. Retry when you are ready.',
    AiJobStatus.canceled => 'This AI request was canceled.',
  };
}
