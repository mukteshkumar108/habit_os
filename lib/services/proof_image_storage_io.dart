import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProofImageStorage {
  static Future<String> persistXFile(XFile source) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final proofDirectory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}habit_os_proofs',
    );
    await proofDirectory.create(recursive: true);
    final extension = source.name.contains('.')
        ? source.name.substring(source.name.lastIndexOf('.'))
        : '.jpg';
    final destination = File(
      '${proofDirectory.path}${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}$extension',
    );
    await File(source.path).copy(destination.path);
    return destination.path;
  }

  static Future<void> deleteReference(String reference) async {
    if (reference.startsWith('data:')) return;
    final file = File(reference);
    if (await file.exists()) await file.delete();
  }
}
