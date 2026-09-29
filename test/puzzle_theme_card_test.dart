import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'package:hippolulu/puzzle_theme_selections.dart';

void main() {
  for (final width in [100.0, 130.0, 170.0, 230.0]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('Theme cards fit width=$width textScale=$scale',
          (tester) async {
        await tester.runAsync(() async {
          final font = FontLoader('Baloo2 ExtraBold')
            ..addFont(rootBundle.load('assets/fonts/Baloo2-ExtraBold.ttf'));
          await font.load();
        });
        for (final locale in ['tr', 'en', 'es']) {
          for (final tablet in [false, true]) {
            await tester.pumpWidget(MaterialApp(
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData(fontFamily: 'Baloo2 ExtraBold'),
              home: MediaQuery(
                  data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                  child: Scaffold(
                      body: Center(
                          child: SizedBox(
                              width: width,
                              height: width / 1.48,
                              child: ThemeCard(
                                  item: puzzleThemeItems.last,
                                  isTablet: tablet,
                                  isLandscape: true))))),
            ));
            expect(tester.takeException(), isNull,
                reason: '$locale tablet=$tablet');
          }
        }
      });
    }
  }
}
