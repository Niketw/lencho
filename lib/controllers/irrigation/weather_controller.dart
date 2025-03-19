import 'dart:convert';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lencho/widgets/irrigation/weather_map_widget.dart'; // This should point to your LocationPickerScreen

class WeatherController extends GetxController {
  // Observable variables to hold weather data.
  RxDouble temperature = 0.0.obs;
  RxString locationName = ''.obs;
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;

  // Replace with your actual WeatherAPI key.
  final String apiKey = 'WEATHER_API';
  // WeatherAPI endpoint for current weather.
  final String baseUrl = 'http://api.weatherapi.com/v1/current.json';

  @override
  void onInit() {
    super.onInit();
    // We no longer call fetchLocationAndWeather() automatically.
    // The user must tap the location icon.
  }

  Future<void> fetchLocationAndWeather() async {
    // Request location permission.
    PermissionStatus status = await Permission.location.request();
    if (!status.isGranted) {
      Get.snackbar('Permission Denied', 'Location permission is required');
      // If permission is not granted, open the manual location picker.
      await pickLocationManually();
      return;
    }
    
    try {
      // Obtain current position.
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude.value = position.latitude;
      longitude.value = position.longitude;
      
      // After obtaining coordinates, fetch the weather.
      await fetchWeather();
    } catch (e) {
      Get.snackbar('Error', 'Error obtaining location: $e');
    }
  }

  Future<void> fetchWeather() async {
    final url = Uri.parse('$baseUrl?key=$apiKey&q=${latitude.value},${longitude.value}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        temperature.value = (data['current']['temp_c'] ?? 0).toDouble();
        locationName.value = data['location']['name'] ?? 'Unknown';
      } else {
        Get.snackbar('Error', 'Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching weather data: $e');
    }
  }

  // Open the location picker to manually select a location.
  Future<void> pickLocationManually() async {
    final result = await Get.to(() => const WeatherMapWidget());
    if (result != null && result is LatLng) {
      latitude.value = result.latitude;
      longitude.value = result.longitude;
      await fetchWeather();
    }
  }
}
