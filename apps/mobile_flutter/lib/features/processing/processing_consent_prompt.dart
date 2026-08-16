import 'package:flutter/material.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/domain/processing/processing_consent_prompt.dart';
import 'package:mymenu/domain/processing/processing_privacy_notice.dart';
import 'package:mymenu/shared/widgets/app_dialog.dart';

class ProcessingConsentPromptHost extends StatefulWidget {
  const ProcessingConsentPromptHost({required this.child, super.key});

  final Widget child;

  @override
  State<ProcessingConsentPromptHost> createState() =>
      _ProcessingConsentPromptHostState();
}

class _ProcessingConsentPromptHostState
    extends State<ProcessingConsentPromptHost> {
  MyMenuState? _state;
  int? _activeRequestId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final MyMenuState next = MyMenuScope.of(context);
    if (!identical(next, _state)) {
      _state?.removeListener(_onStateChanged);
      _state = next..addListener(_onStateChanged);
    }
    _onStateChanged();
  }

  @override
  void dispose() {
    _state?.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showPendingPrompt();
      }
    });
  }

  Future<void> _showPendingPrompt() async {
    final MyMenuState? state = _state;
    final ProcessingConsentRequest? request =
        state?.pendingProcessingConsentRequest;
    if (state == null || request == null || request.id == _activeRequestId) {
      return;
    }
    _activeRequestId = request.id;
    final ProcessingConsentDecision? decision =
        await showDialog<ProcessingConsentDecision>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AppDialog(
        key: const ValueKey<String>('processing_consent_dialog'),
        title: 'Let MyMenu use AI?',
        subtitle: 'Your menu stays saved on this device.',
        icon: Icons.auto_awesome_outlined,
        showCloseButton: false,
        content: const _ProcessingConsentContent(),
        actions: <AppDialogAction>[
          AppDialogAction(
            label: 'Not now',
            icon: Icons.lock_outline,
            onPressed: () => Navigator.pop(
              dialogContext,
              ProcessingConsentDecision.declined,
            ),
          ),
          AppDialogAction(
            label: 'Allow AI processing',
            icon: Icons.auto_awesome,
            isPrimary: true,
            onPressed: () => Navigator.pop(
              dialogContext,
              ProcessingConsentDecision.accepted,
            ),
          ),
        ],
      ),
    );
    if (decision != null) {
      await state.resolveProcessingConsent(decision);
    }
    _activeRequestId = null;
    if (mounted) {
      await _showPendingPrompt();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ProcessingConsentContent extends StatelessWidget {
  const _ProcessingConsentContent();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'MyMenu can send reduced copies of new captures and dish context to '
          'Google Gemini to organize captures and generate improved covers.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        const _PrivacyPoint(
          icon: Icons.phonelink_lock_outlined,
          text: 'Cover generation can include the dish title, every standalone '
              'Note, and up to three Sources you choose. Automatic covers use '
              'up to three newly organized Sources and become the cover when ready.',
        ),
        const SizedBox(height: 9),
        const _PrivacyPoint(
          icon: Icons.cloud_upload_outlined,
          text: 'MyMenu deletes processing content after receipt or within 24 '
              'hours. On Gemini’s free tier, Google may use submitted content '
              'and AI responses to improve its products, and human reviewers '
              'may read or annotate them.',
        ),
        const SizedBox(height: 9),
        const _PrivacyPoint(
          icon: Icons.visibility_off_outlined,
          text: 'For pre-launch testing, submit only food content that is not '
              'sensitive, confidential, or personally identifying.',
        ),
        const SizedBox(height: 9),
        const _PrivacyPoint(
          icon: Icons.receipt_long_outlined,
          text: 'Content-free usage records last up to 90 days and routine '
              'operational logs up to 30 days.',
        ),
        const SizedBox(height: 9),
        const _PrivacyPoint(
          icon: Icons.no_accounts_outlined,
          text: 'AI is optional. Capture and every local menu feature keep '
              'working if you choose Not now. Allowing AI turns automatic '
              'cover generation on by default; you can turn it off later.',
        ),
        const SizedBox(height: 14),
        Text(
          'AI processing privacy notice · '
          '${ProcessingPrivacyNotice.currentVersion}',
          style: textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  const _PrivacyPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 9),
        Expanded(child: Text(text)),
      ],
    );
  }
}
