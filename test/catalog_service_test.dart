import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippolulu/catalog_service.dart';

void main() {
  test(
      'locale-specific titles/audio and HTTP failures do not use local fallback',
      () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      if (request.uri.path.endsWith('/locked')) {
        request.response.statusCode = 403;
      } else {
        final locale = request.uri.queryParameters['locale'];
        request.response.write(jsonEncode({
          'data': [
            {
              'image_url': 'https://example.com/bear.webp',
              'title': locale == 'tr' ? 'Ayı' : 'Bear',
              'audio_url':
                  locale == 'tr' ? null : 'https://example.com/bear.mp3'
            }
          ]
        }));
      }
      await request.response.close();
    });
    final service = CatalogService(baseUrl: 'http://127.0.0.1:${server.port}');
    await service.fetch('contents', 'en');
    await service.fetch('contents', 'tr');
    expect(service.title('https://example.com/bear.webp', 'tr'), 'Ayı');
    expect(service.title('https://example.com/bear.webp', 'en'), 'Bear');
    expect(service.audio('https://example.com/bear.webp', 'tr'), isNull);
    expect(
        service.audio('https://example.com/bear.webp', 'en'), endsWith('.mp3'));
    await expectLater(
        service.fetch('locked', 'en'), throwsA(isA<HttpException>()));
  });
}
