import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lencho/controllers/irrigation/weather_controller.dart';
import 'package:lencho/controllers/home/language_controller.dart';
import 'package:lencho/widgets/BushCloudRotated.dart';
import 'package:lencho/widgets/irrigation/weather_map_widget.dart'; 
class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final WeatherController weatherController = Get.put(WeatherController());
    final LanguageController languageController = Get.put(LanguageController());
    
    return Stack(
      children: [
        const SizedBox(
          height: 60,
          width: double.infinity,
          child: BushCloudRotated(),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Location icon: when tapped, navigate to the WeatherMapWidget.
                InkWell(
                  onTap: () async {
                    final result = await Get.to(() => const WeatherMapWidget());
                    if (result != null && result is LatLng) {
                      weatherController.latitude.value = result.latitude;
                      weatherController.longitude.value = result.longitude;
                      await weatherController.fetchWeather();
                      Get.snackbar(
                        'Weather Updated',
                        'Temp: ${weatherController.temperature.value.toStringAsFixed(1)}°C',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF2D5A27),
                  ),
                ),
                Row(
                  children: [
                    Image.asset('assets/images/logo.png', height: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Lencho Inc.',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF2D5A27),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Language toggle switch: shows "EN" and "HI".
                Obx(() {
                  bool isHindi = languageController.currentLanguage.value == "hi";
                  return Row(
                    children: [
                      const Text("EN", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                      Switch(
                        value: isHindi,
                        onChanged: (value) {
                          languageController.toggleLanguage();
                          Get.snackbar(
                            'Language Changed',
                            value ? 'Hindi selected' : 'English selected',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.green,
                      ),
                      const Text("HI", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
