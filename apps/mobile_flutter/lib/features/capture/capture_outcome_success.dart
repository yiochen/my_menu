import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/features/capture/capture_outcome_frame.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class CaptureSavedView extends StatelessWidget {
  const CaptureSavedView({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return CaptureOutcomeFrame(
      topLabel: 'Captured',
      headline: 'Got it. You’re done.',
      description: 'MyMenu is finding the right place for this cooking moment.',
      art: const CaptureResultIcon(
        icon: Icons.check_rounded,
        color: MyMenuColors.green,
        background: MyMenuColors.greenSoft,
      ),
      body: const WarmCard(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            CaptureStatusLine(
              icon: Icons.check,
              title: 'Photo saved on this device',
              subtitle: 'Safe even if you close the app',
            ),
            Divider(height: 24),
            CaptureStatusLine(
              icon: Icons.auto_awesome,
              title: 'Organizing now',
              subtitle: 'Checking your 24 dishes for a match',
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
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
  const CaptureCreatedView({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return CaptureOutcomeFrame(
      topLabel: 'Capture organized',
      headline: 'New dish created',
      description: 'It didn’t match your 24 dishes, so MyMenu started a new '
          'living record.',
      art: const CaptureResultIcon(
        icon: Icons.restaurant_menu_rounded,
        color: MyMenuColors.green,
        background: MyMenuColors.greenSoft,
      ),
      body: const WarmCard(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            CaptureStatusLine(
              icon: Icons.ramen_dining_rounded,
              title: 'Charred Corn Ramen',
              subtitle: '1 cook · 1 source photo',
            ),
            Divider(height: 24),
            CaptureStatusLine(
              icon: Icons.auto_awesome,
              title: 'Recipe draft ready to review',
              subtitle: 'Ingredients and steps are waiting',
            ),
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
