import 'package:supabase_flutter/supabase_flutter.dart';

class FollowService {
  final supabase = Supabase.instance.client;

  // 👥 Follow / Unfollow
  Future<void> toggleFollow(String userId) async {
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) return;

    final existing = await supabase
        .from('follows')
        .select()
        .eq('follower_id', currentUser.id)
        .eq('following_id', userId);

    if (existing.isNotEmpty) {
      // unfollow
      await supabase
          .from('follows')
          .delete()
          .eq('follower_id', currentUser.id)
          .eq('following_id', userId);
    } else {
      // follow
      await supabase.from('follows').insert({
        'follower_id': currentUser.id,
        'following_id': userId,
      });
    }
  }

  // 👥 Check follow status
  Future<bool> isFollowing(String userId) async {
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) return false;

    final data = await supabase
        .from('follows')
        .select()
        .eq('follower_id', currentUser.id)
        .eq('following_id', userId);

    return data.isNotEmpty;
  }

  // 👥 Followers count
  Future<int> getFollowers(String userId) async {
    final data = await supabase
        .from('follows')
        .select()
        .eq('following_id', userId);

    return data.length;
  }

  // 👥 Following count
  Future<int> getFollowing(String userId) async {
    final data = await supabase
        .from('follows')
        .select()
        .eq('follower_id', userId);

    return data.length;
  }
}