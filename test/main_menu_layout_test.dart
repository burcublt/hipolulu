import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippolulu/main.dart';
import 'package:hippolulu/l10n/app_localizations.dart';

void main() {
  for (final size in [const Size(402,874),const Size(320,568),const Size(430,932),const Size(768,1024)]) {
    testWidgets('Main menu fits without scrolling $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(fontFamily: 'Baloo2 ExtraBold'),
        home: MediaQuery(data: MediaQueryData(size:size,padding:const EdgeInsets.only(top:62,bottom:34)),
          child: RepaintBoundary(key: const ValueKey('capture'),child: MainMenu(onModeSelect: (_) {})))));
      await tester.runAsync(() async {
        final font=FontLoader('Baloo2 ExtraBold')..addFont(rootBundle.load('assets/fonts/Baloo2-ExtraBold.ttf')); await font.load();
        final icons=FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')); await icons.load();
        final context=tester.element(find.byType(MainMenu));
        await Future.wait(tester.widgetList<Image>(find.byType(Image)).map((i)=>precacheImage(i.image,context)));
      });
      await tester.pump();
      expect(find.byType(SingleChildScrollView),findsNothing);
      expect(tester.takeException(),isNull);
      for(final scroll in tester.stateList<ScrollableState>(find.byType(Scrollable))) {
        expect(scroll.position.maxScrollExtent,0);
      }
      for(final text in ['YAPBOZ','EŞLEŞTİRME','BOYAMA','SAYMA']) {
        final label=find.text(text);
        expect(label,findsOneWidget);
        expect(tester.getRect(label).bottom,lessThanOrEqualTo(size.height-34));
      }
      if(size.width==402) {
        await tester.runAsync(() async {
          final image=await tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('capture'))).toImage(pixelRatio:2);
          final bytes=await image.toByteData(format:ui.ImageByteFormat.png);
          Directory('build/main_menu_preview').createSync(recursive:true);
          File('build/main_menu_preview/restored.png').writeAsBytesSync(bytes!.buffer.asUint8List());image.dispose();
        });
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
