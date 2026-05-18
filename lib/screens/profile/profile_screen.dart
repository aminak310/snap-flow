import 'dart:typed_data';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/storage_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  final ImagePicker picker = ImagePicker();

  List myPosts = [];

  String username = "";
  String bio = "";
  String avatarUrl = "";

  @override
  void initState() {
    super.initState();
    log("initState: ProfileScreen loaded");
    fetchProfile();
  }

  // 📥 FETCH PROFILE
  Future<void> fetchProfile() async {
    log("fetchProfile: started");

    final user = supabase.auth.currentUser;
    log("fetchProfile: currentUser = ${user?.id}");

    if (user == null) return;

    try {
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      final posts = await supabase
          .from('posts')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        username = profile['username'] ?? "User";
        bio = profile['bio'] ?? "";
        avatarUrl = profile['avatar_url'] ?? "";
        myPosts = posts;
      });

      log("fetchProfile: setState completed");
    } catch (e) {
      log("ERROR in fetchProfile: $e");
    }
  }

  // 📸 UPLOAD PROFILE IMAGE (WEB + MOBILE FIXED)
  Future<void> pickAndUploadImage() async {
    log("pickAndUploadImage: started");

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) {
      log("pickAndUploadImage: cancelled");
      return;
    }

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      log("pickAndUploadImage: file = ${picked.name}");

      // ✅ WEB SAFE (NO File())
      final Uint8List bytes = await picked.readAsBytes();

      final storage = StorageService();

      log("pickAndUploadImage: uploading...");

      final url = await storage.uploadFileFromBytes(
        bytes,
        "avatars",
        picked.name,
      );

      log("pickAndUploadImage: uploaded URL = $url");

      await supabase.from('profiles').update({
        'avatar_url': url,
      }).eq('id', user.id);

      if (!mounted) return;

      setState(() {
        avatarUrl = url;
      });

      fetchProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated ✅")),
      );
    } catch (e) {
      log("UPLOAD ERROR: $e");
    }
  }

  Widget stat(int value, String title) {
    return Column(
      children: [
        Text(
          "$value",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(username),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [

                  GestureDetector(
                    onTap: pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : const NetworkImage(
                        "https://picsum.photos/200",
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        stat(myPosts.length, "Posts"),
                        stat(0, "Followers"),
                        stat(0, "Following"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    bio,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          currentName: username,
                          currentBio: bio,
                        ),
                      ),
                    );

                    fetchProfile();
                  },
                  child: const Text("Edit Profile"),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(color: Colors.grey),

            myPosts.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "No Posts Yet",
                style: TextStyle(color: Colors.white),
              ),
            )
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myPosts.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                final post = myPosts[index];

                return Container(
                  color: Colors.black,
                  child: post['media_type'] == "video"
                      ? const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                  )
                      : Image.network(
                    post['image_url'],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}