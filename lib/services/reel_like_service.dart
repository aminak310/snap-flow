import 'package:supabase_flutter/supabase_flutter.dart';

class ReelLikeService {
  final supabase = Supabase.instance.client;

  Future<void> toggleLike(String reelId) async {
    final user = supabase.auth.currentUser;

    final existing = await supabase
        .from('reel_likes')
        .select()
        .eq('user_id', user!.id)
        .eq('reel_id', reelId);

    if (existing.isEmpty) {
      await supabase.from('reel_likes').insert({
        'user_id': user.id,
        'reel_id': reelId,
      });
    } else {
      await supabase
          .from('reel_likes')
          .delete()
          .eq('user_id', user.id)
          .eq('reel_id', reelId);
    }
  }
}