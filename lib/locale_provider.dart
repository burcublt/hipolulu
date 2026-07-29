import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the active app locale.
///
/// [locale] is `null` when following the device language (default on first
/// launch). A user-selected locale is persisted and restored on next launch.
class LocaleProvider extends ChangeNotifier {
  static const _prefsKey = 'app_locale';
  static const supportedLanguageCodes = ['en', 'tr', 'es'];

  Locale? _locale;

  /// Explicit user choice, or `null` to follow the device locale.
  Locale? get locale => _locale;

  /// Effective language code for UI strings and locale-scoped assets (audio).
  String effectiveLanguageCode(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == null || code.isEmpty) {
      _locale = null;
    } else if (supportedLanguageCodes.contains(code)) {
      _locale = Locale(code);
    } else {
      _locale = null;
    }
    notifyListeners();
  }

  /// Follow the device language again.
  Future<void> useDeviceLocale() async {
    _locale = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    notifyListeners();
  }

  /// Switch language immediately across the app.
  Future<void> setLocale(Locale locale) async {
    if (!supportedLanguageCodes.contains(locale.languageCode)) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
    notifyListeners();
  }

  bool isSelected(Locale? option) {
    if (option == null) return _locale == null;
    return _locale?.languageCode == option.languageCode;
  }
}
