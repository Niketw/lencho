import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lencho/controllers/home/authUser_controller.dart';
import 'package:lencho/widgets/home/header_widgets.dart';
import 'package:lencho/widgets/home/content_widgets.dart';
import 'package:lencho/widgets/home/footer_widgets.dart';
import 'package:lencho/widgets/home/background_widget.dart'; // Adjust the path

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "Guest";
    final AuthUserController authController = Get.put(AuthUserController());
    
    return BackgroundGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make the scaffold background transparent.
        body: Column(
          children: const [
            HomeHeader(isHome: true), // Fixed header
            Expanded(       // HomeContent scrolls within the remaining space
              child: HomeContent(),
            ),
          ],
        ),
        bottomNavigationBar: const FooterNavigationBar(),
      ),
    );
  }
}
