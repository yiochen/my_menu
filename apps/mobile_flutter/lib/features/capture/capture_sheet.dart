import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/captured_media.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/capture/add_idea_sheet.dart';
import 'package:mymenu/features/capture/camera_batch_sheet.dart';
import 'package:mymenu/features/capture/capture_feed_sheet.dart';
import 'package:mymenu/features/capture/capture_media_service.dart';
import 'package:mymenu/features/capture/capture_outcome_sheet.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

enum CaptureAction { takePhoto, importPhotos, addIdea, recentCaptures }

Future<void> showCaptureSheet(
  BuildContext context,
  MyMenuState state,
  CaptureMediaService mediaService,
) async {
  final CaptureAction? action = await showGeneralDialog<CaptureAction>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close Capture',
    barrierColor: const Color(0x52000000),
    transitionDuration: const Duration(milliseconds: 460),
    pageBuilder: (_, __, ___) => BottomSheet(
      onClosing: () {},
      enableDrag: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => _CaptureActionSheet(
        hasCaptures:
            state.captureBatches.isNotEmpty || state.captureItems.isNotEmpty,
      ),
    ),
    transitionBuilder: (_, Animation<double> animation, __, Widget child) =>
        _CaptureSheetTransition(animation: animation, child: child),
  );
  if (!context.mounted || action == null) {
    return;
  }
  switch (action) {
    case CaptureAction.takePhoto:
      await _captureMedia(
        context,
        state,
        () => collectCameraBatch(context, mediaService),
      );
    case CaptureAction.importPhotos:
      await _captureMedia(
        context,
        state,
        mediaService.importPhotos,
      );
    case CaptureAction.addIdea:
      final AddIdeaIntent? intent = await showAddIdeaSheet(context);
      if (intent != null) {
        state.addIdea(intent.title);
      }
    case CaptureAction.recentCaptures:
      await showCaptureFeedSheet(context, state);
  }
}

class _CaptureSheetTransition extends StatelessWidget {
  const _CaptureSheetTransition({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final CurvedAnimation progress = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final double safeBottom = MediaQuery.paddingOf(context).bottom;

    return AnimatedBuilder(
      animation: progress,
      builder: (BuildContext context, _) {
        final double t = progress.value;
        final Size size = MediaQuery.sizeOf(context);
        final double sheetHeight = ui.lerpDouble(
          62,
          math.min(size.height * 0.88, 650),
          t,
        )!;
        final double sheetWidth = ui.lerpDouble(62, size.width, t)!;
        final double bottom = ui.lerpDouble(safeBottom + 29, 0, t)!;
        final double radius = ui.lerpDouble(31, 28, t)!;
        final double contentOpacity = Curves.easeIn.transform(
          ((t - 0.24) / 0.76).clamp(0, 1),
        );

        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottom),
            child: Container(
              width: sheetWidth,
              height: sheetHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: Color.lerp(
                  MyMenuColors.orangeAction,
                  MyMenuColors.cream,
                  Curves.easeInOut.transform(t),
                ),
                border: Border.all(
                  color: Color.lerp(
                    MyMenuColors.cream,
                    Colors.transparent,
                    Curves.easeIn.transform(t),
                  )!,
                  width: ui.lerpDouble(6, 0, t)!,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  OverflowBox(
                    minWidth: size.width,
                    maxWidth: size.width,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: size.width,
                      height: sheetHeight,
                      child: Opacity(
                        opacity: contentOpacity,
                        child: IgnorePointer(
                          ignoring: contentOpacity < 1,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 1 - Curves.easeIn.transform(t),
                    child: const Icon(
                      Icons.add,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> _captureMedia(
  BuildContext context,
  MyMenuState state,
  Future<List<CapturedMedia>> Function() capture,
) async {
  try {
    final List<CapturedMedia> capturedMedia = await capture();
    if (!context.mounted || capturedMedia.isEmpty) {
      return;
    }
    final CaptureBatch? batch = await state.addPhotoCaptures(capturedMedia);
    if (!context.mounted) {
      return;
    }
    if (batch != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            capturedMedia.length == 1
                ? 'Photo is uploading. A dish placeholder shows its progress.'
                : '${capturedMedia.length} photos are uploading. A dish '
                    'placeholder shows their progress.',
          ),
        ),
      );
    }
  } on PlatformException catch (_) {
    if (context.mounted) {
      await showCaptureOutcomeSheet(
        context,
        state: state,
        initialStep: CaptureOutcomeStep.permission,
        organizedStep: CaptureOutcomeStep.created,
        photoCount: 0,
      );
    }
  } on Exception catch (_) {
    if (context.mounted) {
      await showCaptureOutcomeSheet(
        context,
        state: state,
        initialStep: CaptureOutcomeStep.permission,
        organizedStep: CaptureOutcomeStep.created,
        photoCount: 0,
      );
    }
  }
}

class _CaptureActionSheet extends StatelessWidget {
  const _CaptureActionSheet({required this.hasCaptures});

  final bool hasCaptures;

  @override
  Widget build(BuildContext context) {
    return WarmPage(
      includeBottomChromeSpace: false,
      topPadding: 10,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          SheetTopBar(title: 'Capture', onClose: () => Navigator.pop(context)),
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
          if (hasCaptures) ...<Widget>[
            const SizedBox(height: 10),
            _CaptureActionTile(
              icon: Icons.collections_outlined,
              title: 'Recent Captures',
              subtitle: 'Check upload status or retry a photo',
              onTap: () => Navigator.pop(context, CaptureAction.recentCaptures),
            ),
          ],
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
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: foreground),
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
