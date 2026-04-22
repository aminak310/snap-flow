import 'package:supabase_flutter/supabase_flutter.dart';

class SaveService {
  final supabase = Supabase.instance.client;

  Future<void> toggleSave(String postId) async {
    final user = supabase.auth.currentUser;

    final existing = await supabase
        .from('saved_posts')
        .select()
        .eq('user_id', user!.id)
        .eq('post_id', postId);

    if (existing.isEmpty) {
      await supabase.from('saved_posts').insert({
        'user_id': user.id,
        'post_id': postId,
      });
    } else {
      await supabase
          .from('saved_posts')
          .delete()
          .eq('user_id', user.id)
          .eq('post_id', postId);
    }
  }
}