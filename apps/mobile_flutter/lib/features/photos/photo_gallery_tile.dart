import 'package:flutter/material.dart';
import 'package:mymenu/domain/capture/captured_photo.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/app_image.dart';

class PhotoGalleryTile extends StatelessWidget {
  const PhotoGalleryTile({
    required this.photo,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final CapturedPhoto photo;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: ValueKey<String>('photo_tile_${photo.id}'),
      button: true,
      selected: selectionMode ? selected : null,
      label: photo.semanticsLabel,
      child: Material(
        color: MyMenuColors.oat,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Hero(
                tag: 'captured_photo_${photo.id}',
                child: AppImage(imageRef: photo.imageRef, fit: BoxFit.cover),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Colors.transparent, Color(0x70000000)],
                    stops: <double>[0.5, 1],
                  ),
                ),
              ),
              _overlayTag(context),
              if (selectionMode) _selectionIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overlayTag(BuildContext context) {
    final Color color = switch (photo.state) {
      CapturedPhotoState.review => MyMenuColors.orangeDark,
      CapturedPhotoState.failed => const Color(0xFF9D342B),
      CapturedPhotoState.organizing => const Color(0xFF6E5A8D),
      CapturedPhotoState.unorganized => const Color(0xB8322B25),
      CapturedPhotoState.organized => const Color(0xC9342F29),
    };
    return Positioned(
      left: 7,
      right: 7,
      bottom: 7,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 112),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (photo.state == CapturedPhotoState.organizing) ...<Widget>[
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  photo.overlayLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectionIndicator() {
    return Positioned(
      top: 7,
      right: 7,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? MyMenuColors.orange : Colors.white,
          border: Border.all(
            color: selected ? Colors.white : MyMenuColors.ink,
            width: 2,
          ),
        ),
        child: selected
            ? const Icon(Icons.check_rounded, size: 17, color: Colors.white)
            : null,
      ),
    );
  }
}
