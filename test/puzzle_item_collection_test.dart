import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'package:hippolulu/puzzle_item_selection.dart';

void main() {
  for (final size in [const Size(320,568), const Size(402,874), const Size(844,390), const Size(768,1024), const Size(1194,834)]) {
    testWidgets('Collection fits and scrolls $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var selected = -1;
      var back = false;
      final names = ['Aslan', 'Fil', 'Kapibara', 'Zürafa', 'Kedi', 'Dinozorların Kayıp Taşları'];
      final files = ['lion','elephant','capybara','giraffe','cat','bear'];
      final items = List.generate(24, (i) => <String,dynamic>{'slug':'item-$i', 'title':names[i%6], 'image_url':'assets/images/puzzles/animals/${files[i%6]}.webp','locked':i==4});
      await tester.pumpWidget(MaterialApp(locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(data: MediaQueryData(size:size,padding:const EdgeInsets.only(top:44,bottom:24)),child:
          RepaintBoundary(key:const ValueKey('capture'),child:PuzzleItemCollection(themeTitle:'Hayvanlar',items:items,onBack:()=>back=true,onSelect:(i)=>selected=i)))));
      await tester.runAsync(() async {
        final font=FontLoader('Baloo2 ExtraBold')..addFont(rootBundle.load('assets/fonts/Baloo2-ExtraBold.ttf'));await font.load();
        final icons=FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));await icons.load();
        final context=tester.element(find.byType(PuzzleItemCollection));
        await Future.wait(tester.widgetList<Image>(find.byType(Image)).map((i)=>precacheImage(i.image,context)));
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(),isNull);
      expect(find.byType(SingleChildScrollView),findsNothing);
      await tester.ensureVisible(find.byKey(const ValueKey('item-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('item-0')));
      await tester.pumpAndSettle();
      expect(selected,0);
      tester.state<ScrollableState>(find.byType(Scrollable).first).position.jumpTo(0);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Geri'));
      expect(back,isTrue);
      if(size.width==402 || size.width==1194) {
        await tester.runAsync(() async {
          final image=await tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('capture'))).toImage(pixelRatio:1.5);
          final bytes=await image.toByteData(format:ui.ImageByteFormat.png);
          Directory('build/puzzle_collection_preview').createSync(recursive:true);
          File('build/puzzle_collection_preview/${size.width.toInt()}.png').writeAsBytesSync(bytes!.buffer.asUint8List());image.dispose();
        });
      }
      await tester.drag(find.byType(CustomScrollView),const Offset(0,-450));
      await tester.pumpAndSettle();
      expect(tester.takeException(),isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
  test('Responsive columns', () {
    expect(PuzzleItemCollection.columns(320),2);
    expect(PuzzleItemCollection.columns(844),3);
    expect(PuzzleItemCollection.columns(768),3);
    expect(PuzzleItemCollection.columns(1100),4);
  });
}
