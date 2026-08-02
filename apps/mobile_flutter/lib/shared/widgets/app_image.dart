import 'dart:io';

import 'package:flutter/material.dart';

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
      return _ImageFallback(width: width, height: height);
    }
    final ImageProvider provider = AppImageResolver.providerFor(imageRef);
    return Image(
      image: provider,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) {
        return _ImageFallback(width: width, height: height);
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

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({
    required this.width,
    required this.height,
  });

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE8DFD2),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFF727272),
      ),
    );
  }
}
