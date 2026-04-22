import 'package:supabase_flutter/supabase_flutter.dart';

class StoryService {
  final supabase = Supabase.instance.client;

  // 📤 Upload Story
  Future<void> uploadStory({
    required String mediaUrl,
    required String mediaType,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    await supabase.from('stories').insert({
      'user_id': user.id,
      'media_url': mediaUrl,
      'media_type': mediaType,
    });
  }

  // 📥 Get Stories (last 24h only)
  Future<List<Map<String, dynamic>>> getStories() async {
    final data = await supabase
        .from('stories')
        .select()
        .gte(
      'created_at',
      DateTime.now()
          .subtract(const Duration(hours: 24))
          .toIso8601String(),
    )
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}