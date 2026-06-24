import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class ProofImage extends StatelessWidget {
  final String imageReference;
  final BoxFit fit;
  final double? width;
  final double? height;

  const ProofImage({
    super.key,
    required this.imageReference,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (imageReference.startsWith('data:')) {
      final encoded = imageReference.substring(imageReference.indexOf(',') + 1);
      return Image.memory(
        base64Decode(encoded),
        fit: fit,
        width: width,
        height: height,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
      );
    }
    return Image.file(
      File(imageReference),
      fit: fit,
      width: width,
      height: height,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) =>
          const Center(child: Icon(Icons.broken_image_outlined)),
    );
  }
}
