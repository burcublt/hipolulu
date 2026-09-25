import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'package:hippolulu/puzzle_arena.dart';
import 'package:hippolulu/puzzle_arena_layout.dart';

void main() {
  for (final size in [
    const Size(430, 839),
    const Size(814, 409),
    const Size(320, 568),
    const Size(1024, 1300)
  ]) {
    for (final count in [6, 8, 12]) {
      test('All $count piece homes remain separate at $size', () {
        final rows = count == 6 ? 3 : 4;
        final layout = PuzzleArenaLayout.fit(size, count, rows, count ~/ rows);
        expect(layout.homes.length, count);
        for (var i = 0; i < count; i++) {
          final home = layout.homes[i];
          expect(home.width, greaterThan(0));
          expect(home.left, greaterThanOrEqualTo(0));
          expect(home.top, greaterThanOrEqualTo(58));
          expect(home.right, lessThanOrEqualTo(size.width));
          expect(home.bottom, lessThanOrEqualTo(size.height));
          expect(home.overlaps(layout.board.inflate(10)), isFalse);
          for (var j = i + 1; j < count; j++) {
            expect(home.overlaps(layout.homes[j]), isFalse);
          }
        }
      });
    }
  }

  for (final size in [const Size(430, 932), const Size(932, 430)]) {
    testWidgets('Puzzle drags, progress and all pieces fit $size',
        (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RepaintBoundary(
          key: boundaryKey,
          child: MediaQuery(
            data: MediaQueryData(
                size: size,
                padding: size.width < size.height
                    ? const EdgeInsets.fromLTRB(0, 59, 0, 34)
                    : const EdgeInsets.fromLTRB(59, 0, 59, 21)),
            child: PuzzleArena(
              imagePath: 'assets/images/puzzles/animals/bear.webp',
              onBack: () {},
            ),
          ),
        ),
      ));
      await tester.runAsync(() async {
        final font = FontLoader('Baloo2 ExtraBold')
          ..addFont(rootBundle.load('assets/fonts/Baloo2-ExtraBold.ttf'));
        await font.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
        debugDisableShadows = false;
        final context = tester.element(find.byType(PuzzleArena));
        for (final asset in [
          'assets/images/puzzles/animals/bear.webp',
          'assets/images/puzzle_theme/background_theme.webp',
          'assets/images/puzzle_theme/background_theme_landscape.webp',
        ]) {
          await precacheImage(AssetImage(asset), context);
        }
      });
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 1700));
      await tester.pump();
      expect(find.byType(Draggable<String>), findsNWidgets(12));
      expect(find.text('0/12'), findsOneWidget);
      for (final element in find.byType(Draggable<String>).evaluate()) {
        final box = element.renderObject! as RenderBox;
        final origin = box.localToGlobal(Offset.zero);
        expect(origin.dx, greaterThanOrEqualTo(0));
        expect(origin.dy, greaterThanOrEqualTo(0));
        expect(origin.dx + box.size.width, lessThanOrEqualTo(size.width));
        expect(origin.dy + box.size.height, lessThanOrEqualTo(size.height));
      }
      final piece = tester
          .widget<Draggable<String>>(find.byType(Draggable<String>).first);
      final home = find.byKey(ValueKey('puzzle-piece-${piece.data}'));
      final initialCenter = tester.getCenter(home);
      // A drop outside the board returns to the same reserved home.
      await tester.drag(home, const Offset(0, -30));
      await tester.pump();
      expect(tester.getCenter(home), initialCenter);
      expect(find.text('0/12'), findsOneWidget);

      final target = tester.getRect(find.byType(DragTarget<String>));
      final coordinates = piece.data!.split('_').map(int.parse).toList();
      final destination = Offset(
        target.left +
            target.width *
                (kFrameFraction +
                    (coordinates[1] + 0.5) * (1 - 2 * kFrameFraction) / 3),
        target.top +
            target.height *
                (kFrameFraction +
                    (coordinates[0] + 0.5) * (1 - 2 * kFrameFraction) / 4),
      );
      await tester.drag(home, destination - tester.getCenter(home));
      await tester.pump();
      expect(find.text('1/12'), findsOneWidget);
      expect(find.byType(Draggable<String>), findsNWidgets(11));
      expect(tester.takeException(), isNull);

      // Render the actual production screen as a visual verification artifact.
      await tester.runAsync(() async {
        final boundary = boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final directory = Directory('build/puzzle_preview')
          ..createSync(recursive: true);
        File('${directory.path}/${size.width < size.height ? "portrait" : "landscape"}.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
      // Place the remaining pieces, including every differently sized side home.
      while (find.byType(Draggable<String>).evaluate().isNotEmpty) {
        final remaining = tester
            .widget<Draggable<String>>(find.byType(Draggable<String>).first);
        final cell = remaining.data!.split('_').map(int.parse).toList();
        final finder = find.byKey(ValueKey('puzzle-piece-${remaining.data}'));
        final end = Offset(
          target.left +
              target.width *
                  (kFrameFraction +
                      (cell[1] + 0.5) * (1 - 2 * kFrameFraction) / 3),
          target.top +
              target.height *
                  (kFrameFraction +
                      (cell[0] + 0.5) * (1 - 2 * kFrameFraction) / 4),
        );
        final before = find.byType(Draggable<String>).evaluate().length;
        await tester.drag(finder, end - tester.getCenter(finder));
        await tester.pump();
        expect(find.byType(Draggable<String>), findsNWidgets(before - 1));
      }
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pump(const Duration(milliseconds: 1100));
      final l10n =
          AppLocalizations.of(tester.element(find.byType(PuzzleArena)))!;
      expect(find.text(l10n.playAgain), findsOneWidget);
      await tester.tap(find.text(l10n.playAgain));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 1700));
      expect(find.text('0/12'), findsOneWidget);
      expect(find.byType(Draggable<String>), findsNWidgets(12));
      expect(tester.takeException(), isNull);
      debugDisableShadows = true;
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
