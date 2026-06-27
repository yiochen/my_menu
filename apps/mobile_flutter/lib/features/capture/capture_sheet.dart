import 'package:flutter/material.dart';

import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/capture/capture_media_service.dart';
import 'package:mymenu/shared/widgets/text_prompt_dialog.dart';

enum CaptureAction {
  takePhoto,
  importPhotos,
  addIdea,
}

Future<void> showCaptureSheet(
  BuildContext context,
  MyMenuState state,
  CaptureMediaService mediaService,
) async {
  final CaptureAction? action = await showModalBottomSheet<CaptureAction>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFFFFFCF7),
    barrierColor: Colors.black.withValues(alpha: 0.55),
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Capture',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontSize: 42,
                                  color: const Color(0xFF143E24),
                                ),
                      ),
                    ),
                    IconButton.outlined(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Add a photo or idea.\nWe'll organize it for you.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        height: 1.35,
                        color: const Color(0xFF596174),
                      ),
                ),
                const SizedBox(height: 28),
                _CaptureActionTile(
                  icon: Icons.camera_alt,
                  title: 'Take Photo',
                  subtitle: 'Snap a photo of your dish right now.',
                  onTap: () =>
                      Navigator.of(sheetContext).pop(CaptureAction.takePhoto),
                ),
                const SizedBox(height: 14),
                _CaptureActionTile(
                  icon: Icons.photo_size_select_actual_outlined,
                  title: 'Import Photos',
                  subtitle: 'Choose from your library or gallery.',
                  onTap: () => Navigator.of(sheetContext)
                      .pop(CaptureAction.importPhotos),
                ),
                const SizedBox(height: 14),
                _CaptureActionTile(
                  icon: Icons.edit_outlined,
                  title: 'Add Idea',
                  subtitle: 'Note a dish you want to make or remember.',
                  onTap: () =>
                      Navigator.of(sheetContext).pop(CaptureAction.addIdea),
                ),
                const SizedBox(height: 24),
                const _CaptureAiNote(),
                SizedBox(height: MediaQuery.paddingOf(context).bottom),
              ],
            ),
          ),
        ),
      );
    },
  );

  if (!context.mounted || action == null) {
    return;
  }

  switch (action) {
    case CaptureAction.takePhoto:
      await _savePhotoCaptures(
        context,
        state,
        () => mediaService.takePhoto(),
      );
    case CaptureAction.importPhotos:
      await _savePhotoCaptures(
        context,
        state,
        () => mediaService.importPhotos(),
      );
    case CaptureAction.addIdea:
      final String? idea = await showTextPromptDialog(
        context,
        title: 'Add Idea',
        hint: 'Lemongrass chicken bowls',
        autofocus: true,
      );
      if (idea != null) {
        state.addIdea(idea);
      }
  }
}

Future<void> _savePhotoCaptures(
  BuildContext context,
  MyMenuState state,
  Future<List<String>> Function() loadImageRefs,
) async {
  try {
    final List<String> imageRefs = await loadImageRefs();
    if (!context.mounted || imageRefs.isEmpty) {
      return;
    }

    state.addPhotoCaptures(imageRefs);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          imageRefs.length == 1
              ? 'Saved photo for review.'
              : 'Saved ${imageRefs.length} photos for review.',
        ),
      ),
    );
  } on Exception catch (_) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo capture did not complete.')),
    );
  }
}

class _CaptureAiNote extends StatelessWidget {
  const _CaptureAiNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F2E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.auto_awesome,
            color: Color(0xFFC47B00),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: 'AI will match it to a dish',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextSpan(
                    text: '\nor create a new one.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF596174),
                        ),
                  ),
                ],
              ),
            ),
          ),
          const Icon(
            Icons.restaurant,
            color: Color(0xFF174B2A),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFFF8F2E8),
                child: Icon(
                  icon,
                  color: const Color(0xFF174B2A),
                  size: 34,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 24,
                                color: Colors.black,
                              ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            color: const Color(0xFF596174),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFC47B00),
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
