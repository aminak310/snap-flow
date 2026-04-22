import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final supabase = Supabase.instance.client;

  Future<List> getNotifications() async {
    final user = supabase.auth.currentUser;

    final data = await supabase
        .from('notifications')
        .select()
        .eq('user_id', user!.id)
        .order('created_at', ascending: false);

    return data;
  }
}