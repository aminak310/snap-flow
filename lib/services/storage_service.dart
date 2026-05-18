import 'dart:io';
import 'dart:typed_data';
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient supabase = Supabase.instance.client;

  // 📱 MOBILE ONLY (File upload)
  Future<String> uploadFile(File file, String folder) async {
    try {
      final fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";

      log("uploadFile: uploading $fileName");

      await supabase.storage.from(folder).upload(
        fileName,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final url = supabase.storage.from(folder).getPublicUrl(fileName);

      log("uploadFile: success $url");

      return url;
    } catch (e) {
      log("uploadFile ERROR: $e");
      rethrow;
    }
  }

  // 🌐 WEB + MOBILE SAFE (Bytes upload)
  Future<String> uploadFileFromBytes(
      Uint8List bytes,
      String folder,
      String fileName,
      ) async {
    try {
      final finalName =
          "${DateTime.now().millisecondsSinceEpoch}_$fileName";

      log("uploadFileFromBytes: uploading $finalName");

      await supabase.storage.from(folder).uploadBinary(
        finalName,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final url = supabase.storage.from(folder).getPublicUrl(finalName);

      log("uploadFileFromBytes: success $url");

      return url;
    } catch (e) {
      log("uploadFileFromBytes ERROR: $e");
      rethrow;
    }
  }
}