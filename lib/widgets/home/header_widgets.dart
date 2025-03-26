import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart'; // Use latlong2 for LatLng type.
import 'package:lencho/controllers/irrigation/weather_controller.dart';
import 'package:lencho/controllers/home/language_controller.dart';
import 'package:lencho/widgets/BushCloudRotated.dart';
import 'package:lencho/widgets/irrigation/location_widget.dart'; // Your flutter_map-based location picker

class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Register or retrieve controllers.
    final WeatherController weatherController = Get.put(WeatherController());
    final LanguageController languageController = Get.put(LanguageController());

    return Container(
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
            color: const Color(0xFF2D5A27).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          const Positioned.fill(
            child: BushCloudRotated(),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Location button with rounded design
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final result =
                          await Get.to(() => const LocationPickerScreen());
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
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF2D5A27),
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Centered logo and title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset('assets/images/logo.png', height: 24),
                    ),
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

                // Language toggle with better styling
                Obx(() {
                  bool isHindi =
                      languageController.currentLanguage.value == "hi";
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "EN",
                          style: TextStyle(
                            color: isHindi
                                ? Colors.black54
                                : const Color(0xFF2D5A27),
                            fontWeight:
                                isHindi ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
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
                          activeTrackColor: const Color(0xFF2D5A27),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFF2D5A27),
                        ),
                        Text(
                          "HI",
                          style: TextStyle(
                            color: isHindi
                                ? const Color(0xFF2D5A27)
                                : Colors.black54,
                            fontWeight:
                                isHindi ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
