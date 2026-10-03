import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippolulu/media_cache.dart';
import 'package:hippolulu/matching_theme_select.dart';
import 'package:flutter/material.dart';

void main() {
  test(
      'disk survives new cache, concurrent loads deduplicate, expiry refreshes, errors retry',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('hippolulu-cache-test-');
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async {
      await server.close(force: true);
      await directory.delete(recursive: true);
    });
    var requests = 0;
    var fail = false;
    server.listen((r) async {
      requests++;
      if (fail) {
        r.response.statusCode = 404;
      } else {
        r.response.add([1, 2, 3, 4]);
      }
      await r.response.close();
    });
    final url = 'http://127.0.0.1:${server.port}/image';
    final cache = MediaCache(directory: () async => directory);
    final files = await Future.wait(List.generate(5, (_) => cache.get(url)));
    expect(requests, 1);
    expect(await files.first.readAsBytes(), [1, 2, 3, 4]);
    await MediaCache(directory: () async => directory).get(url);
    expect(requests, 1);
    await files.first
        .setLastModified(DateTime.now().subtract(const Duration(days: 2)));
    await cache.get(url);
    expect(requests, 2);
    fail = true;
    await expectLater(cache.get('$url-missing'), throwsA(isA<HttpException>()));
    fail = false;
    await cache.get('$url-missing');
    expect(requests, 4);
    expect(
        directory.listSync().where((f) => f.path.endsWith('.part')), isEmpty);
  });
  test('original theme palette is preserved', () {
    expect(matchingThemeColor('animals'), const Color(0xFFFFE9A9));
    expect(matchingThemeColor('fruits'), const Color(0xFFFFD8E8));
    expect(matchingThemeColor('vegetables'), const Color(0xFFD9F7D4));
    expect(matchingThemeColor('vehicles'), const Color(0xFFD6EDFF));
  });
}
