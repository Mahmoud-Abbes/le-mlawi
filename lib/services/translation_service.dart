import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  OnDeviceTranslator? _frenchTranslator;
  OnDeviceTranslator? _arabicTranslator;
  String _currentLanguage = 'Français';

  // Initialize
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('selectedLanguage') ?? 'Français';

    _frenchTranslator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.french,
    );

    _arabicTranslator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.arabic,
    );
  }

  // Translate text
  Future<String> translate(String text) async {
    if (text.isEmpty || _currentLanguage == 'English') return text;

    try {
      if (_currentLanguage == 'Français') {
        return await _frenchTranslator!.translateText(text);
      } else if (_currentLanguage == 'العربية') {
        return await _arabicTranslator!.translateText(text);
      }
      return text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  // Change language
  Future<void> changeLanguage(String language) async {
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
  }

  String get currentLanguage => _currentLanguage;
}