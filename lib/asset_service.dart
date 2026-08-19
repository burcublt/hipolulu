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
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _allAssets = manifest.listAssets();
      _isLoaded = true;
    } catch (e) {
      // ignore
    }
  }

  /// Returns images for matching themes dynamically from assets/images/matching/<category>/
  List<String> getMatchingImages(String category) {
    if (!_isLoaded) return [];

    final normalized = category.toLowerCase();

    // Check for combined themes like fruitsAndVegetables
    if (normalized.contains('fruit') && normalized.contains('veg')) {
      final fruits = getMatchingImages('fruits');
      final veg = getMatchingImages('vegetables');
      final combined = [...fruits, ...veg];
      return combined;
    }

    List<String> searchPrefixes = [
      'assets/images/matching/$normalized/',
      'assets/images/$normalized/',
    ];

    if (normalized.endsWith('s')) {
      final singular = normalized.substring(0, normalized.length - 1);
      searchPrefixes.add('assets/images/matching/$singular/');
      searchPrefixes.add('assets/images/$singular/');
    } else {
      final plural = '${normalized}s';
      searchPrefixes.add('assets/images/matching/$plural/');
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

  /// Returns images for puzzle themes dynamically from assets/images/puzzles/<theme>/
  List<String> getImagesForTheme(String themeId) {
    if (!_isLoaded) return [];

    final normalized = themeId.toLowerCase();
    List<String> searchPrefixes = [
      'assets/images/puzzles/$normalized/',
      'assets/images/matching/$normalized/',
      'assets/images/$normalized/',
    ];

    if (normalized.endsWith('s')) {
      final singular = normalized.substring(0, normalized.length - 1);
      searchPrefixes.add('assets/images/puzzles/$singular/');
      searchPrefixes.add('assets/images/matching/$singular/');
      searchPrefixes.add('assets/images/$singular/');
    } else {
      final plural = '${normalized}s';
      searchPrefixes.add('assets/images/puzzles/$plural/');
      searchPrefixes.add('assets/images/matching/$plural/');
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
