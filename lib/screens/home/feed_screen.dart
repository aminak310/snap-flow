import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/like_service.dart';
import '../../services/comment_service.dart';
import '../../widgets/video_box.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final supabase = Supabase.instance.client;

  final LikeService likeService = LikeService();
  final CommentService commentService = CommentService();

  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;

  // 🔥 active visible video index
  int activeIndex = 0;

  // ❤️ likes
  Map<String, bool> likedPosts = {};
  Map<String, int> likeCounts = {};

  final TextEditingController commentController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  // 📥 Fetch posts
  Future<void> fetchPosts() async {
    final data = await supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false);

    setState(() {
      posts = List<Map<String, dynamic>>.from(data);
      isLoading = false;
    });

    loadLikes();
  }

  // ❤️ Load likes
  Future<void> loadLikes() async {
    for (var post in posts) {
      final postId = post['id'];

      likedPosts[postId] =
      await likeService.isLiked(postId);

      likeCounts[postId] =
      await likeService.getLikeCount(postId);
    }

    setState(() {});
  }

  // ❤️ Toggle like
  Future<void> toggleLike(String postId) async {
    await likeService.toggleLike(postId);

    likedPosts[postId] =
    await likeService.isLiked(postId);

    likeCounts[postId] =
    await likeService.getLikeCount(postId);

    setState(() {});
  }

  // 💬 Comments Bottom Sheet
  void openComments(String postId) async {
    final comments =
    await commentService.getComments(postId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
            MediaQuery.of(context).viewInsets.bottom,
            left: 15,
            right: 15,
            top: 15,
          ),
          child: SizedBox(
            height: 500,
            child: Column(
              children: [
                const Text(
                  "Comments",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // 📥 Comments List
                Expanded(
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, i) {
                      final c = comments[i];

                      return ListTile(
                        leading: const CircleAvatar(),
                        title: Text(
                          c['comment'] ?? "",
                        ),
                      );
                    },
                  ),
                ),

                // ✍️ Input + Send
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration:
                        const InputDecoration(
                          hintText:
                          "Write comment...",
                        ),
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        if (commentController.text
                            .trim()
                            .isEmpty) return;

                        await commentService.addComment(
                          postId: postId,
                          comment:
                          commentController.text,
                        );

                        commentController.clear();
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Comment Added ✅",
                            ),
                          ),
                        );

                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔥 Header
  Widget header() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: const Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Snap Flow",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.send),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          // 🔥 Top Header
          header(),

          // 🔥 Feed List
          Expanded(
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: posts.length,

              onPageChanged: (index) {
                setState(() {
                  activeIndex = index;
                });
              },

              itemBuilder: (context, index) {
                final post = posts[index];
                final postId = post['id'];

                return SingleChildScrollView(
                  child: Container(
                    margin:
                    const EdgeInsets.only(bottom: 15),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        // 👤 User Header
                        ListTile(
                          leading:
                          const CircleAvatar(),
                          title: Text(
                            post['user_id'] ??
                                "user",
                          ),
                          trailing: const Icon(
                            Icons.more_horiz,
                          ),
                        ),

                        // 🎥 VIDEO / 🖼 IMAGE
                        post['media_type'] ==
                            "video"
                            ? SizedBox(
                          height: 400,
                          width:
                          double.infinity,
                          child: AspectRatio(
                            aspectRatio:
                            9 / 16,
                            child: VideoBox(
                              url: post[
                              'image_url'],
                              play: index ==
                                  activeIndex,
                            ),
                          ),
                        )
                            : SizedBox(
                          height: 400,
                          width:
                          double.infinity,
                          child: Image.network(
                            post[
                            'image_url'],
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ❤️ Actions
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    toggleLike(
                                        postId),
                                child: Icon(
                                  likedPosts[
                                  postId] ==
                                      true
                                      ? Icons
                                      .favorite
                                      : Icons
                                      .favorite_border,
                                  color:
                                  Colors.red,
                                ),
                              ),

                              const SizedBox(
                                  width: 15),

                              GestureDetector(
                                onTap: () =>
                                    openComments(
                                        postId),
                                child:
                                const Icon(
                                  Icons.comment,
                                ),
                              ),

                              const SizedBox(
                                  width: 15),

                              const Icon(
                                  Icons.send),

                              const Spacer(),

                              Text(
                                "${likeCounts[postId] ?? 0} likes",
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 📝 Caption
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Text(
                            post['caption'] ??
                                "",
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}