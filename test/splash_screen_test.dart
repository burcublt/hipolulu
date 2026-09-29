import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'package:hippolulu/splash_scene.dart';
import 'package:hippolulu/splash_screen.dart';

Widget app(Widget child, {String language = 'en'}) => MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final portrait = media.size.width < media.size.height;
        return MediaQuery(
            data: media.copyWith(
                padding: portrait
                    ? const EdgeInsets.fromLTRB(0, 44, 0, 24)
                    : const EdgeInsets.fromLTRB(44, 0, 44, 16)),
            child: child!);
      },
      home: child,
    );

Future<void> warm(WidgetTester tester) async {
  await tester.runAsync(() async {
    final context = tester.element(find.byType(Scaffold).first);
    await Future.wait(SplashAssets.paths
        .map((path) => precacheImage(SplashAssets.provider(path), context)));
    final font = FontLoader('Baloo2 ExtraBold')
      ..addFont(rootBundle.load('assets/fonts/Baloo2-ExtraBold.ttf'));
    await font.load();
  });
  await tester.pump();
}

void main() {
  final sizes = [
    const Size(430, 932),
    const Size(932, 430),
    const Size(768, 1024),
    const Size(1024, 768)
  ];
  for (final size in sizes) {
    testWidgets('Splash stages fit $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final boundary = GlobalKey();
      await tester.pumpWidget(app(
          Scaffold(
              body: RepaintBoundary(
                  key: boundary, child: const SplashScene(seconds: 0))),
          language: 'tr'));
      await warm(tester);
      for (final time in [0.0, 0.75, 1.5, 2.5, 3.5, 4.25]) {
        await tester.pumpWidget(app(
            Scaffold(
                body: RepaintBoundary(
                    key: boundary, child: SplashScene(seconds: time))),
            language: 'tr'));
        expect(tester.takeException(), isNull);
        for (final key in ['splash-logo', 'splash-play-label']) {
          final rect = tester.getRect(find.byKey(ValueKey(key)));
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(size.width));
          expect(rect.bottom, lessThanOrEqualTo(size.height));
        }
      }
      await tester.runAsync(() async {
        final image = await (boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        Directory('build/splash_preview').createSync(recursive: true);
        File('build/splash_preview/${size.width.toInt()}x${size.height.toInt()}.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets(
      'Splash requests portrait only and does not unlock during navigation',
      (tester) async {
    final orientations = <dynamic>[];
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemChrome.setPreferredOrientations') {
        orientations.add(call.arguments);
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(app(SplashScreen(onFinished: () {})));
    expect(orientations, [
      ['DeviceOrientation.portraitUp']
    ]);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(orientations, [
      ['DeviceOrientation.portraitUp']
    ]);
  });

  testWidgets('Navigation waits for the timeline and fires exactly once',
      (tester) async {
    var finishes = 0;
    await tester.pumpWidget(app(SplashScreen(onFinished: () => finishes++)));
    await warm(tester);
    expect(find.byType(SplashScene), findsOneWidget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 4400));
    expect(finishes, 0);
    await tester.pump(const Duration(milliseconds: 200));
    expect(finishes, 1);
    await tester.pump(const Duration(seconds: 2));
    expect(finishes, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Removing splash early never navigates', (tester) async {
    var finishes = 0;
    await tester.pumpWidget(app(SplashScreen(onFinished: () => finishes++)));
    await warm(tester);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
    expect(finishes, 0);
    expect(tester.takeException(), isNull);
  });

  for (final language in ['en', 'tr', 'es']) {
    testWidgets('Localized label and reduced motion in $language',
        (tester) async {
      await tester.pumpWidget(app(
          const Scaffold(body: SplashScene(seconds: 0, reduceMotion: true)),
          language: language));
      await warm(tester);
      final context = tester.element(find.byType(LetsPlayLabel));
      expect(tester.widget<LetsPlayLabel>(find.byType(LetsPlayLabel)).text,
          AppLocalizations.of(context)!.letsPlay);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
