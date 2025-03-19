import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LanguageController extends GetxController {
  // "en" for English, "hi" for Hindi.
  RxString currentLanguage = "en".obs;


  final String apiKey = "TRANSLATE_API";

  final String baseUrl = "https://translation.googleapis.com/language/translate/v2";

  void toggleLanguage() {
    if (currentLanguage.value == "en") {
      currentLanguage.value = "hi";
    } else {
      currentLanguage.value = "en";
    }
  }

  Future<String> translate(String text, {String targetLang = "hi"}) async {
    if (currentLanguage.value == "en" || targetLang == "en") {
      return text;
    }
    final response = await http.post(
      Uri.parse('$baseUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'q': text,
        'target': targetLang,
        'format': 'text',
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final translations = data['data']['translations'];
      if (translations != null && translations.isNotEmpty) {
        return translations[0]['translatedText'];
      }
      return text;
    } else {
      throw Exception("Translation failed: ${response.statusCode}");
    }
  }
}
