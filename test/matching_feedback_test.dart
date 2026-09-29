import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippolulu/asset_service.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'package:hippolulu/matching_game.dart';
import 'package:hippolulu/matching_feedback.dart';
import 'package:hippolulu/matching_level_complete_dialog.dart';

Widget app() => MaterialApp(
    theme: ThemeData(fontFamily: 'Baloo2 ExtraBold'),
    locale: const Locale('tr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) {
      final m = MediaQuery.of(context);
      return MediaQuery(
          data: m.copyWith(
              padding: m.size.width > m.size.height
                  ? const EdgeInsets.fromLTRB(44, 0, 44, 21)
                  : const EdgeInsets.fromLTRB(0, 44, 0, 24)),
          child: child!);
    },
    home: RepaintBoundary(
        key: const ValueKey('capture'),
        child: MatchingGame(theme: MatchingTheme.animals, onBack: () {})));
Finder card(String id) => find.byKey(ValueKey('matching-card-$id'));
bool face(WidgetTester t, String id) =>
    (t.widget(card(id)) as dynamic).faceUp as bool;
Future<void> start(WidgetTester t) async {
  await t.runAsync(() async {
    await AssetService().load();
    final font = FontLoader('Baloo2 ExtraBold')
      ..addFont(rootBundle.load('assets/fonts/Baloo2-ExtraBold.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  await t.pumpWidget(app());
  await t.runAsync(() async {
    final context = t.element(find.byType(MatchingGame));
    await Future.wait(MatchingFeedbackOverlay.assets
        .map((p) => precacheImage(AssetImage(p), context)));
    await Future.wait(t
        .widgetList<Image>(find.byType(Image))
        .map((image) => precacheImage(image.image, context)));
  });
  await t.pump(const Duration(seconds: 11));
  await t.pump(const Duration(milliseconds: 300));
}

Future<void> select(WidgetTester t, String a, String b) async {
  await t.tap(card(a));
  await t.pump();
  await t.tap(card(b));
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    for (final name in [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events'
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(name), (call) async {
        if (call.method == 'create') {
          final id = (call.arguments as Map)['playerId'];
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                  MethodChannel('xyz.luan/audioplayers/events/$id'),
                  (_) async => null);
        }
        return 1;
      });
    }
  });
  testWidgets(
      'Wrong feedback locks input, closes at 1050ms and unlocks at 1300ms',
      (t) async {
    await start(t);
    await select(t, '0-a', '1-a');
    expect(
        t
            .widget<MatchingFeedbackOverlay>(
                find.byType(MatchingFeedbackOverlay))
            .state,
        FeedbackState.wrong);
    await t.tap(card('2-a'), warnIfMissed: false);
    await t.pump();
    expect(face(t, '2-a'), false);
    await t.pump(const Duration(milliseconds: 1000));
    expect(face(t, '0-a'), true);
    await t.pump(const Duration(milliseconds: 110));
    expect(face(t, '0-a'), false);
    await t.pump(const Duration(milliseconds: 250));
    expect(find.byType(MatchingFeedbackOverlay), findsNothing);
    await t.tap(card('2-a'));
    await t.pump();
    expect(face(t, '2-a'), true);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets(
      'Correct stays matched, ignores retaps and final feedback precedes dialog',
      (t) async {
    await start(t);
    for (var i = 0; i < 5; i++) {
      await select(t, '$i-a', '$i-b');
      expect(find.byType(MatchingFeedbackOverlay), findsOneWidget);
      expect(find.byType(MatchingLevelCompleteDialog), findsNothing);
      await t.pump(Duration(milliseconds: i == 4 ? 700 : 1000));
      expect(find.byType(MatchingFeedbackOverlay), findsNothing);
      expect(find.byKey(const ValueKey('golden-check')), findsNWidgets(2));
      expect(find.byType(MatchingLevelCompleteDialog), findsNothing);
      await t.pump(Duration(milliseconds: i == 4 ? 301 : 451));
      expect(find.byType(MatchingFeedbackOverlay), findsNothing);
      expect(face(t, '$i-a'), true);
      if (i == 0) {
        await t.tap(card('0-a'));
        await t.pump();
        expect(find.byType(MatchingFeedbackOverlay), findsNothing);
      }
    }
    expect(find.byType(MatchingLevelCompleteDialog), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets(
      'Spotlight follows Hippo, keeps other cards opaque and follows rotation',
      (t) async {
    await start(t);
    await select(t, '0-a', '0-b');
    await t.pump(const Duration(milliseconds: 1000));
    expect(find.byType(MatchingFeedbackOverlay), findsNothing);
    expect(find.byKey(const ValueKey('golden-check')), findsNWidgets(2));
    expect(
        t
            .widget<Opacity>(find.byKey(const ValueKey('card-opacity-1-a')))
            .opacity,
        1);
    expect(
        t
            .widget<SpotlightCard>(find.byKey(const ValueKey('spotlight-0-a')))
            .strength,
        1);
    for (final size in [
      const Size(430, 932),
      const Size(932, 430),
      const Size(768, 1024),
      const Size(1024, 768)
    ]) {
      await t.binding.setSurfaceSize(size);
      await t.pump();
      for (final id in ['0-a', '0-b']) {
        final original = t.getRect(card(id));
        final overlay = t.getRect(find
            .descendant(
                of: find.byKey(ValueKey('spotlight-$id')),
                matching: find.byType(DecoratedBox))
            .first);
        expect(overlay.center.dx, closeTo(original.center.dx, .1));
        expect(overlay.center.dy, closeTo(original.center.dy, .1));
        expect(overlay.width / original.width, closeTo(1.08, .01));
      }
      expect(t.takeException(), isNull);
    }
    await t.tap(card('1-a'), warnIfMissed: false);
    await t.pump();
    expect(face(t, '1-a'), false);
    await t.pump(const Duration(milliseconds: 451));
    expect(find.byType(SpotlightCard), findsNothing);
    expect(
        t
            .widget<Opacity>(find.byKey(const ValueKey('card-opacity-1-a')))
            .opacity,
        1);
    await t.pumpWidget(const SizedBox());
    await t.binding.setSurfaceSize(null);
  });
  testWidgets(
      'Closed cards stay opaque through reaction, spotlight, release and next tap',
      (t) async {
    await start(t);
    await select(t, '0-a', '0-b');
    var elapsed = 0;
    for (final ms in [200, 700, 850, 900, 1050, 1200, 1300, 1440, 1460, 2000]) {
      await t.pump(Duration(milliseconds: ms - elapsed));
      elapsed = ms;
      for (var pair = 1; pair < 5; pair++) {
        for (final side in ['a', 'b']) {
          expect(
              t
                  .widget<Opacity>(
                      find.byKey(ValueKey('card-opacity-$pair-$side')))
                  .opacity,
              1,
              reason: 'Closed card must remain opaque at $ms ms');
          expect(face(t, '$pair-$side'), false);
        }
      }
    }
    expect(find.byType(SpotlightCard), findsNothing);
    await t.tap(card('1-a'));
    await t.pump();
    expect(face(t, '1-a'), true);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('Disposing mid reaction cancels completion', (t) async {
    await start(t);
    await select(t, '0-a', '1-a');
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 2));
    expect(t.takeException(), isNull);
  });
  testWidgets(
      'Five wrong attempts restart only after feedback; orientation can change mid reaction',
      (t) async {
    await start(t);
    String? previous;
    for (var i = 0; i < 5; i++) {
      await select(t, '0-a', '1-a');
      await t.pump(const Duration(milliseconds: 500));
      final label = t.widget<MotivationText>(find.byType(MotivationText)).text;
      expect(label, isNot(previous));
      previous = label;
      if (i == 0) {
        await t.binding.setSurfaceSize(const Size(430, 932));
        await t.pump();
        expect(find.byType(MatchingFeedbackOverlay), findsOneWidget);
      }
      await t.pump(const Duration(milliseconds: 851));
    }
    expect(find.byType(MatchingFeedbackOverlay), findsNothing);
    expect(face(t, '2-a'), true); // restarted preview exposes all cards
    await t.pumpWidget(const SizedBox());
    await t.binding.setSurfaceSize(null);
    expect(t.takeException(), isNull);
  });
  for (final size in [
    const Size(430, 932),
    const Size(932, 430),
    const Size(768, 1024),
    const Size(1024, 768)
  ]) {
    for (final correct in [true, false]) {
      testWidgets('Feedback fits $size correct=$correct', (t) async {
        await t.binding.setSurfaceSize(size);
        addTearDown(() => t.binding.setSurfaceSize(null));
        await start(t);
        await select(t, '0-a', correct ? '0-b' : '1-a');
        await t.pump(const Duration(milliseconds: 600));
        expect(t.takeException(), isNull);
        final rect = t.getRect(find.byType(MatchingFeedbackOverlay));
        final text = t.getRect(find.byType(MotivationText));
        expect(rect.contains(text.topLeft), true);
        expect(rect.contains(text.bottomRight), true);
        await t.runAsync(() async {
          final boundary = t.renderObject<RenderRepaintBoundary>(
              find.byKey(const ValueKey('capture')));
          final image = await boundary.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final dir = Directory('build/matching_feedback_preview')
            ..createSync(recursive: true);
          File('${dir.path}/${size.width.toInt()}-${correct ? 'correct' : 'wrong'}.png')
              .writeAsBytesSync(data!.buffer.asUint8List());
          image.dispose();
        });
        if (correct) {
          await t.pump(const Duration(milliseconds: 400));
          await t.runAsync(() async {
            final boundary = t.renderObject<RenderRepaintBoundary>(
                find.byKey(const ValueKey('capture')));
            final image = await boundary.toImage();
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            File('build/matching_feedback_preview/${size.width.toInt()}-spotlight.png')
                .writeAsBytesSync(data!.buffer.asUint8List());
            image.dispose();
          });
        }
        await t.pumpWidget(const SizedBox());
      });
    }
  }
}
