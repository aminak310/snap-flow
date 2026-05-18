import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentBio;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentBio,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final supabase = Supabase.instance.client;

  late TextEditingController nameController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.currentName);
    bioController = TextEditingController(text: widget.currentBio);
  }

  Future<void> updateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('profiles').update({
      'username': nameController.text.trim(),
      'bio': bioController.text.trim(),
    }).eq('id', user.id);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Username",
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: bioController,
              decoration: const InputDecoration(
                labelText: "Bio",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: updateProfile,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}