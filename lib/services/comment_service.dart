import 'package:supabase_flutter/supabase_flutter.dart';

class CommentService {
  final supabase = Supabase.instance.client;

  // ➕ Add Comment
  Future<void> addComment({
    required String postId,
    required String comment,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    if (comment.trim().isEmpty) {
      throw Exception("Comment is empty");
    }

    await supabase.from('comments').insert({
      'post_id': postId,
      'user_id': user.id,
      'comment': comment.trim(),
    });
  }

  // 📥 Get Comments
  Future<List<Map<String, dynamic>>> getComments(
      String postId,
      ) async {
    final data = await supabase
        .from('comments')
        .select()
        .eq('post_id', postId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // 🔢 Comment Count
  Future<int> getCommentCount(String postId) async {
    final data = await supabase
        .from('comments')
        .select()
        .eq('post_id', postId);

    return data.length;
  }
}