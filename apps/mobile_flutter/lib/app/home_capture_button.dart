import 'package:flutter/material.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

class HomeCaptureButton extends StatelessWidget {
  const HomeCaptureButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Capture',
      child: Container(
        key: const ValueKey<String>('capture_glow'),
        width: 94,
        height: 94,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              Color(0x70FF710A),
              Color(0x36FF9A3D),
              Color(0x00FFB166),
            ],
            stops: <double>[0, 0.58, 1],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            width: MyMenuUnits.captureButtonSize,
            height: MyMenuUnits.captureButtonSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(
                  color: MyMenuColors.cream,
                  width: 6,
                ),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFFFF8A24),
                  MyMenuColors.orangeAction,
                ],
                stops: <double>[0, 0.78],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0x33FFFFFF),
                  blurRadius: 2,
                  spreadRadius: 1,
                  offset: Offset(-1, -1),
                ),
              ],
            ),
            child: InkWell(
              key: const ValueKey<String>('capture_fab'),
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: const Icon(
                Icons.add,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
