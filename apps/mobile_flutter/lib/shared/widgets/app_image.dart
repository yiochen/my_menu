import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mymenu/shared/widgets/food_cover_placeholder.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    required this.imageRef,
    this.fit,
    this.width,
    this.height,
    this.resizeForDisplay = false,
    super.key,
  });

  final String imageRef;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final bool resizeForDisplay;

  static const double _decodeWidthMultiplier = 1.25;
  static const int _maximumDecodeWidth = 2048;

  @override
  Widget build(BuildContext context) {
    if (imageRef.trim().isEmpty) {
      return _placeholder();
    }
    final ImageProvider<Object> provider =
        AppImageResolver.providerFor(imageRef);
    if (!resizeForDisplay) {
      return _image(provider);
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int? cacheWidth = _cacheWidthFor(context, constraints);
        final ImageProvider<Object> displayProvider = cacheWidth == null
            ? provider
            : ResizeImage(provider, width: cacheWidth);
        return _image(displayProvider);
      },
    );
  }

  Widget _image(ImageProvider<Object> provider) {
    return Image(
      image: provider,
      fit: fit,
      width: width,
      height: height,
      gaplessPlayback: true,
      frameBuilder: (
        BuildContext context,
        Widget child,
        int? frame,
        bool wasSynchronouslyLoaded,
      ) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return _placeholder();
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return FoodCoverPlaceholder(
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
    );
  }

  int? _cacheWidthFor(BuildContext context, BoxConstraints constraints) {
    final double? explicitWidth = width?.isFinite ?? false ? width : null;
    final double? constrainedWidth =
        constraints.hasBoundedWidth ? constraints.maxWidth : null;
    final double? logicalWidth = switch ((explicitWidth, constrainedWidth)) {
      (final double explicit, final double constrained) =>
        explicit < constrained ? explicit : constrained,
      (final double explicit, null) => explicit,
      (null, final double constrained) => constrained,
      (null, null) => null,
    };
    if (logicalWidth == null || logicalWidth <= 0) {
      return null;
    }
    final int physicalWidth = (logicalWidth *
            MediaQuery.devicePixelRatioOf(context) *
            _decodeWidthMultiplier)
        .ceil();
    return physicalWidth.clamp(1, _maximumDecodeWidth);
  }
}

class AppImageResolver {
  const AppImageResolver._();

  static ImageProvider<Object> providerFor(String imageRef) {
    final Uri? uri = Uri.tryParse(imageRef);
    if (uri != null && uri.scheme == 'file') {
      return FileImage(File.fromUri(uri));
    }

    if (!isNetworkRef(imageRef)) {
      return FileImage(File(imageRef));
    }

    return NetworkImage(imageRef);
  }

  static bool isNetworkRef(String imageRef) {
    final Uri? uri = Uri.tryParse(imageRef);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
