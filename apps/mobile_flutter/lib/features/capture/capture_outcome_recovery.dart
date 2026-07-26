import 'package:flutter/material.dart';

import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/capture/add_idea_sheet.dart';
import 'package:mymenu/features/capture/capture_outcome_frame.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class CaptureOfflineView extends StatelessWidget {
  const CaptureOfflineView({
    required this.onClose,
    required this.photoCount,
    super.key,
  });

  final VoidCallback onClose;
  final int photoCount;

  @override
  Widget build(BuildContext context) {
    return CaptureOutcomeFrame(
      topLabel: 'Captured',
      headline: 'Captured—even offline',
      description:
          'Nothing else to do. MyMenu will organize it when a '
          'connection returns.',
      art: const CaptureResultIcon(
        icon: Icons.cloud_off_outlined,
        color: MyMenuColors.muted,
        background: MyMenuColors.oat,
      ),
      body: WarmCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            CaptureStatusLine(
              icon: Icons.check,
              title: photoCount == 1
                  ? 'Photo safe on this device'
                  : '$photoCount photos safe on this device',
              subtitle: 'Available in your capture queue',
            ),
            const Divider(height: 24),
            const CaptureStatusLine(
              icon: Icons.cloud_off_outlined,
              title: 'Organization waiting',
              subtitle: 'Automatic matching needs a connection',
            ),
          ],
        ),
      ),
      footer: const StatusStrip(
        icon: Icons.refresh,
        text: 'Queued · retry happens automatically',
      ),
      onClose: onClose,
    );
  }
}

class CaptureFailedView extends StatelessWidget {
  const CaptureFailedView({
    required this.onRetry,
    required this.onClose,
    this.failureReason,
    super.key,
  });

  final Future<void> Function() onRetry;
  final VoidCallback onClose;
  final String? failureReason;

  @override
  Widget build(BuildContext context) {
    return CaptureOutcomeFrame(
      topLabel: 'Organization paused',
      headline: 'Your photos are still safe',
      description:
          'MyMenu could not organize this batch yet. Nothing was deleted.',
      art: const CaptureResultIcon(
        icon: Icons.error_outline_rounded,
        color: MyMenuColors.red,
        background: MyMenuColors.redSoft,
      ),
      body: WarmCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const CaptureStatusLine(
              icon: Icons.photo_library_outlined,
              title: 'Original captures preserved',
              subtitle: 'Retrying will use the same source photos',
            ),
            if (failureReason case final String reason) ...<Widget>[
              const Divider(height: 24),
              CaptureStatusLine(
                icon: Icons.info_outline,
                title: 'What happened',
                subtitle: reason,
              ),
            ],
          ],
        ),
      ),
      footer: PrimaryPillButton(
        key: const ValueKey<String>('retry_capture_organization'),
        label: 'Retry organization',
        icon: Icons.refresh_rounded,
        onPressed: onRetry,
      ),
      onClose: onClose,
    );
  }
}

class CapturePermissionView extends StatelessWidget {
  const CapturePermissionView({
    required this.state,
    required this.onClose,
    super.key,
  });

  final MyMenuState state;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return CaptureOutcomeFrame(
      topLabel: 'Camera access',
      headline: 'Camera access is off',
      description:
          'Turn it on in Settings to snap food directly. You can '
          'still import a photo or add an idea right now.',
      art: const CaptureResultIcon(
        icon: Icons.no_photography_outlined,
        color: MyMenuColors.red,
        background: MyMenuColors.redSoft,
      ),
      body: Column(
        children: <Widget>[
          CapturePermissionAction(
            icon: Icons.photo_library_outlined,
            title: 'Import Photos',
            subtitle: 'Choose from your library',
            onTap: onClose,
          ),
          const SizedBox(height: 10),
          CapturePermissionAction(
            icon: Icons.edit_outlined,
            title: 'Add Idea',
            subtitle: 'Save a thought instead',
            onTap: () => _addIdea(context),
          ),
        ],
      ),
      footer: const StatusStrip(
        icon: Icons.lock_outline,
        text: 'MyMenu only accesses the camera when you choose Take Photo.',
      ),
      onClose: onClose,
    );
  }

  Future<void> _addIdea(BuildContext context) async {
    final AddIdeaIntent? intent = await showAddIdeaSheet(context);
    if (intent != null) {
      state.addIdea(intent.title);
    }
  }
}
