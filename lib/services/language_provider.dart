// lib/services/language_provider.dart

import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!supportedLocales.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }

  void changeLanguage(String languageCode) {
    setLocale(Locale(languageCode));
  }

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('kn'), // Kannada
    Locale('hi'), // Hindi
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'kn': 'ಕನ್ನಡ',
    'hi': 'हिन्दी',
  };

  static const Map<String, String> languageFlags = {
    'en': '🇬🇧',
    'kn': '🇮🇳',
    'hi': '🇮🇳',
  };
}
