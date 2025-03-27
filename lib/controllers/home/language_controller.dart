import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LanguageController extends GetxController {
  // "en" for English, "hi" for Hindi.
  RxString currentLanguage = "en".obs;

  // Load API key and host from environment variables.
  final String apiKey = dotenv.env['TRANSLATE_API'] ?? "";
  final String hostKey = dotenv.env['RAPIDAPI_HOST'] ?? "google-api31.p.rapidapi.com";

  // Standard endpoint for the translation API.
  final String baseUrl = "https://google-api31.p.rapidapi.com/gtranslate";

  void toggleLanguage() {
    if (currentLanguage.value == "en") {
      currentLanguage.value = "hi";
    } else {
      currentLanguage.value = "en";
    }
  }

  Future<String> translate(String text, {String targetLang = "hi"}) async {
    // If current language is English or target language is English, return original text.
    if (currentLanguage.value == "en" || targetLang == "en") {
      return text;
    }
    
    final uri = Uri.parse(baseUrl); // No query parameters needed in this case.
    
    final response = await http.post(
      uri,
      headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': hostKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': text,
        'to': targetLang,
        'from_lang': 'en',
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Extract the translated text directly.
      return data['translated_text'] as String;
    } else {
      throw Exception("Translation failed: ${response.statusCode}");
    }
  }
}
