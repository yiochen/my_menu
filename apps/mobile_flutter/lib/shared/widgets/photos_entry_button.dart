import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

const String photosEntryHeroTag = 'photos_entry_hero';

const Color _processingBlue = Color(0xFF0A8CFF);
const Color _processingViolet = Color(0xFF9A72FF);

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
            color: widget.organizing
                ? MyMenuColors.oat
                : needsAttention
                    ? MyMenuColors.orangeSoft
                    : MyMenuColors.oat,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              key: const ValueKey<String>('menu_photos_button'),
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(15),
              child: _buildContents(needsAttention),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContents(bool needsAttention) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Icon(
            Icons.photo_library_outlined,
            size: 23,
            color: widget.organizing ? _processingBlue : null,
          ),
          if (widget.organizing)
            const Align(
              alignment: Alignment(0.72, -0.72),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 12,
                color: _processingBlue,
              ),
            )
          else if (needsAttention)
            Align(
              alignment: const Alignment(0.86, -0.86),
              child: _buildAttentionBadge(),
            ),
          if (widget.organizing)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget? child) {
                    return CustomPaint(
                      key: const ValueKey<String>(
                        'menu_photos_processing_border',
                      ),
                      painter: _PhotosProcessingBorderPainter(
                        progress: _controller.value,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttentionBadge() {
    return SizedBox.square(
      key: const ValueKey<String>('menu_photos_badge'),
      dimension: 18,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MyMenuColors.orange,
          shape: BoxShape.circle,
          border: Border.all(color: MyMenuColors.cream, width: 1.5),
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

class _PhotosProcessingBorderPainter extends CustomPainter {
  const _PhotosProcessingBorderPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    final Rect strokeBounds = bounds.deflate(1.5);
    final Paint paint = Paint()
      ..shader = SweepGradient(
        transform: GradientRotation(progress * math.pi * 2),
        colors: const <Color>[
          _processingBlue,
          _processingBlue,
          _processingViolet,
          Color(0x663E7BFA),
          _processingBlue,
        ],
        stops: const <double>[0, 0.3, 0.52, 0.72, 1],
      ).createShader(bounds)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(
      RRect.fromRectAndRadius(strokeBounds, const Radius.circular(13.5)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PhotosProcessingBorderPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
