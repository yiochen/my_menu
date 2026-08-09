import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CoverGenerationEffect extends StatefulWidget {
  const CoverGenerationEffect({required this.child, super.key});

  final Widget child;

  @override
  State<CoverGenerationEffect> createState() => _CoverGenerationEffectState();
}

class _CoverGenerationEffectState extends State<CoverGenerationEffect>
    with TickerProviderStateMixin {
  static const String _shaderAsset = 'assets/shaders/cover_generation.frag';
  static Future<ui.FragmentProgram>? _sharedProgram;

  late final AnimationController _revealController = AnimationController(
    duration: const Duration(milliseconds: 850),
    vsync: this,
  );
  late final AnimationController _motionController = AnimationController(
    duration: const Duration(milliseconds: 5600),
    vsync: this,
  );
  late final Animation<double> _reveal = CurvedAnimation(
    parent: _revealController,
    curve: Curves.easeInOutCubic,
  );

  ui.FragmentShader? _shader;
  bool? _motionDisabled;

  @override
  void initState() {
    super.initState();
    unawaited(_loadShader());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool motionDisabled =
        MediaQuery.disableAnimationsOf(context) || debugDisableShadows;
    if (_motionDisabled == motionDisabled) return;
    _motionDisabled = motionDisabled;
    if (motionDisabled) {
      _revealController.value = 1;
      _motionController
        ..stop()
        ..value = 0.32;
      return;
    }
    unawaited(_revealController.forward());
    unawaited(_motionController.repeat());
  }

  Future<void> _loadShader() async {
    final ui.FragmentProgram program =
        await (_sharedProgram ??= ui.FragmentProgram.fromAsset(_shaderAsset));
    if (!mounted) return;
    setState(() => _shader = program.fragmentShader());
  }

  @override
  void dispose() {
    _shader?.dispose();
    _revealController.dispose();
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            AnimatedBuilder(
              animation: _reveal,
              child: widget.child,
              builder: (BuildContext context, Widget? child) {
                final double blur = 14 * _reveal.value;
                return ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: blur,
                    sigmaY: blur,
                    tileMode: TileMode.clamp,
                  ),
                  child: child,
                );
              },
            ),
            if (_shader != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: Listenable.merge(<Listenable>[
                      _reveal,
                      _motionController,
                    ]),
                    builder: (BuildContext context, Widget? child) {
                      return CustomPaint(
                        painter: _CoverGenerationPainter(
                          shader: _shader!,
                          time: _motionController.value,
                          reveal: _reveal.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoverGenerationPainter extends CustomPainter {
  const _CoverGenerationPainter({
    required this.shader,
    required this.time,
    required this.reveal,
  });

  final ui.FragmentShader shader;
  final double time;
  final double reveal;

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, reveal);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = shader
        ..isAntiAlias = false,
    );
  }

  @override
  bool shouldRepaint(_CoverGenerationPainter oldDelegate) {
    return time != oldDelegate.time ||
        reveal != oldDelegate.reveal ||
        shader != oldDelegate.shader;
  }
}
