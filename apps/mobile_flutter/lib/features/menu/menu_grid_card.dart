import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';
import 'package:mymenu/features/menu/menu_memory_cue.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/local_write_feedback.dart';

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
          child: _MenuCardArtwork(
            dish: dish,
            selected: selected,
            selectionMode: selectionMode,
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
              MenuMemoryCue(dish: dish),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuCardArtwork extends StatelessWidget {
  const _MenuCardArtwork({
    required this.dish,
    required this.selected,
    required this.selectionMode,
  });

  final Dish dish;
  final bool selected;
  final bool selectionMode;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
            left: 10,
            child: _SelectionIndicator(selected: selected),
          ),
        if (!selectionMode && dish.createdAt != null)
          Positioned(
            top: 5,
            left: 7,
            child: _NewDishLabel(dishId: dish.id),
          ),
        if (!selectionMode)
          Positioned(
            top: 8,
            right: 8,
            child: Semantics(
              button: true,
              label: dish.isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => runLocalWriteWithFeedback(
                  context,
                  () => MyMenuScope.read(context).toggleFavorite(dish.id),
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dish.isFavorite
                        ? const Color(0xF2FFFFFF)
                        : const Color(0x57302018),
                  ),
                  child: Icon(
                    dish.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 19,
                    color: dish.isFavorite
                        ? const Color(0xFFEF4D4D)
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NewDishLabel extends StatefulWidget {
  const _NewDishLabel({required this.dishId});

  final String dishId;

  @override
  State<_NewDishLabel> createState() => _NewDishLabelState();
}

class _NewDishLabelState extends State<_NewDishLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 900),
    vsync: this,
  );
  late final Animation<double> _rotation = TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0, end: -0.12),
        weight: 18,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -0.12, end: 0.09),
        weight: 25,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.09, end: -0.06),
        weight: 22,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -0.06, end: 0.035),
        weight: 20,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.035, end: 0),
        weight: 15,
      ),
    ],
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.value == 0 && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'New dish',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final double lift = math.sin(_controller.value * math.pi * 5) *
                1.2 *
                (1 - _controller.value);
            return Transform.translate(
              offset: Offset(0, lift),
              child: Transform.rotate(
                  angle: -0.14 + _rotation.value, child: child),
            );
          },
          child: Text(
            key: ValueKey<String>('menu_new_label_${widget.dishId}'),
            'New',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: '.SF Pro Rounded',
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -1.2,
              shadows: <Shadow>[
                Shadow(
                  color: Color(0x75302018),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
        ),
      ),
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
