import 'dart:convert';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:lencho/widgets/irrigation/location_widget.dart'; // For manual location picking
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

class WeatherController extends GetxController {
  RxDouble temperature = 0.0.obs;
  RxString locationName = ''.obs;
  RxString weatherType = ''.obs; 
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;

  // Get the API key from the .env file.
  final String apiKey = dotenv.env['WEATHER_API'] ?? 'DEFAULT_API_KEY';

  @override
  void onInit() {
    super.onInit();
    fetchLocationFromUserDetails();
  }

  Future<void> fetchLocationFromUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User not logged in.');
      return;
    }
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('UserDetails')
          .where('email', isEqualTo: user.email?.trim())
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        final lat = data['latitude'];
        final lng = data['longitude'];
        if (lat != null && lng != null) {
          latitude.value = (lat as num).toDouble();
          longitude.value = (lng as num).toDouble();
          await fetchWeather();
        } else {
          Get.snackbar('Error', 'Latitude or longitude not found in user details.');
        }
      } else {
        Get.snackbar('Error', 'User details not found.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user location: $e');
    }
  }

  Future<void> fetchWeather() async {
    final url = Uri.parse(
      'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=${latitude.value},${longitude.value}&days=7'
    );
    print("Fetching weather with URL: $url");
    try {
      final response = await http.get(url);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        temperature.value = (data['current']['temp_c'] ?? 0).toDouble();
        locationName.value = data['location']['name'] ?? 'Unknown';
        weatherType.value = data['current']['condition']['text'] ?? 'Unknown';
      } else {
        Get.snackbar('Error', 'Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching weather: $e");
      Get.snackbar('Error', 'Error fetching weather data: $e');
    }
  }

  // Open the location picker to manually select a location.
  Future<void> pickLocationManually() async {
    final result = await Get.to(() => const LocationPickerScreen());
    if (result != null && result is LatLng) {
      latitude.value = result.latitude;
      longitude.value = result.longitude;
      await fetchWeather();
    }
  }
}
