import 'dart:convert';
import 'package:flutter/services.dart';

class AssetService {
  static final AssetService _instance = AssetService._internal();
  factory AssetService() => _instance;
  AssetService._internal();

  List<String> _allAssets = [];
  bool _isLoaded = false;

  Future<void> load() async {
    if (_isLoaded) return;
    try {
      // Eski yöntem yerine Flutter'ın resmi Manifest API'sini kullanın
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _allAssets = manifest.listAssets();
      _isLoaded = true;
    } catch (e) {
      print('Error loading asset manifest: $e');
    }
  }

  List<String> getImagesForTheme(String themeId) {
    if (!_isLoaded) return [];

    final normalized = themeId.toLowerCase();
    List<String> searchPrefixes = [
      'assets/images/puzzles/$normalized/',
      'assets/images/$normalized/',
    ];

    if (normalized.endsWith('s')) {
      final singular = normalized.substring(0, normalized.length - 1);
      searchPrefixes.add('assets/images/puzzles/$singular/');
      searchPrefixes.add('assets/images/$singular/');
    } else {
      final plural = '${normalized}s';
      searchPrefixes.add('assets/images/puzzles/$plural/');
      searchPrefixes.add('assets/images/$plural/');
    }

    for (final prefix in searchPrefixes) {
      final lowerPrefix = prefix.toLowerCase();
      final matches = _allAssets.where((path) {
        final lowerPath = path.toLowerCase();
        return lowerPath.startsWith(lowerPrefix) &&
            (lowerPath.endsWith('.png') ||
                lowerPath.endsWith('.jpg') ||
                lowerPath.endsWith('.jpeg') ||
                lowerPath.endsWith('.webp'));
      }).toList();
      if (matches.isNotEmpty) {
        return matches;
      }
    }

    return [];
  }
}
