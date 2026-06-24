import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class ProofImageStorage {
  static Future<String> persistXFile(XFile source) async {
    final bytes = await source.readAsBytes();
    final mimeType = source.mimeType ?? _mimeTypeFromName(source.name);
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }

  static Future<void> deleteReference(String reference) async {}

  static String _mimeTypeFromName(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.endsWith('.png')) return 'image/png';
    if (lowerName.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
