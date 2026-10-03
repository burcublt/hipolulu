import 'media_cache.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class CatalogService {
  static final instance = CatalogService();
  final Map<String, Map<String, dynamic>> _items = {};
  final Map<String, _CatalogResponse> _responses = {};
  final Map<String, Future<List<Map<String, dynamic>>>> _pending = {};
  final String baseUrl;
  CatalogService({this.baseUrl = base});
  static const base = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://hippolulu-api.bodrumdublin.com');
  Future<List<Map<String, dynamic>>> fetch(String path, String locale) async {
    final key = '$locale:$path';
    final cached = _responses[key];
    if (cached != null &&
        DateTime.now().difference(cached.created) < const Duration(minutes: 5)) {
      return cached.data;
    }
    return _pending.putIfAbsent(
        key,
        () => _fetch(path, locale).then((data) {
              _responses[key] = _CatalogResponse(DateTime.now(), data);
              return data;
            }).whenComplete(() { _pending.remove(key); }));
  }

  Future<List<Map<String, dynamic>>> _fetch(String path, String locale) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client
          .getUrl(Uri.parse('$baseUrl/v1/$path')
              .replace(queryParameters: {'locale': locale}))
          .timeout(const Duration(seconds: 20));
      final response =
          await request.close().timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw HttpException('Catalog ${response.statusCode}');
      }
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 20));
      final data =
          (jsonDecode(body)['data'] as List).cast<Map<String, dynamic>>();
      for (final item in data) {
        if (item['image_url'] is String) {
          _items['$locale:${item['image_url']}'] = item;
        }
      }
      return data;
    } finally {
      client.close(force: true);
    }
  }

  String? title(String url, String locale) =>
      _items['$locale:$url']?['title'] as String?;
  String? audio(String url, String locale) =>
      _items['$locale:$url']?['audio_url'] as String?;
}

ImageProvider catalogImageProvider(String path) =>
    path.startsWith('https://') || path.startsWith('http://')
        ? CachedCatalogImage(path)
        : AssetImage(path) as ImageProvider;

class CatalogLoader extends StatefulWidget {
  final String path;
  final Widget Function(BuildContext, List<Map<String, dynamic>>) builder;
  const CatalogLoader({super.key, required this.path, required this.builder});
  @override
  State<CatalogLoader> createState() => _CatalogLoaderState();
}

class _CatalogLoaderState extends State<CatalogLoader> {
  String? _locale;
  Future<List<Map<String, dynamic>>>? _future;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (_locale != locale) {
      _locale = locale;
      _load();
    }
  }

  @override
  void didUpdateWidget(CatalogLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) _load();
  }

  void _load() {
    _future = CatalogService.instance.fetch(widget.path, _locale!);
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return widget.builder(context, snapshot.data!);
          }
          return Scaffold(
              appBar: AppBar(),
              body: CatalogStatus(
                  error: snapshot.hasError, retry: () => setState(_load)));
        },
      );
}

class CatalogStatus extends StatelessWidget {
  final bool error;
  final VoidCallback retry;
  const CatalogStatus({super.key, required this.error, required this.retry});
  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: error
                ? Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                        lang == 'tr'
                            ? 'İçerikler yüklenemedi. İnternet bağlantını kontrol et.'
                            : lang == 'es'
                                ? 'No se pudo cargar el contenido. Comprueba tu conexión.'
                                : 'Could not load content. Check your internet connection.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: retry,
                        child: Text(lang == 'tr'
                            ? 'Tekrar dene'
                            : lang == 'es'
                                ? 'Reintentar'
                                : 'Try again')),
                  ])
                : const CircularProgressIndicator()));
  }
}

Future<void> loadCatalogImage(String url, BuildContext context) async {
  final stream =
      catalogImageProvider(url).resolve(createLocalImageConfiguration(context));
  final ready = Completer<void>();
  late ImageStreamListener listener;
  listener = ImageStreamListener((image, synchronousCall) {
    image.dispose();
    if (!ready.isCompleted) ready.complete();
  }, onError: (Object error, StackTrace? stack) {
    if (!ready.isCompleted) ready.completeError(error, stack);
  });
  stream.addListener(listener);
  try {
    await ready.future.timeout(const Duration(seconds: 30));
  } finally {
    stream.removeListener(listener);
  }
}

class _CatalogResponse {
  final DateTime created;
  final List<Map<String, dynamic>> data;
  _CatalogResponse(this.created, this.data);
}
