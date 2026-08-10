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
    // Ensure we match the directory exactly
    final prefix = 'assets/images/puzzles/$themeId/';
    return _allAssets.where((path) {
      final lowerPath = path.toLowerCase();
      return path.startsWith(prefix) &&
          (lowerPath.endsWith('.png') ||
              lowerPath.endsWith('.jpg') ||
              lowerPath.endsWith('.jpeg') ||
              lowerPath.endsWith('.webp'));
    }).toList();
  }
}
