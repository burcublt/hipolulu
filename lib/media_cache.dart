import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

/// Bounded disk cache shared by preloading, image widgets and audio playback.
class MediaCache {
  static final instance = MediaCache();
  final Future<Directory> Function() directory;
  final Duration maxAge;
  final int maxBytes;
  final Map<String, Future<File>> _pending = {};
  Future<void>? _cleaning;
  MediaCache(
      {Future<Directory> Function()? directory,
      this.maxAge = const Duration(days: 1),
      this.maxBytes = 200 * 1024 * 1024})
      : directory = directory ??
            (() async => Directory(
                '${(await getTemporaryDirectory()).path}/catalog_media_v1'));

  Future<File> get(String url) => _pending.putIfAbsent(
      url, () => _get(url).whenComplete(() { _pending.remove(url); }));
  Future<File> _get(String url) async {
    final root = await directory();
    await root.create(recursive: true);
    final file = File('${root.path}/${sha256.convert(utf8.encode(url))}');
    if (await file.exists()) {
      final stat = await file.stat();
      if (stat.size > 0 && DateTime.now().difference(stat.modified) < maxAge) {
        return file;
      }
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    final temp = File('${file.path}.part');
    try {
      final request = await client
          .getUrl(Uri.parse(url))
          .timeout(const Duration(seconds: 20));
      final response =
          await request.close().timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw HttpException('Media ${response.statusCode}');
      }
      if (response.contentLength > 20 * 1024 * 1024) {
        throw const HttpException('Media too large');
      }
      final sink = temp.openWrite();
      var size = 0;
      try {
        await for (final bytes
            in response.timeout(const Duration(seconds: 20))) {
          size += bytes.length;
          if (size > 20 * 1024 * 1024) {
            throw const HttpException('Media too large');
          }
          sink.add(bytes);
        }
      } finally {
        await sink.close();
      }
      if (size == 0) throw const HttpException('Empty media');
      await temp.rename(file.path);
      // Cleanup is serialized so concurrent downloads cannot race over files.
      _cleaning ??= _trim(root, file.path).whenComplete(() => _cleaning = null);
      await _cleaning;
      return file;
    } finally {
      client.close(force: true);
      if (await temp.exists()) await temp.delete();
    }
  }

  Future<void> _trim(Directory root, String keep) async {
    final files = <MapEntry<File, FileStat>>[];
    await for (final entry in root.list()) {
      if (entry is File && !entry.path.endsWith('.part')) {
        files.add(MapEntry(entry, await entry.stat()));
      }
    }
    files.sort((a, b) => a.value.modified.compareTo(b.value.modified));
    var total = files.fold<int>(0, (sum, e) => sum + e.value.size);
    for (final entry in files) {
      if (total <= maxBytes) break;
      if (entry.key.path == keep) continue;
      try {
        await entry.key.delete();
        total -= entry.value.size;
      } on FileSystemException {/* Already removed. */}
    }
  }
}

class CachedCatalogImage extends ImageProvider<CachedCatalogImage> {
  final String url;
  const CachedCatalogImage(this.url);
  @override
  Future<CachedCatalogImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);
  @override
  ImageStreamCompleter loadImage(
          CachedCatalogImage key, ImageDecoderCallback decode) =>
      MultiFrameImageStreamCompleter(codec: _decode(decode), scale: 1);
  Future<ui.Codec> _decode(ImageDecoderCallback decode) async {
    try {
      final file = await MediaCache.instance.get(url);
      return await decode(
          await ui.ImmutableBuffer.fromUint8List(await file.readAsBytes()));
    } catch (_) {
      scheduleMicrotask(() => PaintingBinding.instance.imageCache.evict(this));
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is CachedCatalogImage && other.url == url;
  @override
  int get hashCode => url.hashCode;
}
