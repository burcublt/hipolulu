import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippolulu/unlock_screen.dart';
import 'package:hippolulu/l10n/app_localizations.dart';

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(402, 874),
    const Size(768, 1024)
  ]) {
    for (final locale in ['tr', 'en', 'es']) {
      testWidgets('Unlock layout $size $locale', (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(MaterialApp(
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(fontFamily: 'Baloo2 ExtraBold'),
            home: MediaQuery(
                data: MediaQueryData(
                    size: size,
                    padding: const EdgeInsets.only(top: 50, bottom: 24),
                    textScaler: TextScaler.linear(size.width == 320 ? 1.5 : 1)),
                child: const RepaintBoundary(
                    key: ValueKey('capture'), child: UnlockScreen()))));
        await tester.runAsync(() async {
          for (final name in ['Baloo2 ExtraBold', 'Baloo2']) {
            final file = name == 'Baloo2'
                ? 'Baloo2-Regular.ttf'
                : 'Baloo2-ExtraBold.ttf';
            await (FontLoader(name)
                  ..addFont(rootBundle.load('assets/fonts/$file')))
                .load();
          }
          await (FontLoader('MaterialIcons')
                ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
              .load();
          final context = tester.element(find.byType(UnlockScreen));
          await Future.wait(tester
              .widgetList<Image>(find.byType(Image))
              .map((i) => precacheImage(i.image, context)));
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (size.width == 402 && locale == 'tr') {
          await tester.runAsync(() async {
            final image = await tester
                .renderObject<RenderRepaintBoundary>(
                    find.byKey(const ValueKey('capture')))
                .toImage(pixelRatio: 2);
            final bytes =
                await image.toByteData(format: ui.ImageByteFormat.png);
            Directory('build/unlock_preview').createSync(recursive: true);
            File('build/unlock_preview/phone.png')
                .writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        expect(find.byType(Scrollable), findsNothing);
        final l =
            AppLocalizations.of(tester.element(find.byType(UnlockScreen)))!;
        expect(find.text(l.unlockRestore).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
