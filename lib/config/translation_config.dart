import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationConfig {
  static String _currentLanguage = 'Français';
  static OnDeviceTranslator? _frToEnTranslator;
  static OnDeviceTranslator? _enToArTranslator;
  static bool _isInitialized = false;

  // Cache to avoid re-translating the same strings
  static final Map<String, Map<String, String>> _translationCache = {
    'English': {},
    'العربية': {},
  };

  /// Initialize translators and load language preference
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      print('Initializing Translation Config...');

      // Load current language from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString('selectedLanguage') ?? 'Français';
      print('Current language: $_currentLanguage');

      // Initialize French to English translator
      _frToEnTranslator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.french,
        targetLanguage: TranslateLanguage.english,
      );

      // Initialize English to Arabic translator
      _enToArTranslator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: TranslateLanguage.arabic,
      );

      _isInitialized = true;

      // Download models in background (non-blocking)
      _downloadModelsInBackground();

      print('Translation Config initialized successfully');
    } catch (e) {
      print('Error initializing Translation Config: $e');
      _isInitialized = true; // Mark as initialized to avoid blocking
    }
  }

  /// Download translation models in background
  static Future<void> _downloadModelsInBackground() async {
    try {
      final modelManager = OnDeviceTranslatorModelManager();

      // Download English model
      final isEnDownloaded = await modelManager.isModelDownloaded(
        TranslateLanguage.english.bcpCode,
      );
      if (!isEnDownloaded) {
        print('Downloading English translation model...');
        await modelManager.downloadModel(TranslateLanguage.english.bcpCode);
        print('English model downloaded');
      }

      // Download Arabic model
      final isArDownloaded = await modelManager.isModelDownloaded(
        TranslateLanguage.arabic.bcpCode,
      );
      if (!isArDownloaded) {
        print('Downloading Arabic translation model...');
        await modelManager.downloadModel(TranslateLanguage.arabic.bcpCode);
        print('Arabic model downloaded');
      }
    } catch (e) {
      print('Error downloading translation models: $e');
    }
  }

  /// Update current language (call this when user changes language)
  static Future<void> updateLanguage(String newLanguage) async {
    _currentLanguage = newLanguage;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', newLanguage);
    print('Language updated to: $newLanguage');
  }

  /// Main translation method - translates French text to selected language
  /// If language is French, returns the original text
  /// If language is English or Arabic, translates using ML Kit
  static Future<String> translate(String frenchText) async {
    // If not initialized yet, return original text
    if (!_isInitialized) {
      await init();
    }

    // Reload language preference in case it changed
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('selectedLanguage') ?? 'Français';

    // If French, return original text
    if (_currentLanguage == 'Français') {
      return frenchText;
    }

    // Check cache first
    if (_translationCache[_currentLanguage]?.containsKey(frenchText) ?? false) {
      return _translationCache[_currentLanguage]![frenchText]!;
    }

    try {
      String translatedText = frenchText;

      if (_currentLanguage == 'English') {
        // Translate French → English
        if (_frToEnTranslator != null) {
          translatedText = await _frToEnTranslator!.translateText(frenchText);
          print('Translated "$frenchText" → "$translatedText"');

          // Cache the translation
          _translationCache['English']![frenchText] = translatedText;
        }
      } else if (_currentLanguage == 'العربية') {
        // Translate French → English → Arabic
        if (_frToEnTranslator != null && _enToArTranslator != null) {
          // Step 1: French → English
          final englishText = await _frToEnTranslator!.translateText(frenchText);

          // Step 2: English → Arabic
          translatedText = await _enToArTranslator!.translateText(englishText);
          print('Translated "$frenchText" → "$englishText" → "$translatedText"');

          // Cache the translation
          _translationCache['العربية']![frenchText] = translatedText;
        }
      }

      return translatedText;
    } catch (e) {
      print('Translation error for "$frenchText": $e');
      // Return original text if translation fails
      return frenchText;
    }
  }

  /// Get current language
  static String get currentLanguage => _currentLanguage;

  /// Dispose translators when app closes
  static Future<void> dispose() async {
    await _frToEnTranslator?.close();
    await _enToArTranslator?.close();
  }
}

/// Global shorthand function for easy use
Future<String> translate(String frenchText) async {
  return await TranslationConfig.translate(frenchText);
}