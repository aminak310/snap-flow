import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/storage_service.dart';
import '../../services/post_service.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController captionController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  File? selectedFile;
  Uint8List? webFile;

  String mediaType = "";
  bool isLoading = false;

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        webFile = await pickedFile.readAsBytes();
        selectedFile = null;
      } else {
        selectedFile = File(pickedFile.path);
        webFile = null;
      }

      setState(() {
        mediaType = "image";
      });
    }
  }

  Future<void> pickVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        webFile = await pickedFile.readAsBytes();
        selectedFile = null;
      } else {
        selectedFile = File(pickedFile.path);
        webFile = null;
      }

      setState(() {
        mediaType = "video";
      });
    }
  }

  Future<void> uploadPost() async {
    if (mediaType.isEmpty) return;
    if (captionController.text.trim().isEmpty) return;

    setState(() => isLoading = true);

    try {
      final storage = StorageService();
      final postService = PostService();

      String mediaUrl = "";

      // 📱 MOBILE
      if (!kIsWeb && selectedFile != null) {
        mediaUrl = await storage.uploadFile(
          selectedFile!,
          mediaType == "image" ? "images" : "videos",
        );
      }

      // 🌐 WEB (FIXED HERE)
      if (kIsWeb && webFile != null) {
        mediaUrl = await storage.uploadFileFromBytes(
          webFile!,
          mediaType == "image" ? "images" : "videos",
          "post_${DateTime.now().millisecondsSinceEpoch}",
        );
      }

      await postService.createPost(
        mediaUrl: mediaUrl,
        caption: captionController.text.trim(),
        mediaType: mediaType,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post Uploaded 🚀")),
      );

      setState(() {
        selectedFile = null;
        webFile = null;
        mediaType = "";
        captionController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  Widget previewBox() {
    if (kIsWeb && webFile != null) {
      return mediaType == "image"
          ? Image.memory(webFile!, fit: BoxFit.cover)
          : const Icon(Icons.video_library, size: 80);
    }

    if (!kIsWeb && selectedFile != null) {
      return mediaType == "image"
          ? Image.file(selectedFile!, fit: BoxFit.cover)
          : const Icon(Icons.video_library, size: 80);
    }

    return const Center(child: Text("Select Image or Video"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Post")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // 📦 Preview Box
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: previewBox(),
                ),
              ),

              const SizedBox(height: 20),

              // 📸 Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: pickImage,
                      child: const Text("Pick Image"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: pickVideo,
                      child: const Text("Pick Video"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ✍️ Caption
              TextField(
                controller: captionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Write caption...",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // 🚀 Upload Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: uploadPost,
                  child: const Text("Upload Post"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}