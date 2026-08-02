import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mymenu/shared/widgets/food_cover_placeholder.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    required this.imageRef,
    this.fit,
    this.width,
    this.height,
    super.key,
  });

  final String imageRef;
  final BoxFit? fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (imageRef.trim().isEmpty) {
      return FoodCoverPlaceholder(
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
      );
    }
    final ImageProvider provider = AppImageResolver.providerFor(imageRef);
    return Image(
      image: provider,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) {
        return FoodCoverPlaceholder(
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
        );
      },
    );
  }
}

class AppImageResolver {
  const AppImageResolver._();

  static ImageProvider providerFor(String imageRef) {
    final Uri? uri = Uri.tryParse(imageRef);
    if (uri != null && uri.scheme == 'file') {
      return FileImage(File.fromUri(uri));
    }

    final File localFile = File(imageRef);
    if (!isNetworkRef(imageRef) && localFile.existsSync()) {
      return FileImage(localFile);
    }

    return NetworkImage(imageRef);
  }

  static bool isNetworkRef(String imageRef) {
    final Uri? uri = Uri.tryParse(imageRef);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
