import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';

class MenuGridCard extends StatelessWidget {
  const MenuGridCard({
    required this.dish,
    this.selected = false,
    this.selectionMode = false,
    this.onTap,
    this.onLongPress,
    this.onSelect,
    super.key,
  });

  final Dish dish;
  final bool selected;
  final bool selectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    final double titleLineHeight =
        MediaQuery.textScalerOf(context).scale(titleStyle.fontSize!) *
            titleStyle.height!;
    final double titleSlotHeight = (titleLineHeight * 2).ceilToDouble();

    return Semantics(
      selected: selectionMode ? selected : null,
      customSemanticsActions: onSelect == null && onLongPress == null
          ? const <CustomSemanticsAction, VoidCallback>{}
          : <CustomSemanticsAction, VoidCallback>{
              const CustomSemanticsAction(label: 'Select dish'):
                  onSelect ?? onLongPress!,
            },
      child: Container(
        key: ValueKey<String>('menu_dish_${dish.id}'),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x24C94B00),
                    blurRadius: 26,
                    offset: Offset(0, 10),
                  ),
                ]
              : myMenuCardShadow,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? MyMenuColors.orangeAction : MyMenuColors.line,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ??
                () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DishDetailScreen(dishId: dish.id),
                      ),
                    ),
            onLongPress: onLongPress,
            child: _MenuCardBody(
              dish: dish,
              titleStyle: titleStyle,
              titleSlotHeight: titleSlotHeight,
              selected: selected,
              selectionMode: selectionMode,
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuCardBody extends StatelessWidget {
  const _MenuCardBody({
    required this.dish,
    required this.titleStyle,
    required this.titleSlotHeight,
    required this.selected,
    required this.selectionMode,
  });

  final Dish dish;
  final TextStyle titleStyle;
  final double titleSlotHeight;
  final bool selected;
  final bool selectionMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              DishArtwork(dish: dish),
              if (selectionMode)
                Positioned.fill(
                  child: ColoredBox(
                    color: selected
                        ? MyMenuColors.orangeAction.withValues(alpha: 0.12)
                        : Colors.transparent,
                  ),
                ),
              if (selectionMode)
                Positioned(
                  top: 10,
                  right: 10,
                  child: _SelectionIndicator(selected: selected),
                ),
              if (dish.isFavorite)
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: GestureDetector(
                    onTap: selectionMode
                        ? null
                        : () =>
                            MyMenuScope.read(context).toggleFavorite(dish.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xEFFFFFFF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.favorite, size: 10),
                          SizedBox(width: 3),
                          Text(
                            'Favorite',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: titleSlotHeight,
                child: Text(
                  key: ValueKey<String>('menu_dish_title_${dish.id}'),
                  dish.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ),
              Text(
                '${dish.madeCount} '
                '${dish.madeCount == 1 ? 'cook' : 'cooks'}'
                ' · ${dish.sourcePhotos.length} photos',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 7),
              _MemoryCue(dish: dish),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? MyMenuColors.orangeAction : const Color(0xEFFFFFFF),
        border: Border.all(
          color: selected ? Colors.white : MyMenuColors.softInk,
          width: 2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
          : null,
    );
  }
}

class _MemoryCue extends StatelessWidget {
  const _MemoryCue({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          _usesNoteCue(dish) ? Icons.edit_outlined : Icons.history_rounded,
          size: 11,
          color: const Color(0xFF796E64),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _memoryCue(dish),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF796E64),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

String _memoryCue(Dish dish) {
  if (dish.id == 'dish_salmon') {
    return '“Broil for 2 minutes…”';
  }
  if (dish.id == 'dish_katsu') {
    return 'Crispier crumbs next time';
  }
  if (dish.id == 'dish_pho') {
    return 'Evolving since 2024';
  }
  return 'Last made ${dish.lastMadeLabel}';
}

bool _usesNoteCue(Dish dish) =>
    dish.id == 'dish_salmon' || dish.id == 'dish_katsu';
