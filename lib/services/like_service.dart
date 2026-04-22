import 'package:supabase_flutter/supabase_flutter.dart';

class LikeService {
  final supabase = Supabase.instance.client;

  // ❤️ Toggle Like
  Future<void> toggleLike(String postId) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final existing = await supabase
        .from('likes')
        .select()
        .eq('post_id', postId.toString())
        .eq('user_id', user.id);

    if (existing.isNotEmpty) {
      await supabase
          .from('likes')
          .delete()
          .eq('post_id', postId.toString())
          .eq('user_id', user.id);
    } else {
      await supabase.from('likes').insert({
        'post_id': postId.toString(),
        'user_id': user.id,
      });
    }
  }

  // ❤️ Get Like Count
  Future<int> getLikeCount(String postId) async {
    final data = await supabase
        .from('likes')
        .select()
        .eq('post_id', postId.toString());

    return data.length;
  }

  // ❤️ Check Liked
  Future<bool> isLiked(String postId) async {
    final user = supabase.auth.currentUser;

    if (user == null) return false;

    final data = await supabase
        .from('likes')
        .select()
        .eq('post_id', postId.toString())
        .eq('user_id', user.id);

    return data.isNotEmpty;
  }
}