import 'package:flutter/material.dart';

import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';

part 'menu_delete_action_bar.dart';

Future<bool> showMenuDeleteDialog(BuildContext context, List<Dish> dishes,
    {List<CaptureBatch> processingBatches = const <CaptureBatch>[]}) async {
  return await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        sheetAnimationStyle: const AnimationStyle(
          duration: Duration(milliseconds: 250),
          reverseDuration: Duration(milliseconds: 250),
        ),
        backgroundColor: MyMenuColors.cream,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        builder: (BuildContext sheetContext) {
          return _MenuDeleteConfirmation(
            dishes: dishes,
            processingBatches: processingBatches,
          );
        },
      ) ??
      false;
}

class _MenuDeleteConfirmation extends StatelessWidget {
  const _MenuDeleteConfirmation({
    required this.dishes,
    required this.processingBatches,
  });

  final List<Dish> dishes;
  final List<CaptureBatch> processingBatches;

  @override
  Widget build(BuildContext context) {
    final int count = dishes.length + processingBatches.length;
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.82;
    return ConstrainedBox(
      key: const ValueKey<String>('menu_delete_dialog'),
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4CEC6),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _DeleteTitle(
              count: count,
              dishCount: dishes.length,
              uploadCount: processingBatches.length,
            ),
            const SizedBox(height: 14),
            ...dishes.take(3).map(
                  (Dish dish) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _DeleteDishRow(dish: dish),
                  ),
                ),
            ...processingBatches.take(3 - dishes.take(3).length).map(
                  (CaptureBatch batch) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _DeleteUploadRow(batch: batch),
                  ),
                ),
            if (count > 3)
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 8),
                child: Text(
                  'and ${count - 3} more',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 2),
            const _DeletionScope(),
            const SizedBox(height: 12),
            Text(
              'This permanently removes the selected items from this device. '
              'You can undo briefly.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            const _DeleteActions(),
          ],
        ),
      ),
    );
  }
}

class _DeleteTitle extends StatelessWidget {
  const _DeleteTitle({
    required this.count,
    required this.dishCount,
    required this.uploadCount,
  });

  final int count;
  final int dishCount;
  final int uploadCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: MyMenuColors.redSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: MyMenuColors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'REMOVE FROM MYMENU',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: MyMenuColors.red,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
              ),
              Text(
                uploadCount == 0
                    ? count == 1
                        ? 'Delete this dish?'
                        : 'Delete $count dishes?'
                    : dishCount == 0
                        ? count == 1
                            ? 'Remove this pending upload?'
                            : 'Remove $count pending uploads?'
                        : 'Remove $count items?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeleteActions extends StatelessWidget {
  const _DeleteActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton(
            key: const ValueKey<String>('menu_keep_dishes'),
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              foregroundColor: MyMenuColors.ink,
              side: const BorderSide(color: MyMenuColors.line),
              shape: const StadiumBorder(),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(
            key: const ValueKey<String>('menu_confirm_delete'),
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: MyMenuColors.red,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: const Text('Delete'),
          ),
        ),
      ],
    );
  }
}

class _DeleteUploadRow extends StatelessWidget {
  const _DeleteUploadRow({required this.batch});

  final CaptureBatch batch;

  @override
  Widget build(BuildContext context) {
    final int count = batch.items.length;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MyMenuColors.orangeSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.auto_awesome_rounded,
              color: MyMenuColors.orangeDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              count == 1 ? 'Pending photo upload' : '$count pending photos',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteDishRow extends StatelessWidget {
  const _DeleteDishRow({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: MyMenuColors.oat,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox.square(
              dimension: 42,
              child: DishArtwork(dish: dish),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  dish.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  '${dish.madeCount} '
                  '${dish.madeCount == 1 ? 'cook' : 'cooks'}'
                  ' · ${dish.sourcePhotos.length} source photos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeletionScope extends StatelessWidget {
  const _DeletionScope();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2EC),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Column(
        children: <Widget>[
          _ScopeRow(
            icon: Icons.remove_rounded,
            text:
                'Cooking history, notes, recipes, and MyMenu source copies are removed.',
          ),
          SizedBox(height: 7),
          _ScopeRow(
            icon: Icons.remove_rounded,
            text: 'Planned meals using these dishes are also removed.',
          ),
          SizedBox(height: 7),
          _ScopeRow(
            icon: Icons.check_rounded,
            text: 'Photos in your phone’s library are not changed.',
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _ScopeRow extends StatelessWidget {
  const _ScopeRow({
    required this.icon,
    required this.text,
    this.strong = false,
  });

  final IconData icon;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: MyMenuColors.redSoft,
          ),
          child: Icon(icon, size: 12, color: MyMenuColors.red),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: MyMenuColors.ink,
                  fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
