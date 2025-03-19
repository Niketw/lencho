import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lencho/screens/chat/chat_list_page.dart';
import 'package:lencho/widgets/campaign/posting_widget.dart'; // This widget shows campaigns.
import 'package:lencho/widgets/home/header_widgets.dart';
import 'package:lencho/widgets/home/content_widgets.dart';
import 'package:lencho/controllers/home/authUser_controller.dart';
import 'package:lencho/controllers/irrigation/weather_controller.dart';

/// HomePage displays header, content, and conditionally an "Add" button for authorized users.
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final WeatherController weatherController = Get.put(WeatherController());
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "Guest";
    
    // Initialize the AuthUserController.
    final AuthUserController authController = Get.put(AuthUserController());
    
    return Scaffold(
      appBar: AppBar(
        // Use Obx to dynamically update the title based on weather data.
        title: Obx(() {
          if (weatherController.temperature.value == 0.0) {
            return const Text('Loading weather...');
          }
          return Text(
            'Weather in ${weatherController.locationName.value}: ${weatherController.temperature.value.toStringAsFixed(1)}°C',
          );
        }),
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
        ];
        
        return BottomNavigationBar(
          items: items,
          onTap: (index) {
            if (isAuth) {
              // When authorized: indices: 0:Home, 1:Add, 2:Search, 3:Chat.
              if (index == 1) {
                // Navigate to campaign posting.
                Get.to(() => PostingWidget());
              } else if (index == 3) {
                Get.to(() => const ChatListPage());
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
