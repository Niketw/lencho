import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/home/language_controller.dart';
import 'package:lencho/widgets/irrigation/location_widget.dart';
import 'package:lencho/widgets/BushCloudRotated.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Register or retrieve the language controller.
    final LanguageController languageController = Get.put(LanguageController());
    
    // Define the total header height.
    const double headerHeight = 140.0;
    
    return Container(
      height: headerHeight,
      child: Stack(
        children: [
          // Slim Ace268 rectangle at the very top.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 20,
            child: Container(
              color: const Color(0xFFACE268),
            ),
          ),
          // Fixed BushCloudRotated header.
          Positioned(
            top: 20, // Start right below the slim rectangle.
            left: 0,
            right: 0,
            height: 120,
            child: const BushCloudRotated(),
          ),
          // Header controls (location icon, logo/title, language toggle) on top of the bush cloud.
          Positioned(
            top: 20, // Align with the bush cloud top.
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location icon.
                    InkWell(
                      onTap: () {
                        Get.to(() => const LocationPickerScreen());
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF2D5A27),
                        size: 32,
                      ),
                    ),
                    // Logo and title.
                    Row(
                      children: [
                        Image.asset('assets/images/logo.png', height: 32),
                        const SizedBox(width: 8),
                        const Text(
                          'Lencho Inc.',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFF2D5A27),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Language toggle switch.
                    Obx(() {
                      bool isHindi = languageController.currentLanguage.value == "hi";
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "EN",
                              style: TextStyle(
                                color: const Color(0xFF2D5A27),
                                fontWeight: isHindi ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                            Switch(
                              value: isHindi,
                              onChanged: (value) async {
                                languageController.toggleLanguage();
                                if (value) {
                                  try {
                                    String translatedTitle = await languageController.translate(
                                      "Lencho Inc.",
                                      targetLang: "hi",
                                    );
                                    Get.snackbar(
                                      'Language Changed',
                                      'Hindi selected: $translatedTitle',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  } catch (e) {
                                    Get.snackbar('Error', 'Translation failed: $e');
                                  }
                                } else {
                                  Get.snackbar(
                                    'Language Changed',
                                    'English selected',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              },
                              activeColor: Colors.white,
                              activeTrackColor: const Color(0xFF2D5A27),
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: const Color(0xFF2D5A27),
                            ),
                            Text(
                              "हि",
                              style: TextStyle(
                                color: const Color(0xFF2D5A27),
                                fontWeight: isHindi ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
