import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/local_write_feedback.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

Future<void> showCookAgainSheet(
  BuildContext context,
  MyMenuState state,
  Dish dish,
) async {
  final _CookAgainIntent? intent = await showModalBottomSheet<_CookAgainIntent>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => _CookAgainSheet(dish: dish),
  );
  if (intent == null || !context.mounted) {
    return;
  }
  if (intent.date != null) {
    await runLocalWriteWithFeedback(
      context,
      () => state.addPlannedMeal(
        dayKeyForDate(intent.date!),
        dish.id,
        label: 'Dinner',
      ),
    );
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Cooking occasion started.')),
  );
}

class _CookAgainIntent {
  const _CookAgainIntent.now() : date = null;

  const _CookAgainIntent.plan(this.date);

  final DateTime? date;
}

class _CookAgainSheet extends StatelessWidget {
  const _CookAgainSheet({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return WarmPage(
      includeBottomChromeSpace: false,
      topPadding: 10,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SheetTopBar(
            title: 'Cook again',
            closeOnLeft: true,
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: DishArtwork(dish: dish),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  dish.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Are you cooking now or saving it for another day?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          _ChoiceRow(
            icon: Icons.play_arrow_rounded,
            title: 'I’m cooking now',
            subtitle: 'Open recipe · group today’s photos',
            primary: true,
            onTap: () => Navigator.pop(
              context,
              const _CookAgainIntent.now(),
            ),
          ),
          const SizedBox(height: 10),
          _ChoiceRow(
            icon: Icons.calendar_month_outlined,
            title: 'Plan for later',
            subtitle: 'Choose any day',
            onTap: () => _planLater(context),
          ),
          const SizedBox(height: 16),
          WarmCard(
            color: MyMenuColors.oat,
            shadow: false,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'What becomes a “cook”?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  'One finished cooking occasion. You can add several source '
                  'photos without increasing the made count.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          StatusStrip(
            icon: Icons.check_circle_outline,
            text: 'Your existing ${dish.madeCount} cooks and '
                '${dish.sourcePhotos.length} photos stay unchanged until '
                'you finish.',
            color: MyMenuColors.green,
            background: MyMenuColors.greenSoft,
          ),
        ],
      ),
    );
  }

  Future<void> _planLater(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 7, 25),
      firstDate: DateTime(2026, 7, 20),
      lastDate: DateTime(2026, 10),
    );
    if (date == null || !context.mounted) {
      return;
    }
    Navigator.pop(context, _CookAgainIntent.plan(date));
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
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
    final Color background = primary ? MyMenuColors.orangeAction : Colors.white;
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
              Icon(Icons.chevron_right, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
