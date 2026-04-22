import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final supabase = Supabase.instance.client;

  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    await supabase.from('messages').insert({
      'sender_id': user.id,
      'receiver_id': receiverId,
      'message': message,
    });
  }

  Future<List<Map<String, dynamic>>> getMessages(
      String userId) async {
    final user = supabase.auth.currentUser;

    final data = await supabase
        .from('messages')
        .select()
        .or(
      'and(sender_id.eq.${user!.id},receiver_id.eq.$userId),and(sender_id.eq.$userId,receiver_id.eq.${user.id})',
    )
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(data);
  }
}