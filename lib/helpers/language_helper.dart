import 'package:shared_preferences/shared_preferences.dart';

class LanguageHelper {
  // Get current language from SharedPreferences
  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedLanguage') ?? 'Français';
  }

  // Set language in SharedPreferences
  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
  }
}

// How to use in any page:
//
// String currentLang = await LanguageHelper.getCurrentLanguage();
// print('Current language: $currentLang'); // Output: Français, English, or العربية