import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../services/reels_service.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final ReelsService reelsService = ReelsService();

  List<Map<String, dynamic>> reels = [];
  List<VideoPlayerController> controllers = [];

  late PageController pageController;

  int currentIndex = 0;

  // ❤️ Like animation
  bool showHeart = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    loadReels();
  }

  // 📥 LOAD REELS
  Future<void> loadReels() async {
    final data = await reelsService.getReels();

    reels = data;

    controllers = reels.map((reel) {
      final controller = VideoPlayerController.network(
        reel['video_url'],
      )..initialize().then((_) {
        setState(() {});
      });

      return controller;
    }).toList();

    if (controllers.isNotEmpty) {
      controllers[0].play();
      controllers[0].setLooping(true);
    }

    setState(() {});
  }

  // 📌 HANDLE SWIPE
  void onPageChanged(int index) {
    currentIndex = index;

    for (var c in controllers) {
      c.pause();
    }

    controllers[index].play();
    controllers[index].setLooping(true);
  }

  // ❤️ DOUBLE TAP LIKE
  void onDoubleTap() {
    setState(() {
      showHeart = true;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        showHeart = false;
      });
    });
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: reels.isEmpty
          ? const Center(child: CircularProgressIndicator())

          : PageView.builder(
        scrollDirection: Axis.vertical,
        controller: pageController,
        onPageChanged: onPageChanged,
        itemCount: reels.length,

        itemBuilder: (context, index) {
          final reel = reels[index];
          final controller = controllers[index];

          return GestureDetector(

            // ❤️ DOUBLE TAP LIKE
            onDoubleTap: onDoubleTap,

            child: Stack(
              children: [

                // 🎥 VIDEO PLAYER
                Center(
                  child: controller.value.isInitialized
                      ? AspectRatio(
                    aspectRatio:
                    controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  )
                      : const CircularProgressIndicator(),
                ),

                // ❤️ BIG HEART ANIMATION
                if (showHeart && index == currentIndex)
                  const Center(
                    child: Icon(
                      Icons.favorite,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),

                // 🔥 OVERLAY UI
                Positioned(
                  bottom: 60,
                  left: 15,
                  right: 15,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        reel['caption'] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: const [

                          Icon(Icons.favorite,
                              color: Colors.white),

                          SizedBox(width: 15),

                          Icon(Icons.comment,
                              color: Colors.white),

                          SizedBox(width: 15),

                          Icon(Icons.send,
                              color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}