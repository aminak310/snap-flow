import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/video_box.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  List myPosts = [];

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      final data = await supabase
          .from('posts')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        myPosts = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: GridView.builder(
        itemCount: myPosts.length,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          final post = myPosts[index];

          return Container(
            color: Colors.black,

            // ✅ FIX IMAGE + VIDEO
            child: post['media_type'] == "video"
                ? const Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 40,
            )
                : Image.network(
              post['image_url'],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}