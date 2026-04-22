import 'package:supabase_flutter/supabase_flutter.dart';

class ReelsService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getReels() async {
    final data = await supabase
        .from('reels')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> uploadReel({
    required String videoUrl,
    required String caption,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    await supabase.from('reels').insert({
      'user_id': user.id,
      'video_url': videoUrl,
      'caption': caption,
    });
  }
}