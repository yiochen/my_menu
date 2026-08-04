import 'package:flutter/material.dart';

import 'package:mymenu/domain/processing/processing_privacy_notice.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

Future<void> showAiSettingsSheet(
  BuildContext context,
  MyMenuState state,
) =>
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) => _AiSettingsSheet(state: state),
    );

class _AiSettingsSheet extends StatefulWidget {
  const _AiSettingsSheet({required this.state});
  final MyMenuState state;
  @override
  State<_AiSettingsSheet> createState() => _AiSettingsSheetState();
}

class _AiSettingsSheetState extends State<_AiSettingsSheet> {
  bool? _automatic;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bool enabled = await widget.state.automaticCoverGenerationEnabled();
    if (mounted) setState(() => _automatic = enabled);
  }

  @override
  Widget build(BuildContext context) => WarmPage(
        includeBottomChromeSpace: false,
        topPadding: 10,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SheetTopBar(
              title: 'AI settings',
              closeOnLeft: true,
              onClose: () => Navigator.pop(context),
            ),
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
          ],
        ),
      );
}
