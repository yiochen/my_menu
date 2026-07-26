import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/features/capture/capture_outcome_frame.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class CaptureSavedView extends StatelessWidget {
  const CaptureSavedView({
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
      headline: 'Got it. You’re done.',
      description: photoCount <= 1
          ? 'This cooking moment is safely queued for upload.'
          : 'All $photoCount photos are safely queued in one capture batch.',
      art: const CaptureResultIcon(
        icon: Icons.check_rounded,
        color: MyMenuColors.green,
        background: MyMenuColors.greenSoft,
      ),
      body: WarmCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            CaptureStatusLine(
              icon: Icons.check,
              title: photoCount <= 1
                  ? 'Photo saved on this device'
                  : '$photoCount photos saved on this device',
              subtitle: 'Safe even if you close the app',
            ),
            const Divider(height: 24),
            const CaptureStatusLine(
              icon: Icons.auto_awesome,
              title: 'Upload continues in the background',
              subtitle: 'You can return to Plan or Menu now',
            ),
            const SizedBox(height: 12),
            const LinearProgressIndicator(
              color: MyMenuColors.orange,
              backgroundColor: MyMenuColors.oat2,
            ),
          ],
        ),
      ),
      footer: const StatusStrip(
        icon: Icons.open_in_new,
        text: 'You can leave—MyMenu will show the result when ready.',
      ),
      onClose: onClose,
    );
  }
}

class CaptureMatchedView extends StatelessWidget {
  const CaptureMatchedView({
    required this.dish,
    required this.onClose,
    super.key,
  });

  final Dish dish;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return CaptureOutcomeFrame(
      topLabel: 'Capture organized',
      headline: 'Added to Miso Salmon Bowl',
      description: 'Your photo joined today’s cooking occasion—not a new dish.',
      art: CaptureDishResultArt(dish: dish),
      body: Column(
        children: <Widget>[
          WarmCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                CaptureDishSafeSummary(
                  dish: dish,
                  title: 'Miso Salmon Bowl',
                  subtitle: 'Cook #9 · 13 source photos now',
                ),
                const Divider(height: 24),
                const CaptureStatusLine(
                  icon: Icons.auto_awesome,
                  title: 'Why this match?',
                  subtitle: 'Salmon · bowl · glaze · 94%',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: PrimaryPillButton(
                  label: 'Correct',
                  onPressed: onClose,
                  backgroundColor: MyMenuColors.oat,
                  foregroundColor: MyMenuColors.ink,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryPillButton(
                  label: 'Undo',
                  onPressed: onClose,
                  backgroundColor: MyMenuColors.orangeSoft,
                  foregroundColor: MyMenuColors.orangeDark,
                ),
              ),
            ],
          ),
        ],
      ),
      onClose: onClose,
    );
  }
}

class CaptureCreatedView extends StatelessWidget {
  const CaptureCreatedView({
    required this.onClose,
    this.dishes = const <Dish>[],
    super.key,
  });

  final List<Dish> dishes;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return CaptureOutcomeFrame(
      topLabel: 'Capture organized',
      headline: dishes.length <= 1
          ? 'New dish created'
          : '${dishes.length} dishes created',
      description: dishes.length <= 1
          ? 'MyMenu organized this cooking occasion into a new living record.'
          : 'Photos from different dates became separate cooking occasions.',
      art: const CaptureResultIcon(
        icon: Icons.restaurant_menu_rounded,
        color: MyMenuColors.green,
        background: MyMenuColors.greenSoft,
      ),
      body: WarmCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            if (dishes.isEmpty)
              const CaptureStatusLine(
                icon: Icons.hourglass_top_rounded,
                title: 'Finishing local sync',
                subtitle: 'The created dish will appear in Menu shortly',
              )
            else
              for (int index = 0;
                  index < dishes.length;
                  index += 1) ...<Widget>[
                CaptureStatusLine(
                  icon: Icons.ramen_dining_rounded,
                  title: dishes[index].title,
                  subtitle: '${dishes[index].madeCount} cook · '
                      '${dishes[index].sourcePhotos.length} '
                      '${dishes[index].sourcePhotos.length == 1 ? 'photo' : 'photos'}',
                ),
                if (index != dishes.length - 1) const Divider(height: 24),
              ],
          ],
        ),
      ),
      footer: Row(
        children: <Widget>[
          Expanded(
            child: PrimaryPillButton(label: 'Correct', onPressed: onClose),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PrimaryPillButton(
              label: 'Undo',
              onPressed: onClose,
              backgroundColor: MyMenuColors.oat,
              foregroundColor: MyMenuColors.ink,
            ),
          ),
        ],
      ),
      onClose: onClose,
    );
  }
}
