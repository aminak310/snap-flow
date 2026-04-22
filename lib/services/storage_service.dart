import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient supabase = Supabase.instance.client;

  // 📱 MOBILE UPLOAD (image/video)
  Future<String> uploadFile(File file, String folder) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    await supabase.storage.from('posts').upload(
      '$folder/$fileName',
      file,
    );

    return supabase.storage.from('posts').getPublicUrl('$folder/$fileName');
  }

  // 🌐 WEB UPLOAD (image/video)
  Future<String> uploadWebFile(Uint8List bytes, String folder) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    await supabase.storage.from('posts').uploadBinary(
      '$folder/$fileName',
      bytes,
    );

    return supabase.storage.from('posts').getPublicUrl('$folder/$fileName');
  }
}