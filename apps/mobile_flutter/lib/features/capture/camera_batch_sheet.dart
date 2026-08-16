import 'package:flutter/material.dart';
import 'package:mymenu/domain/capture/captured_media.dart';
import 'package:mymenu/domain/menu/app_repositories.dart';
import 'package:mymenu/features/capture/capture_media_service.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

enum _CameraBatchIntent { takeAnother, done }

Future<List<CapturedMedia>> collectCameraBatch(
  BuildContext context,
  CaptureMediaService mediaService,
) async {
  final List<CapturedMedia> media = <CapturedMedia>[];
  while (media.length < CaptureRepository.maxBatchItems) {
    final CapturedMedia? captured = await mediaService.takePhoto();
    if (captured == null) {
      break;
    }
    media.add(captured);
    if (!context.mounted) {
      break;
    }
    final _CameraBatchIntent? intent =
        await showModalBottomSheet<_CameraBatchIntent>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) => _CameraBatchReview(
        media: List<CapturedMedia>.unmodifiable(media),
      ),
    );
    if (intent != _CameraBatchIntent.takeAnother) {
      break;
    }
  }
  return media;
}

class _CameraBatchReview extends StatelessWidget {
  const _CameraBatchReview({required this.media});

  final List<CapturedMedia> media;

  @override
  Widget build(BuildContext context) {
    final bool atLimit = media.length >= CaptureRepository.maxBatchItems;
    return WarmPage(
      includeBottomChromeSpace: false,
      topPadding: 10,
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          SheetTopBar(
            title: 'Photos captured',
            onClose: () => Navigator.pop(context, _CameraBatchIntent.done),
          ),
          const SizedBox(height: 16),
          Text(
            '${media.length} of ${CaptureRepository.maxBatchItems}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: media.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: AppImage(
                        imageRef: media[index].path,
                        width: 104,
                        height: 104,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor:
                            MyMenuColors.ink.withValues(alpha: 0.75),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          if (atLimit)
            const StatusStrip(
              icon: Icons.check_circle_outline,
              text: 'Batch limit reached. These 9 photos are ready to save.',
            ),
          if (atLimit) const SizedBox(height: 12),
          Row(
            children: <Widget>[
              if (!atLimit) ...<Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey<String>('camera_take_another'),
                    onPressed: () => Navigator.pop(
                      context,
                      _CameraBatchIntent.takeAnother,
                    ),
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Take another'),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey<String>('camera_done'),
                  onPressed: () =>
                      Navigator.pop(context, _CameraBatchIntent.done),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
