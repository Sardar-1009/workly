import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton that manages the app locale. Default is Russian (ru).
/// Persists the user's choice across sessions via SharedPreferences.
class LanguageManager extends ValueNotifier<Locale> {
  static final LanguageManager _instance = LanguageManager._internal();

  factory LanguageManager() => _instance;

  LanguageManager._internal() : super(const Locale('ru'));

  static const String _key = 'app_locale';

  static const List<Locale> supportedLocales = [
    Locale('ru'),
    Locale('en'),
  ];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'ru';
    value = Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }

  bool get isRussian => value.languageCode == 'ru';
}
