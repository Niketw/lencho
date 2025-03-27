import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lencho/controllers/home/authUser_controller.dart';
import 'package:lencho/widgets/home/header_widgets.dart';
import 'package:lencho/widgets/home/content_widgets.dart';
import 'package:lencho/widgets/home/footer_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "Guest";
    final AuthUserController authController = Get.put(AuthUserController());
    
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: const [
              HomeHeader(),
              HomeContent(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const FooterNavigationBar(),
    );
  }
}
