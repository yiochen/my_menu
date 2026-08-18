import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymenu/app/app_providers.dart';
import 'package:mymenu/core/network/processing_api_client.dart';
import 'package:mymenu/domain/account/service_identity.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/domain/processing/processing_privacy_notice.dart';
import 'package:mymenu/shared/widgets/app_dialog.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

Future<void> showSettingsSheet(
  BuildContext context,
  MyMenuState state,
) =>
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) => _SettingsSheet(state: state),
    );

class _SettingsSheet extends ConsumerStatefulWidget {
  const _SettingsSheet({required this.state});
  final MyMenuState state;
  @override
  ConsumerState<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<_SettingsSheet> {
  bool? _automatic;
  ApiProcessingAllowance? _coverAllowance;
  bool _coverAllowanceLoaded = false;
  bool _erasingLocalMenu = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bool enabled = await widget.state.automaticCoverGenerationEnabled();
    final ApiProcessingAllowance? allowance =
        await widget.state.coverAllowance();
    if (mounted) {
      setState(() {
        _automatic = enabled;
        _coverAllowance = allowance;
        _coverAllowanceLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ServiceIdentityController identityController = ref.watch(
      serviceIdentityControllerProvider,
    );
    final ServiceIdentity identity = identityController.identity;
    final bool busy = identityController.busy || _erasingLocalMenu;
    return WarmPage(
      includeBottomChromeSpace: false,
      topPadding: 10,
      child: Material(
        color: Colors.transparent,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SheetTopBar(
              title: 'Settings',
              closeOnLeft: true,
              onClose: () => Navigator.pop(context),
            ),
            ..._aiSettings(context),
            ..._accountSettings(
              context,
              controller: identityController,
              identity: identity,
              busy: busy,
            ),
            ..._localDataSettings(context, busy: busy),
          ],
        ),
      ),
    );
  }

  List<Widget> _aiSettings(BuildContext context) => <Widget>[
        const SizedBox(height: 14),
        SwitchListTile.adaptive(
          key: const ValueKey<String>('automatic_ai_covers_switch'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Automatic AI covers'),
          subtitle: const Text(
            'Generate once for newly organized or newly added idea Dishes. Existing Dishes are not backfilled.',
          ),
          value: _automatic ?? true,
          onChanged: _automatic == null
              ? null
              : (bool value) async {
                  setState(() => _automatic = value);
                  await widget.state.setAutomaticCoverGenerationEnabled(
                    enabled: value,
                  );
                },
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.verified_user_outlined),
          title: Text(
            widget.state.processingConsentDecision ==
                    ProcessingConsentDecision.accepted
                ? 'AI processing allowed'
                : 'AI processing not allowed',
          ),
          subtitle: const Text(
            'Organization and cover generation have separate free allowances.',
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.image_outlined),
          title: const Text('Cover allowance'),
          subtitle: Text(_coverAllowanceDescription),
        ),
        if (widget.state.processingConsentDecision ==
            ProcessingConsentDecision.accepted)
          TextButton.icon(
            onPressed: () async {
              await widget.state.disableAiProcessing();
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.block),
            label: const Text('Turn off AI processing'),
          ),
      ];

  String get _coverAllowanceDescription {
    if (!_coverAllowanceLoaded) return 'Checking allowance…';
    final ApiProcessingAllowance? allowance = _coverAllowance;
    if (allowance == null) return 'Remaining allowance unavailable offline';
    return switch (allowance.status) {
      ApiProcessingAllowanceStatus.enforcementDisabled =>
        'Allowance enforcement is disabled for this service identity',
      ApiProcessingAllowanceStatus.exhausted =>
        'Free allowance used for the last 30 days',
      ApiProcessingAllowanceStatus.enforced =>
        '${allowance.remaining} of ${allowance.limit} remaining in the last 30 days',
    };
  }

  List<Widget> _accountSettings(
    BuildContext context, {
    required ServiceIdentityController controller,
    required ServiceIdentity identity,
    required bool busy,
  }) =>
      <Widget>[
        const SizedBox(height: 10),
        const Divider(),
        _sectionLabel(context, 'ACCOUNT'),
        ListTile(
          key: const ValueKey<String>('service_identity_status'),
          contentPadding: EdgeInsets.zero,
          leading: Icon(identity.isGuest
              ? Icons.person_outline
              : Icons.account_circle_outlined),
          title: Text(identity.isGuest
              ? 'Guest service identity'
              : identity.email ?? 'Signed account'),
          subtitle: Text(identity.isGuest
              ? 'AI usage is tied to this guest identity. Your menu stays on this device.'
              : 'Signing out or deleting this account does not erase your menu.'),
        ),
        if (identity.isAccount) ...<Widget>[
          ListTile(
            key: const ValueKey<String>('sign_out_account'),
            contentPadding: EdgeInsets.zero,
            enabled: !busy,
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            subtitle: const Text('Continue with a new guest identity.'),
            onTap: busy
                ? null
                : () => _performIdentityAction(controller.signOutToGuest),
          ),
          ListTile(
            key: const ValueKey<String>('delete_service_account'),
            contentPadding: EdgeInsets.zero,
            enabled: !busy,
            leading: const Icon(Icons.person_remove_outlined),
            title: const Text('Delete account'),
            subtitle: const Text(
              'Deletes account, entitlement, AI jobs, and server processing media. Keeps this device menu.',
            ),
            onTap: busy ? null : () => _confirmAndDeleteAccount(controller),
          ),
        ],
      ];

  List<Widget> _localDataSettings(
    BuildContext context, {
    required bool busy,
  }) =>
      <Widget>[
        const Divider(),
        _sectionLabel(context, 'DATA ON THIS DEVICE'),
        ListTile(
          key: const ValueKey<String>('erase_local_menu'),
          contentPadding: EdgeInsets.zero,
          enabled: !busy,
          leading: const Icon(Icons.delete_forever_outlined),
          title: const Text('Erase local menu'),
          subtitle: const Text(
            'Permanently removes dishes, plans, captures, and menu media. Keeps your service identity and AI access.',
          ),
          onTap: busy ? null : _confirmAndEraseLocalMenu,
        ),
      ];

  Widget _sectionLabel(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 2),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
        ),
      );

  Future<void> _performIdentityAction(
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update the account.')),
        );
      }
    }
  }

  Future<void> _confirmAndDeleteAccount(
    ServiceIdentityController controller,
  ) async {
    final bool confirmed = await _showDestructiveConfirmation(
      title: 'Delete account?',
      message: 'Your signed account, entitlement, AI jobs, and server-side '
          'processing media will be permanently deleted. Your local menu and '
          'photos on this device will remain.',
      confirmLabel: 'Delete account',
    );
    if (!confirmed || !mounted) return;
    await _performIdentityAction(controller.deleteAccount);
  }

  Future<void> _confirmAndEraseLocalMenu() async {
    final bool confirmed = await _showDestructiveConfirmation(
      title: 'Erase this device menu?',
      message: 'All dishes, plans, captures, and menu media on this device '
          'will be permanently removed. Your service identity, account, and '
          'AI access will remain.',
      confirmLabel: 'Erase local menu',
    );
    if (!confirmed || !mounted) return;
    setState(() => _erasingLocalMenu = true);
    try {
      await widget.state.eraseLocalMenu();
      if (mounted) Navigator.pop(context);
    } on Object {
      if (mounted) {
        setState(() => _erasingLocalMenu = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not erase the local menu.')),
        );
      }
    }
  }

  Future<bool> _showDestructiveConfirmation({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AppDialog(
            title: title,
            icon: Icons.warning_amber_rounded,
            content: Text(message),
            actions: <AppDialogAction>[
              AppDialogAction(
                label: 'Cancel',
                onPressed: () => Navigator.pop(dialogContext, false),
              ),
              AppDialogAction(
                label: confirmLabel,
                isPrimary: true,
                isDestructive: true,
                onPressed: () => Navigator.pop(dialogContext, true),
              ),
            ],
          ),
        ) ??
        false;
  }
}
