import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lencho/controllers/home/authUser_controller.dart';
import 'package:lencho/controllers/irrigation/weather_controller.dart';
import 'package:lencho/widgets/home/header_widgets.dart';
import 'package:lencho/widgets/home/content_widgets.dart';
import 'package:lencho/widgets/home/footer_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final WeatherController weatherController = Get.put(WeatherController());
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "Guest";
    final AuthUserController authController = Get.put(AuthUserController());
    
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          if (weatherController.temperature.value == 0.0) {
            return const Text('Loading weather...');
          }
          return Text(
            'Weather in ${weatherController.locationName.value}: ${weatherController.temperature.value.toStringAsFixed(1)}°C',
          );
        }),
      ),
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
