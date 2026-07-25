import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/capture/add_idea_sheet.dart';
import 'package:mymenu/features/capture/capture_media_service.dart';
import 'package:mymenu/features/capture/capture_outcome_sheet.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

enum CaptureAction { takePhoto, importPhotos, addIdea }

Future<void> showCaptureSheet(
  BuildContext context,
  MyMenuState state,
  CaptureMediaService mediaService,
) async {
  final CaptureAction? action = await showModalBottomSheet<CaptureAction>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => const _CaptureActionSheet(),
  );
  if (!context.mounted || action == null) {
    return;
  }
  switch (action) {
    case CaptureAction.takePhoto:
      await _captureMedia(
        context,
        state,
        mediaService.takePhoto,
        organizedStep: CaptureOutcomeStep.matched,
      );
    case CaptureAction.importPhotos:
      await _captureMedia(
        context,
        state,
        mediaService.importPhotos,
        organizedStep: CaptureOutcomeStep.created,
      );
    case CaptureAction.addIdea:
      final AddIdeaIntent? intent = await showAddIdeaSheet(context);
      if (intent != null) {
        state.addIdea(intent.title);
      }
  }
}

Future<void> _captureMedia(
  BuildContext context,
  MyMenuState state,
  Future<List<String>> Function() capture, {
  required CaptureOutcomeStep organizedStep,
}) async {
  try {
    final List<String> imageRefs = await capture();
    if (!context.mounted || imageRefs.isEmpty) {
      return;
    }
    state.addPhotoCaptures(imageRefs);
    const String scenario = String.fromEnvironment(
      'MY_MENU_CAPTURE_SCENARIO',
      defaultValue: 'success',
    );
    await showCaptureOutcomeSheet(
      context,
      state: state,
      initialStep: scenario == 'offline'
          ? CaptureOutcomeStep.offline
          : CaptureOutcomeStep.saved,
      organizedStep: organizedStep,
    );
  } on PlatformException catch (_) {
    if (context.mounted) {
      await showCaptureOutcomeSheet(
        context,
        state: state,
        initialStep: CaptureOutcomeStep.permission,
        organizedStep: organizedStep,
      );
    }
  } on Exception catch (_) {
    if (context.mounted) {
      await showCaptureOutcomeSheet(
        context,
        state: state,
        initialStep: CaptureOutcomeStep.permission,
        organizedStep: organizedStep,
      );
    }
  }
}

class _CaptureActionSheet extends StatelessWidget {
  const _CaptureActionSheet();

  @override
  Widget build(BuildContext context) {
    return WarmPage(
      includeBottomChromeSpace: false,
      topPadding: 10,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          SheetTopBar(
            title: 'Capture',
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: MyMenuColors.orangeSoft,
              borderRadius: BorderRadius.circular(29),
            ),
            child: const Icon(
              Icons.photo_camera_outlined,
              size: 42,
              color: MyMenuColors.orange,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Save it while it’s fresh',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 7),
          Text(
            'Snap first. MyMenu can sort out where it belongs afterward.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          _CaptureActionTile(
            icon: Icons.camera_alt_outlined,
            title: 'Take Photo',
            subtitle: 'Fastest — point, snap, done',
            primary: true,
            onTap: () => Navigator.pop(context, CaptureAction.takePhoto),
          ),
          const SizedBox(height: 10),
          _CaptureActionTile(
            icon: Icons.photo_library_outlined,
            title: 'Import Photos',
            subtitle: 'Bring in one or a few',
            onTap: () => Navigator.pop(context, CaptureAction.importPhotos),
          ),
          const SizedBox(height: 10),
          _CaptureActionTile(
            icon: Icons.edit_outlined,
            title: 'Add Idea',
            subtitle: 'Save a thought for later',
            onTap: () => Navigator.pop(context, CaptureAction.addIdea),
          ),
          const SizedBox(height: 14),
          const StatusStrip(
            icon: Icons.check_circle_outline,
            text: 'Captures save locally, even without signal.',
            color: MyMenuColors.green,
            background: MyMenuColors.greenSoft,
          ),
        ],
      ),
    );
  }
}

class _CaptureActionTile extends StatelessWidget {
  const _CaptureActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final Color background =
        primary ? MyMenuColors.orangeAction : MyMenuColors.surface;
    final Color foreground = primary ? Colors.white : MyMenuColors.ink;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minHeight: 78),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primary ? const Color(0x2FFFFFFF) : MyMenuColors.oat,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(icon, color: foreground),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: foreground,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                primary ? Colors.white70 : MyMenuColors.muted,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
