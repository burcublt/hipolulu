import 'dart:math' as math;
import 'package:flutter/painting.dart';

/// Shared by the board, piece homes, intro animation and drop geometry.
class PuzzleArenaLayout {
  static const boardAspect = 0.75;
  final Rect board;
  final List<Rect> homes;
  const PuzzleArenaLayout(this.board, this.homes);

  factory PuzzleArenaLayout.fit(Size size, int count, int rows, int columns) {
    const gap = 14.0;
    final landscape = size.width > size.height;
    final header = landscape ? 62.0 : 72.0;
    final area = Rect.fromLTWH(
        8, header, size.width - 16, math.max(1, size.height - header - 16));
    final boardWidth = math.min(area.width * (landscape ? 0.38 : 0.60),
        area.height * (landscape ? 0.91 : 0.66) * boardAspect);
    final board = Rect.fromCenter(
        center: area.center,
        width: boardWidth,
        height: boardWidth / boardAspect);
    final aspect = boardAspect * rows / columns;
    final homes = <Rect>[];

    void addBand(Rect band, int amount, int across, int down) {
      if (amount == 0) return;
      final cellW = band.width / across;
      final cellH = band.height / down;
      final width = math.max(1.0, math.min(cellW - 4, (cellH - 4) * aspect));
      for (var i = 0; i < amount; i++) {
        homes.add(Rect.fromCenter(
          center: Offset(band.left + (i % across + 0.5) * cellW,
              band.top + (i ~/ across + 0.5) * cellH),
          width: width,
          height: width / aspect,
        ));
      }
    }

    if (landscape) {
      // Two roomy side banks leave the full height available for the board.
      final leftCount = (count / 2).ceil();
      for (var side = 0; side < 2; side++) {
        final amount = side == 0 ? leftCount : count - leftCount;
        if (amount == 0) continue;
        final band = side == 0
            ? Rect.fromLTRB(area.left, area.top, board.left - gap, area.bottom)
            : Rect.fromLTRB(
                board.right + gap, area.top, area.right, area.bottom);
        var across = 1;
        var bestWidth = 0.0;
        for (var candidate = 1; candidate <= amount; candidate++) {
          final down = (amount / candidate).ceil();
          final width = math.min(
              band.width / candidate - 4, (band.height / down - 4) * aspect);
          if (width > bestWidth) {
            bestWidth = width;
            across = candidate;
          }
        }
        addBand(band, amount, across, (amount / across).ceil());
      }
    } else {
      final counts = List<int>.filled(4, count ~/ 4);
      for (var i = 0; i < count % 4; i++) {
        counts[i]++;
      }
      addBand(Rect.fromLTRB(area.left, area.top, area.right, board.top - gap),
          counts[0], math.max(1, counts[0]), 1);
      addBand(
          Rect.fromLTRB(board.right + gap, board.top, area.right, board.bottom),
          counts[1],
          1,
          math.max(1, counts[1]));
      addBand(
          Rect.fromLTRB(area.left, board.bottom + gap, area.right, area.bottom),
          counts[2],
          math.max(1, counts[2]),
          1);
      addBand(
          Rect.fromLTRB(area.left, board.top, board.left - gap, board.bottom),
          counts[3],
          1,
          math.max(1, counts[3]));
    }
    return PuzzleArenaLayout(board, homes);
  }
}
