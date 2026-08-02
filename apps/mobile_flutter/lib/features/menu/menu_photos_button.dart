import 'package:flutter/material.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

class MenuPhotosButton extends StatefulWidget {
  const MenuPhotosButton({
    required this.unorganizedCount,
    required this.organizing,
    required this.onPressed,
    super.key,
  });

  final int unorganizedCount;
  final bool organizing;
  final VoidCallback onPressed;

  @override
  State<MenuPhotosButton> createState() => _MenuPhotosButtonState();
}

class _MenuPhotosButtonState extends State<MenuPhotosButton>
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
  void didUpdateWidget(covariant MenuPhotosButton oldWidget) {
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
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 18),
                        height: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: MyMenuColors.orange,
                          borderRadius: BorderRadius.circular(9),
                          border:
                              Border.all(color: MyMenuColors.cream, width: 1.5),
                        ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
