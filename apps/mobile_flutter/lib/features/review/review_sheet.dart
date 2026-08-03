import 'package:flutter/material.dart';

import 'package:mymenu/domain/capture/review_item.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/review/review_alternate_search.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/local_write_feedback.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

Future<void> showReviewSheet(BuildContext context, MyMenuState state) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => ReviewFlow(state: state),
  );
}

class ReviewFlow extends StatefulWidget {
  const ReviewFlow({required this.state, super.key});

  final MyMenuState state;

  @override
  State<ReviewFlow> createState() => _ReviewFlowState();
}

class _ReviewFlowState extends State<ReviewFlow> {
  bool _makeNew = false;
  bool _searching = false;
  String _query = 'spicy salmon pasta';

  @override
  Widget build(BuildContext context) {
    final List<ReviewItem> items = widget.state.reviewItems;
    if (items.isEmpty) {
      return const _ReviewComplete();
    }
    final ReviewItem item = items.first;
    final String? suggestedId = item.suggestedDishIds.firstOrNull;
    final Dish? suggested =
        suggestedId == null ? null : widget.state.dishById(suggestedId);
    final bool makeNew = _makeNew || suggested == null;
    return FractionallySizedBox(
      heightFactor: 0.97,
      child: _searching
          ? AlternateDishSearch(
              state: widget.state,
              query: _query,
              onQueryChanged: (String value) => setState(() => _query = value),
              onBack: () => setState(() => _searching = false),
              onSelect: (Dish dish) async {
                await widget.state.resolveReviewToDish(item.id, dish.id);
                if (!mounted) return;
                setState(() {
                  _query = '';
                  _searching = false;
                });
              },
              onMakeNew: () async {
                final bool saved = await runLocalWriteWithFeedback(
                  context,
                  () => widget.state.createDishFromReview(item.id),
                );
                if (saved && mounted) {
                  setState(() => _searching = false);
                }
              },
            )
          : _ReviewDecision(
              item: item,
              suggested: suggested,
              totalCount: items.length,
              makeNew: makeNew,
              onClose: () => Navigator.pop(context),
              onChooseMatch: () => setState(() => _makeNew = false),
              onChooseNew: () => setState(() => _makeNew = true),
              onChooseDifferent: () => setState(() => _searching = true),
              onConfirm: () async {
                if (makeNew) {
                  final bool saved = await runLocalWriteWithFeedback(
                    context,
                    () => widget.state.createDishFromReview(item.id),
                  );
                  if (!saved) {
                    return;
                  }
                } else {
                  await widget.state.resolveReviewToDish(
                    item.id,
                    suggested.id,
                  );
                }
                if (mounted) {
                  setState(() {});
                }
              },
            ),
    );
  }
}

class _ReviewDecision extends StatelessWidget {
  const _ReviewDecision({
    required this.item,
    required this.suggested,
    required this.totalCount,
    required this.makeNew,
    required this.onClose,
    required this.onChooseMatch,
    required this.onChooseNew,
    required this.onChooseDifferent,
    required this.onConfirm,
  });

  final ReviewItem item;
  final Dish? suggested;
  final int totalCount;
  final bool makeNew;
  final VoidCallback onClose;
  final VoidCallback onChooseMatch;
  final VoidCallback onChooseNew;
  final VoidCallback onChooseDifferent;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return WarmPage(
      includeBottomChromeSpace: false,
      topPadding: 10,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _ReviewHeader(totalCount: totalCount, onClose: onClose),
          const SizedBox(height: 12),
          const LinearProgressIndicator(
            value: 0.5,
            minHeight: 6,
            borderRadius: BorderRadius.all(Radius.circular(999)),
            color: MyMenuColors.orange,
            backgroundColor: MyMenuColors.oat2,
          ),
          const SizedBox(height: 16),
          Text(
            'Where should this go?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 7),
          Text(
            suggested == null
                ? item.summary
                : 'We found a close match, but you know your cooking best.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          _ReviewPhoto(dish: suggested, item: item),
          const SizedBox(height: 12),
          if (suggested != null) ...<Widget>[
            _ReviewChoice(
              selected: !makeNew,
              title: 'Add to ${suggested!.title}',
              subtitle: 'Keeps this cooking occasion together',
              onTap: onChooseMatch,
            ),
            const SizedBox(height: 10),
          ],
          _ReviewChoice(
            selected: makeNew,
            title: 'Make a new dish',
            subtitle: 'Start a separate recipe and history',
            onTap: onChooseNew,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onChooseDifferent,
              child: const Text('Choose a different dish'),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryPillButton(
            label: makeNew ? 'Create new dish' : 'Confirm match',
            icon: Icons.arrow_forward,
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({required this.totalCount, required this.onClose});

  final int totalCount;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleIconButton(
          icon: Icons.close,
          size: 40,
          radius: 14,
          onPressed: onClose,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Capture review',
                  style: Theme.of(context).textTheme.bodySmall),
              Text(
                'Item 1 of $totalCount',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        WarmPill(
          label: '${totalCount - 1} after this',
          orange: true,
          compact: true,
        ),
      ],
    );
  }
}

class _ReviewPhoto extends StatelessWidget {
  const _ReviewPhoto({required this.dish, required this.item});

  final Dish? dish;
  final ReviewItem item;

  @override
  Widget build(BuildContext context) {
    return WarmCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 200,
              width: double.infinity,
              child: item.imageRef == null
                  ? dish == null
                      ? const ColoredBox(color: MyMenuColors.oat2)
                      : DishArtwork(dish: dish!)
                  : AppImage(
                      imageRef: item.imageRef!,
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Looks like',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 3),
                    Text(dish?.title ?? 'Needs your decision',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                      'Salmon, bowl, and glaze · ${item.confidenceLabel} match',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewChoice extends StatelessWidget {
  const _ReviewChoice({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? MyMenuColors.orangeSoft : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? MyMenuColors.orange : MyMenuColors.line,
        ),
      ),
      child: ListTile(
        minTileHeight: 62,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? MyMenuColors.orange : MyMenuColors.softInk,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}

class _ReviewComplete extends StatelessWidget {
  const _ReviewComplete();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Everything is organized.'));
  }
}
