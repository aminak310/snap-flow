import 'package:flutter/material.dart';

import 'feed_screen.dart';
import 'add_post_screen.dart';
import '../profile/profile_screen.dart';
import 'reels_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final PageController pageController = PageController();

  final List<Widget> screens = [
    const FeedScreen(),
    const AddPostScreen(),
    const ReelsScreen(),
    const ProfileScreen(),
  ];

  // 📌 Swipe update
  void onPageChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // 📌 Tap navigation
  void onTabTapped(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // 📱 Swipe pages (Instagram style)
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: screens,
      ),

      // 🔥 Bottom Navigation (Instagram style)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTabTapped,
        type: BottomNavigationBarType.fixed,
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
            icon: Icon(Icons.video_library),
            label: "Reels",
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