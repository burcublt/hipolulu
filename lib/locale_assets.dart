import 'package:flutter/material.dart';

/// Helpers for locale-scoped assets (e.g. animal name audio per language).
///
/// Expected layout:
/// ```
/// assets/audio/
///   en/animals/lion_name.mp3
///   tr/animals/lion_name.mp3
///   es/animals/lion_name.mp3
/// ```
class LocaleAssets {
  LocaleAssets._();

  static const supportedCodes = ['en', 'tr', 'es'];
  static const defaultCode = 'en';

  static String resolveLanguageCode(String? code) {
    if (code != null && supportedCodes.contains(code)) return code;
    return defaultCode;
  }

  static String audioPath(String relativePath, String languageCode) {
    final code = resolveLanguageCode(languageCode);
    return 'assets/audio/$code/$relativePath';
  }

  static String audioForContext(BuildContext context, String relativePath) {
    return audioPath(relativePath, Localizations.localeOf(context).languageCode);
  }
}
