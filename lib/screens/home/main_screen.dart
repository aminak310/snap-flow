import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'add_post_screen.dart';
import 'package:snapflow/screens/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  final PageController pageController = PageController();

  final pages = [
    const FeedScreen(),
    const AddPostScreen(),
    const ProfileScreen(),
  ];

  // 📌 When user swipes
  void onPageChanged(int i) {
    setState(() {
      index = i;
    });
  }

  // 📌 When user taps bottom nav
  void onTabTapped(int i) {
    pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: pages,
      ),

      // 📌 Instagram-like bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: onTabTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: "Post",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}