import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lencho/screens/chat/chat_list_page.dart';
import 'package:lencho/widgets/campaign/posting_widget.dart'; // This widget shows campaigns.
import 'package:lencho/widgets/home/header_widgets.dart';
import 'package:lencho/widgets/home/content_widgets.dart';
import 'package:lencho/controllers/home/authUser_controller.dart';
import 'package:lencho/screens/community/community_browse_page.dart';

/// HomePage displays header, content, and conditionally an "Add" button for authorized users.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "Guest";

    // Initialize the AuthUserController.
    final AuthUserController authController = Get.put(AuthUserController());

    return Scaffold(
      appBar: AppBar(
        title: Text("Hello $email"),
      ),
      body: Column(
        children: const [
          HomeHeader(),
          HomeContent(),
        ],
      ),
      bottomNavigationBar: Obx(() {
        // Build the bottom navigation items based on authorization.
        bool isAuth = authController.isAuthorized.value;
        List<BottomNavigationBarItem> items = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          if (isAuth)
            const BottomNavigationBarItem(
              icon: Icon(Icons.add_box),
              label: 'Add',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          if (isAuth)
            const BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Communities',
            ),
        ];

        return BottomNavigationBar(
          items: items,
          onTap: (index) {
            if (isAuth) {
              // When authorized: indices: 0:Home, 1:Add, 2:Search, 3:Chat, 4:Communities.
              if (index == 1) {
                // Navigate to campaign posting.
                Get.to(() => CampaignPostingWidget());
              } else if (index == 3) {
                Get.to(() => const ChatListPage());
              } else if (index == 4) {
                Get.to(() => const CommunityBrowsePage());
              }
            } else {
              // When not authorized: indices: 0:Home, 1:Search, 2:Chat.
              if (index == 2) {
                Get.to(() => const ChatListPage());
              }
            }
          },
          type: BottomNavigationBarType.fixed,
        );
      }),
    );
  }
}
