import 'package:flutter/material.dart';
import 'package:hippolulu/puzzle_arena_layout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippolulu/puzzle_completion_overlay.dart';
import 'package:hippolulu/l10n/app_localizations.dart';

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(667, 375),
    const Size(820, 1180),
    const Size(1180, 820)
  ]) {
    testWidgets('Completion group fits $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final c = PuzzleCompletionController(vsync: tester)
        ..begin(reduceMotion: true);
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
            body: PuzzleCompletionOverlay(
                timeline: c,
                board:
                    PuzzleArenaLayout.fit(size, 12, 4, 3, imageAspect: 1).board,
                imagePath: 'assets/images/puzzles/animals/bear.webp',
                onReplay: () {},
                onNext: () {})),
      ));
      await tester.pump();
      final picture =
          PuzzleArenaLayout.fit(size, 12, 4, 3, imageAspect: 1).board;
      for (final button in find.byType(ElevatedButton).evaluate()) {
        final rect = tester.getRect(find.byWidget(button.widget));
        expect(rect.overlaps(picture), isFalse);
        expect(rect.bottom, lessThanOrEqualTo(size.height));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(size.width));
        expect(rect.height, greaterThanOrEqualTo(48));
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      c.dispose();
    });
  }

  testWidgets(
      'Finite timeline is idempotent, resets, and supports reduced motion',
      (tester) async {
    final c = PuzzleCompletionController(vsync: tester);
    expect(c.phase, PuzzleCompletionPhase.playing);
    c.begin(reduceMotion: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(c.phase, PuzzleCompletionPhase.celebration);
    final value = c.value;
    c.begin(reduceMotion: false);
    expect(c.value, value);
    await tester.pump(const Duration(milliseconds: 2200));
    expect(c.phase, PuzzleCompletionPhase.actionsReady);
    expect(c.isAnimating, isFalse);
    c.restartRound();
    expect(c.phase, PuzzleCompletionPhase.playing);
    expect(c.value, 0);
    c.begin(reduceMotion: true);
    expect(c.phase, PuzzleCompletionPhase.actionsReady);
    expect(c.isAnimating, isFalse);
    c.dispose();
  });

  testWidgets('Actions wait for celebration and accept only one navigation',
      (tester) async {
    final c = PuzzleCompletionController(vsync: tester);
    var next = 0;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: PuzzleCompletionOverlay(
        timeline: c,
        board: const Rect.fromLTWH(300, 70, 180, 250),
        imagePath: 'assets/images/puzzles/animals/bear.webp',
        onReplay: () {},
        onNext: () => next++,
      )),
    ));
    c.begin(reduceMotion: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.byType(ElevatedButton), findsNothing);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(ElevatedButton), findsNWidgets(2));
    await tester.tap(find.text('New Puzzle'), warnIfMissed: false);
    expect(next, 0);
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.tap(find.text('New Puzzle'));
    await tester.tap(find.text('New Puzzle'));
    expect(next, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    c.dispose();
    expect(tester.takeException(), isNull);
  });
}
