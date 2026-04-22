import 'package:flutter/material.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text("User"),
      subtitle: Text("Nice post!"),
    );
  }
}