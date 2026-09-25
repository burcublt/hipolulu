import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'package:hippolulu/matching_card_grid.dart';
import 'package:hippolulu/matching_level_complete_dialog.dart';

void main() {
  for (final size in [
    const Size(740, 220),
    const Size(550, 170),
    const Size(360, 450),
    const Size(1100, 600),
  ]) {
    for (final count in [10, 12, 16, 20, 24, 28]) {
      testWidgets('$count cards fit in $size without scrolling',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(MaterialApp(
          home: Center(
            child: SizedBox(
              key: const ValueKey('board'),
              width: size.width,
              height: size.height,
              child: MatchingCardGrid(
                itemCount: count,
                isTablet: size.shortestSide >= 600,
                itemBuilder: (_, i) => ColoredBox(
                  key: ValueKey('card-$i'),
                  color: Colors.amber,
                ),
              ),
            ),
          ),
        ));
        final board = tester.getRect(find.byKey(const ValueKey('board')));
        for (var i = 0; i < count; i++) {
          final card = tester.getRect(find.byKey(ValueKey('card-$i')));
          expect(card.left, greaterThanOrEqualTo(board.left - 0.01));
          expect(card.right, lessThanOrEqualTo(board.right + 0.01));
          expect(card.top, greaterThanOrEqualTo(board.top - 0.01));
          expect(card.bottom, lessThanOrEqualTo(board.bottom - 12 + 0.01));
          expect(card.width, closeTo(card.height, 0.01));
        }
        final scrollable =
            tester.state<ScrollableState>(find.byType(Scrollable));
        expect(scrollable.position.maxScrollExtent, closeTo(0, 0.01));
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final size in [
    const Size(932, 430),
    const Size(667, 375),
    const Size(430, 932)
  ]) {
    for (final hasNext in [true, false]) {
      testWidgets('Dialog actions fit $size, next=$hasNext', (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        var next = 0;
        var retry = 0;
        var menu = 0;
        await tester.pumpWidget(MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              padding: size.width > size.height
                  ? const EdgeInsets.fromLTRB(59, 0, 59, 21)
                  : const EdgeInsets.fromLTRB(0, 59, 0, 34),
            ),
            child: MatchingLevelCompleteDialog(
              level: hasNext ? 1 : 6,
              characterAsset: 'assets/matching/level_complete/lion.webp',
              hasNextLevel: hasNext,
              onNextLevel: () => next++,
              onRetry: () => retry++,
              onMenu: () => menu++,
            ),
          ),
        ));
        await tester.pumpAndSettle();
        final buttons = find.byType(InkWell);
        expect(buttons, findsNWidgets(hasNext ? 3 : 2));
        for (var i = 0; i < (hasNext ? 3 : 2); i++) {
          final rect = tester.getRect(buttons.at(i));
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.bottom, lessThanOrEqualTo(size.height - 21));
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(size.width));
          await tester.tap(buttons.at(i));
        }
        expect(next, hasNext ? 1 : 0);
        expect(retry, 1);
        expect(menu, 1);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
