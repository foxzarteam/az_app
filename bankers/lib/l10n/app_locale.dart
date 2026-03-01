import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'translations.dart';

/// Holds app locale ('en' | 'hi'), persists to SharedPreferences, and provides t(key).
class AppLocale extends ChangeNotifier {
  AppLocale() : _locale = 'en' {
    _load();
  }

  static const String localeEn = 'en';
  static const String localeHi = 'hi';

  String _locale = localeEn;
  String get locale => _locale;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(AppConstants.keyAppLocale);
      if (saved == localeHi || saved == localeEn) {
        _locale = saved!;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLocale(String value) async {
    if (value != localeEn && value != localeHi) return;
    _locale = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyAppLocale, value);
    } catch (_) {}
  }

  /// Returns translated string for current locale; falls back to English then key.
  String t(String key) {
    final map = appTranslations[key];
    if (map == null) return key;
    return map[_locale] ?? map[localeEn] ?? key;
  }
}

/// Use in UI: context.t('labelHome') so text updates when locale changes.
extension AppLocaleExtension on BuildContext {
  String t(String key) => Provider.of<AppLocale>(this, listen: true).t(key);
  /// Use when showing errors: if [keyOrMessage] is a translation key, returns translated; else returns as-is.
  String tOrRaw(String keyOrMessage) =>
      appTranslations.containsKey(keyOrMessage) ? t(keyOrMessage) : keyOrMessage;
}
