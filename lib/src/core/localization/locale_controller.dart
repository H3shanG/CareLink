import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController {
  static final ValueNotifier<Locale> currentLocale = ValueNotifier(
    const Locale('en'),
  );

  static const Set<String> supportedLanguages = {'en', 'si', 'ta'};

  static Future<void> loadSavedLocale() async {
    final preferences = await SharedPreferences.getInstance();

    final savedLanguage = preferences.getString('app_language') ?? 'en';

    if (supportedLanguages.contains(savedLanguage)) {
      currentLocale.value = Locale(savedLanguage);
    }
  }

  static Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguages.contains(languageCode)) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();

    await preferences.setString('app_language', languageCode);

    currentLocale.value = Locale(languageCode);
  }
}
