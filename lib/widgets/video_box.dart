import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBox extends StatefulWidget {
  final String url;
  final bool play;

  const VideoBox({
    super.key,
    required this.url,
    required this.play,
  });

  @override
  State<VideoBox> createState() => _VideoBoxState();
}

class _VideoBoxState extends State<VideoBox> {
  late VideoPlayerController controller;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {
          isInitialized = true;
        });

        // 🎯 auto play if active
        if (widget.play) {
          controller.play();
          controller.setLooping(true);
        }
      });
  }

  @override
  void didUpdateWidget(covariant VideoBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔥 AUTO PLAY / PAUSE CONTROL
    if (widget.play) {
      if (!controller.value.isPlaying && isInitialized) {
        controller.play();
        controller.setLooping(true);
      }
    } else {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose(); // 🔥 important cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
        });
      },

      child: Stack(
        alignment: Alignment.center,
        children: [

          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),

          // ▶️ Play Icon Overlay
          if (!controller.value.isPlaying)
            const Icon(
              Icons.play_circle_fill,
              size: 70,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}