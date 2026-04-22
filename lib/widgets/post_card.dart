import 'package:flutter/material.dart';
import '../models/post_model.dart';
import 'like_button.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(post.imageUrl),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(post.caption),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              LikeButton(),
              Icon(Icons.comment),
              Icon(Icons.share),
            ],
          )
        ],
      ),
    );
  }
}