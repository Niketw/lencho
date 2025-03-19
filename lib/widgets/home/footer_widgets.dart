import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/home/authUser_controller.dart';
import 'package:lencho/controllers/home/logout_controller.dart';
import 'package:lencho/screens/chat/chat_list_page.dart';
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
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ];
      } else {
        items = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ];
      }

      return BottomNavigationBar(
        items: items,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (isAuth) {
            if (index == 1) {
              Get.to(() => PostingWidget());
            } else if (index == 3) {
              Get.to(() => const ChatListPage());
            } else if (index == 4) {
              LogoutController.instance.logout();
            }
          } else {
            if (index == 2) {
              Get.to(() => const ChatListPage());
            } else if (index == 3) {
              LogoutController.instance.logout();
            }
          }
        },
      );
    });
  }
}
