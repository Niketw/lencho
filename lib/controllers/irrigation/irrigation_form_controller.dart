import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lencho/controllers/irrigation/weather_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IrrigationPlanController extends GetxController {
  final WeatherController weatherController = Get.find<WeatherController>();

  /// Classify the temperature range by dividing the average temperature (in Celsius) by 10,
  /// clamping the result between 1 and 4, and mapping to a descriptive range.
  String classifyTemperatureRange(double avgtempC) {
    int key = (avgtempC ~/ 10);
    if (key < 1) key = 1;
    if (key > 4) key = 4;
    
    Map<int, String> mapping = {
      1: "10-20",
      2: "20-30",
      3: "30-40",
      4: "40-50",
    };
    
    return mapping[key]!;
  }

  String classifyWeatherType(String condition) {
    final cond = condition.toLowerCase();
    
    // Map conditions containing keywords to our categories.
    if (cond.contains('rain') || cond.contains('shower') || cond.contains('drizzle')) {
      return 'RAINY';
    } else if (cond.contains('sunny') || cond.contains('clear') || cond.contains('partly')) {
      return 'SUNNY';
    } else if (cond.contains('wind') || cond.contains('breezy')) {
      return 'WINDY';
    } else {
      return 'NORMAL';
    }
  }


  Future<String> classifyRegion(double lat, double lng) async {
    final apiKey = dotenv.env['GEMINI_API'];
    final prompt =
        "Based on the latitude $lat and longitude $lng, classify the region into one of the following categories: DESERT, HUMID, SEMI ARID, SEMI HUMID. Respond with only one word.";

    final url = Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey"); //Replace with your API key
    
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      try {
        final region = data['candidates'][0]['content']['parts'][0]['text'].toString().trim();
        return region;
      } catch (e) {
        return "Error parsing Gemini response: $e, full response: ${response.body}";
      }

    } else {
      return "Gemini API error: ${response.statusCode}, body: ${response.body}";
    }
  }

  Future<Map<String, dynamic>> submitIrrigationPlan({
    required String cropType,
    required String soilType,
  }) async {
    double currentTemp = weatherController.temperature.value;
    double currentLat = weatherController.latitude.value;
    double currentLng = weatherController.longitude.value;

    String currentWeatherType = classifyWeatherType(weatherController.weatherType.value);
    String tempClassification = classifyTemperatureRange(currentTemp);

    String region;
    try {
      region = await classifyRegion(currentLat, currentLng);
    } catch (e) {
      region = "Unknown";
      Get.snackbar("Error", "Failed to classify region: $e");
    }

    print("cropType: $cropType");
    print("soilType: $soilType");
    print("region: $region");
    print("tempClassification: $tempClassification");
    print("weatherType: $currentWeatherType");

    return {
      "CROP TYPE": cropType,
      "SOIL TYPE": soilType,
      "REGION": region,
      "TEMPERATURE": tempClassification,
      "WEATHER CONDITION": currentWeatherType,
    };
  }

  /// Sends the irrigation plan to the API and returns a prediction (floating number).
  Future<double?> predictIrrigationPlan({
    required String cropType,
    required String soilType,
  }) async {
    // First, get the plan details.
    Map<String, dynamic> planData = await submitIrrigationPlan(
      cropType: cropType,
      soilType: soilType,
    );
    print("planData: $planData");
    // Construct the API URL.
    final url = Uri.parse("https://lencho2-irrigation.hf.space/predict-irrigation");
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(planData),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Assume API returns the prediction in a field named "prediction".
        double prediction = (data["predicted_water_requirement"] as num).toDouble();
        return prediction;
      } else {
        Get.snackbar("Error", "Prediction API returned: ${response.statusCode}");
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      Get.snackbar("Error", "Error predicting irrigation: $e");
      return null;
    }
  }
}
