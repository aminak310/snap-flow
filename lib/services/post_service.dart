import 'package:supabase_flutter/supabase_flutter.dart';

class PostService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> createPost({
    required String mediaUrl,
    required String caption,
    required String mediaType,
  }) async {
    await supabase.from('posts').insert({
      'image_url': mediaUrl,
      'caption': caption,
      'media_type': mediaType,
      'user_id': supabase.auth.currentUser?.id,
    });
  }

  // 📌 ADD THIS (FIX ERROR)
  Future<List<Map<String, dynamic>>> getPosts() async {
    final response = await supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> deletePost(String postId) async {
    await supabase.from('posts').delete().eq('id', postId);
  }
}