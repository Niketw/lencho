import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/irrigation/weather_controller.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final WeatherController weatherController = Get.put(WeatherController());
    
    return Obx(() {
      // Display a placeholder until weather is loaded.
      if (weatherController.temperature.value == 0) {
        return const Padding(
          padding: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0, bottom: 16.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      
      return Padding(
        padding: const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0, bottom: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF4BE),
                Color(0xFFACE268),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D5A27).withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wb_sunny, color: Color(0xFF2D5A27)),
              const SizedBox(width: 8),
              Text(
                'Temp: ${weatherController.temperature.value.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A27),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
