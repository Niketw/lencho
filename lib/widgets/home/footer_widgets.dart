import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/home/authUser_controller.dart';
import 'package:lencho/controllers/home/logout_controller.dart';
import 'package:lencho/widgets/chat/chat_list_page.dart';
import 'package:lencho/widgets/community/community_browse_page.dart';
import 'package:lencho/widgets/campaign/posting_widget.dart';

class FooterNavigationBar extends StatelessWidget {
  const FooterNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve the AuthUserController to check if the user is authorized.
    final AuthUserController authController = Get.find<AuthUserController>();

    return Obx(() {
      bool isAuth = authController.isAuthorized.value;
      List<BottomNavigationBarItem> items;
      if (isAuth) {
        items = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
      } else {
        items = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
      }

      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFFFF4BE),
              Color(0xFFACE268),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D5A27).withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: items,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF2D5A27),
          unselectedItemColor: const Color(0xFF557153),
          elevation: 0,
          onTap: (index) {
            if (isAuth) {
              if (index == 0) {
                // Do nothing, already on home
              } else if (index == 1) {
                Get.to(() => PostingWidget());
              } else if (index == 2) {
                Get.to(() => const CommunityBrowsePage());
              } else if (index == 3) {
                Get.to(() => const ChatListPage());
              } else if (index == 4) {
                // Profile or logout
                _showProfileOptions(context);
              }
            } else {
              if (index == 0) {
                // Do nothing, already on home
              } else if (index == 1) {
                Get.to(() => const CommunityBrowsePage());
              } else if (index == 2) {
                Get.to(() => const ChatListPage());
              } else if (index == 3) {
                // Profile or logout
                _showProfileOptions(context);
              }
            }
          },
        ),
      );
    });
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF4BE),
              Color(0xFFACE268),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF2D5A27),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: const Text(
                  'Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A27),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to profile page
                },
              ),
              const Divider(color: Color(0xFF2D5A27)),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF2D5A27),
                  child: Icon(Icons.logout, color: Colors.white),
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A27),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  LogoutController.instance.logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
