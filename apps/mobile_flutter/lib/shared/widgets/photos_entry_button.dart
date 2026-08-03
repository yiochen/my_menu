import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

const String photosEntryHeroTag = 'photos_entry_hero';

class PhotosEntryButton extends StatefulWidget {
  const PhotosEntryButton({
    required this.unorganizedCount,
    required this.organizing,
    required this.onPressed,
    super.key,
  });

  final int unorganizedCount;
  final bool organizing;
  final VoidCallback onPressed;

  @override
  State<PhotosEntryButton> createState() => _PhotosEntryButtonState();
}

class _PhotosEntryButtonState extends State<PhotosEntryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant PhotosEntryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  void _updateAnimation() {
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.organizing && !reduceMotion) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool needsAttention = widget.unorganizedCount > 0;
    final String label = widget.organizing
        ? 'Photos, organizing in progress'
        : needsAttention
            ? 'Photos, ${widget.unorganizedCount} unorganized'
            : 'Photos, all organized';
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: Hero(
          tag: photosEntryHeroTag,
          createRectTween: _photosRectTween,
          flightShuttleBuilder: photosFlightShuttleBuilder,
          child: Material(
            color: needsAttention || widget.organizing
                ? MyMenuColors.orangeSoft
                : MyMenuColors.oat,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              key: const ValueKey<String>('menu_photos_button'),
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                width: 46,
                height: 46,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    const Icon(Icons.photo_library_outlined, size: 23),
                    if (widget.organizing)
                      RotationTransition(
                        turns: _controller,
                        child: const Align(
                          alignment: Alignment(0.82, -0.82),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 13,
                            color: MyMenuColors.orange,
                          ),
                        ),
                      )
                    else if (needsAttention)
                      Align(
                        alignment: const Alignment(0.86, -0.86),
                        child: SizedBox.square(
                          key: const ValueKey<String>('menu_photos_badge'),
                          dimension: 18,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: MyMenuColors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: MyMenuColors.cream,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    widget.unorganizedCount > 99
                                        ? '99+'
                                        : '${widget.unorganizedCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

RectTween _photosRectTween(Rect? begin, Rect? end) =>
    MaterialRectArcTween(begin: begin, end: end);

Widget photosFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, _) {
      final double progress = animation.value;
      final double iconOpacity =
          1 - const Interval(0, 0.28, curve: Curves.easeIn).transform(progress);

      return ClipRRect(
        key: const ValueKey<String>('photos_morph_surface'),
        borderRadius: BorderRadius.circular(ui.lerpDouble(15, 0, progress)!),
        child: ColoredBox(
          color: Color.lerp(
            MyMenuColors.orangeSoft,
            MyMenuColors.cream,
            progress,
          )!,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Opacity(
                opacity: iconOpacity,
                child: const Icon(Icons.photo_library_outlined, size: 23),
              ),
            ],
          ),
        ),
      );
    },
  );
}
