import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'package:hippolulu/l10n/game_l10n.dart';

/// Fraction of the board's width/height reserved for the static image
/// "frame" around the edges. The jigsaw pieces are cut only from the
/// remaining inner area, so the frame and the pieces never show the same
/// part of the picture twice. Change this single value to make the frame
/// thicker or thinner everywhere (board, tray pieces, and placed pieces
/// all read from it).
const double kFrameFraction = 0.03;

// Layout constants shared between the widget tree and the manual geometry
// math used to fly pieces between the board and the tray. Keeping these as
// named constants (instead of ad-hoc numbers baked into widgets) is what
// lets us compute a piece's board position and its tray position in the
// exact same coordinate space.
const double kTrayMargin = 8;
const double kTrayHeaderH = 48;
const double kTrayPad = 8;
const double kBoardMargin = 8;
const double kBoardPad = 8;

/// The board is normally sized to fill whatever space is available (width
/// or height, whichever is the tighter fit) minus the small fixed margins
/// above. That works fine on a phone, but on a tablet — where there's a
/// lot of vertical room — it meant the board could balloon up to nearly
/// the full screen height. This caps it at a fraction of the available
/// height instead, so there's always some visible breathing room around
/// it on bigger screens. Lower this (e.g. 0.72) to shrink the board
/// further; raise it (closer to 1.0) to let it grow bigger again.
const double kBoardMaxHeightFraction = 0.82;

// ─────────────────────────────────────────────
//  JIGSAW MODELS & LOGIC
// ─────────────────────────────────────────────
enum EdgeType { flat, tab, blank }

class JigsawPiece {
  final int row, col;
  final EdgeType top, right, bottom, left;
  final String id;
  JigsawPiece(this.row, this.col, this.top, this.right, this.bottom, this.left)
      : id = '${row}_$col';
}

/// Simple (row, col) pair — used instead of a Dart 3 record type so this
/// file keeps working on older SDK constraints (records need Dart 3.0+).
class _BoardCell {
  final int row, col;
  const _BoardCell(this.row, this.col);
}

/// Rows/cols pair for a given total piece count.
/// 6  -> 2x3   8  -> 2x4   12 -> 3x4   (fallback: roughly square)
class _GridSize {
  final int rows, cols;
  const _GridSize(this.rows, this.cols);
}

_GridSize _gridSizeForPieceCount(int count) {
  switch (count) {
    case 6:
      return const _GridSize(2, 3);
    case 8:
      return const _GridSize(2, 4);
    case 12:
      return const _GridSize(3, 4);
    default:
      final cols = sqrt(count).ceil();
      final rows = (count / cols).ceil();
      return _GridSize(rows, cols);
  }
}

/// Rough near-square grid dimensions for laying out `n` scattered tray
/// pieces WITHOUT overlap. Used both to pick each piece's initial resting
/// position (as a fraction of the scatter area — see initState/_handleReset)
/// and, later, to size the piece boxes against the *actual* on-screen
/// scatter area inside the LayoutBuilder. Using the same n-only formula in
/// both places keeps them in sync regardless of how many pieces there are:
/// more pieces automatically means more (smaller) grid cells instead of a
/// fixed box size that inevitably overlaps once there are more than a
/// handful of pieces.
_GridSize _scatterGridDims(int n) {
  // The tray column is usually narrower than it is tall, so assume a bit
  // of that instead of a perfectly square layout — this only affects each
  // piece's *starting* resting spot (for spreading them apart initially);
  // actual piece *size* is computed separately against the real, on-screen
  // scatter area (see the LayoutBuilder in _buildGame), so this doesn't
  // need to be pixel-perfect.
  final cols = max(2, sqrt(n * 0.6).ceil());
  final rows = (n / cols).ceil();
  return _GridSize(rows, cols);
}

/// Generates a rows x cols jigsaw grid with randomly assigned tab/blank
/// edges. Shared edges between neighboring pieces are always complementary
/// (one gets `tab`, the other gets `blank`), and outer-border edges are
/// always `flat`.
List<JigsawPiece> generateGrid(int rows, int cols) {
  final rnd = Random();
  EdgeType randomEdge() => rnd.nextBool() ? EdgeType.tab : EdgeType.blank;
  EdgeType opposite(EdgeType e) {
    switch (e) {
      case EdgeType.tab:
        return EdgeType.blank;
      case EdgeType.blank:
        return EdgeType.tab;
      case EdgeType.flat:
        return EdgeType.flat;
    }
  }

  final horizontal = List.generate(
      rows, (_) => List<EdgeType>.generate(cols - 1, (_) => randomEdge()));
  final vertical = List.generate(
      rows - 1, (_) => List<EdgeType>.generate(cols, (_) => randomEdge()));

  final pieces = <JigsawPiece>[];
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      final top = r == 0 ? EdgeType.flat : opposite(vertical[r - 1][c]);
      final left = c == 0 ? EdgeType.flat : opposite(horizontal[r][c - 1]);
      final right = c == cols - 1 ? EdgeType.flat : horizontal[r][c];
      final bottom = r == rows - 1 ? EdgeType.flat : vertical[r][c];
      pieces.add(JigsawPiece(r, c, top, right, bottom, left));
    }
  }
  return pieces;
}

class JigsawClipper extends CustomClipper<Path> {
  final JigsawPiece piece;
  final double cellW, cellH;
  final double ox, oy;
  JigsawClipper(this.piece, this.cellW, this.cellH, this.ox, this.oy);

  @override
  Path getClip(Size size) {
    // Push every corner outward by a small margin so this piece's shape
    // slightly overlaps its neighbors instead of exactly touching them.
    // Two independently-clipped shapes that only just touch can leave a
    // hairline, anti-aliased gap at the seam (letting whatever is behind
    // peek through); a small deliberate overlap guarantees there's never
    // a gap, and since the overlap shows the same picture/color on both
    // sides, it's invisible in practice.
    const double eps = 1.5;

    Path p = Path();
    Offset topLeft = Offset(ox - eps, oy - eps);
    Offset topRight = Offset(ox + cellW + eps, oy - eps);
    Offset botRight = Offset(ox + cellW + eps, oy + cellH + eps);
    Offset botLeft = Offset(ox - eps, oy + cellH + eps);

    p.moveTo(topLeft.dx, topLeft.dy);
    _drawEdge(p, topLeft, topRight, piece.top);
    _drawEdge(p, topRight, botRight, piece.right);
    _drawEdge(p, botRight, botLeft, piece.bottom);
    _drawEdge(p, botLeft, topLeft, piece.left);
    p.close();
    return p;
  }

  void _drawEdge(Path p, Offset start, Offset end, EdgeType type) {
    if (type == EdgeType.flat) {
      p.lineTo(end.dx, end.dy);
      return;
    }

    double dx = end.dx - start.dx;
    double dy = end.dy - start.dy;
    double L = sqrt(dx * dx + dy * dy);

    double ux = dx / L;
    double uy = dy / L;

    Offset transform(double x, double y) {
      return Offset(
        start.dx + ux * x - uy * y,
        start.dy + uy * x + ux * y,
      );
    }

    double yOut = L * 0.25 * (type == EdgeType.tab ? 1 : -1);

    Offset p1 = transform(L * 0.35, 0);
    Offset c1 = transform(L * 0.45, 0);
    Offset c2 = transform(L * 0.30, yOut);
    Offset p2 = transform(L * 0.50, yOut);

    Offset c3 = transform(L * 0.70, yOut);
    Offset c4 = transform(L * 0.55, 0);
    Offset p3 = transform(L * 0.65, 0);

    p.lineTo(p1.dx, p1.dy);
    p.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    p.cubicTo(c3.dx, c3.dy, c4.dx, c4.dy, p3.dx, p3.dy);
    p.lineTo(end.dx, end.dy);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Wraps an already-built Path (e.g. the result of a Path.combine union) so
/// it can be used directly with a ClipPath widget.
class _StaticPathClipper extends CustomClipper<Path> {
  final Path path;
  const _StaticPathClipper(this.path);

  @override
  Path getClip(Size size) => path;

  @override
  bool shouldReclip(covariant _StaticPathClipper oldClipper) =>
      oldClipper.path != path;
}

// ─────────────────────────────────────────────
//  PUZZLE ARENA WIDGET
// ─────────────────────────────────────────────
class PuzzleArena extends StatefulWidget {
  final String imagePath;
  final VoidCallback onBack;

  /// Called when the player taps "Diğer Oyuna Geç" on the win screen.
  /// Optional for now — if you don't pass one, the button simply does
  /// nothing (no crash). Wire it up later to your "go to next game" flow.
  final VoidCallback? onNextGame;

  /// How many pieces the puzzle should have (6 / 8 / 12 map to a matching
  /// grid via _gridSizeForPieceCount; any other count falls back to a
  /// roughly-square grid).
  final int pieceCount;

  const PuzzleArena({
    super.key,
    required this.imagePath,
    required this.onBack,
    this.onNextGame,
    this.pieceCount = 12,
  });

  @override
  State<PuzzleArena> createState() => _PuzzleArenaState();
}

class _PuzzleArenaState extends State<PuzzleArena>
    with TickerProviderStateMixin {
  late final int rows;
  late final int cols;
  late final List<JigsawPiece> pieces;
  final Set<String> placed = {};
  bool wrongFlash = false;
  bool showWin = false;

  late String imageAsset;

  // Win animation controllers
  late AnimationController _winCtrl;
  late AnimationController _celebCtrl;
  final List<AnimationController> _starCtrls = [];

  // ── Intro: "show the solved picture, then scatter the pieces" ──
  late AnimationController introCtrl;
  bool introDone = false;
  late List<Offset>
      scatterFrac; // 0..1 resting position within the tray's scatter area, per piece index
  late List<double> scatterRot; // resting tilt (radians), per piece index
  final GlobalKey _stackKey =
      GlobalKey(); // outer Stack — used to convert drop offsets to local coords

  @override
  void initState() {
    super.initState();
    imageAsset = widget.imagePath;

    final grid = _gridSizeForPieceCount(widget.pieceCount);
    rows = grid.rows;
    cols = grid.cols;
    pieces = generateGrid(rows, cols)..shuffle();

    final rnd = Random();
    scatterFrac = _scatterFrac(pieces.length, rnd);
    scatterRot = List.generate(
        pieces.length, (_) => (rnd.nextDouble() - 0.5) * 0.5); // ~ -14° .. +14°

    _winCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _celebCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    for (int i = 0; i < 3; i++) {
      _starCtrls.add(AnimationController(
          vsync: this, duration: const Duration(milliseconds: 400)));
    }

    introCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
    introCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => introDone = true);
      }
    });
    _playIntro();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).catchError((_) {});
  }

  /// Holds the fully-solved picture on screen for a beat, then lets the
  /// pieces fly out to the tray.
  void _playIntro() {
    introCtrl.value = 0;
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) introCtrl.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _winCtrl.dispose();
    _celebCtrl.dispose();
    for (final c in _starCtrls) {
      c.dispose();
    }
    introCtrl.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values)
        .catchError((_) {});
    super.dispose();
  }

  /// Per-piece flight progress (0..1), staggered so pieces peel off one
  /// after another instead of all moving at once. Piece order already
  /// comes shuffled (see `pieces` in initState), so index order alone
  /// gives a natural-looking, non-sequential cascade.
  double _localProgress(int i) {
    final n = pieces.length;
    final start = (i / n) * 0.65;
    final end = (start + 0.4).clamp(0.0, 1.0);
    final t = ((introCtrl.value - start) / (end - start)).clamp(0.0, 1.0);
    return Curves.easeInOut.transform(t);
  }

  /// Converts a drag's global drop position into a (row, col) board cell,
  /// clamped to the grid. `dragCenterOffset` corrects for the fact that
  /// Flutter's DragTargetDetails.offset is the *top-left* of the dragged
  /// feedback widget, not the finger/pointer position — passing half the
  /// feedback's size here recovers the (much more intuitive) center point,
  /// so the cell a piece lands on matches where it visually looks dropped.
  _BoardCell? _cellAt(
    Offset globalOffset,
    Rect boardRect,
    double frameW,
    double frameH,
    double cellW,
    double cellH,
    int rows,
    int cols, {
    Offset dragCenterOffset = Offset.zero,
  }) {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return null;
    final local = stackBox.globalToLocal(globalOffset + dragCenterOffset);
    final col = (((local.dx - boardRect.left - frameW) / cellW).floor())
        .clamp(0, cols - 1);
    final row = (((local.dy - boardRect.top - frameH) / cellH).floor())
        .clamp(0, rows - 1);
    return _BoardCell(row, col);
  }

  /// Starting resting positions for the tray pile: one per grid cell (see
  /// `_scatterGridDims`) plus a small random nudge, instead of a fully
  /// random `Offset` per piece. Fully random positions are what caused
  /// pieces to pile up on top of each other and become unreadable/hard to
  /// grab once there were more than 3-4 of them — placing each piece in
  /// its own cell first guarantees they start out spread apart, and the
  /// small nudge (plus each piece's own random tilt) keeps the "tossed
  /// into a pile" look instead of a perfectly robotic grid.
  List<Offset> _scatterFrac(int n, Random rnd) {
    final grid = _scatterGridDims(n);
    return List.generate(n, (i) {
      final col = i % grid.cols;
      final row = i ~/ grid.cols;
      final jitterX = (rnd.nextDouble() - 0.5) * (0.12 / grid.cols);
      final jitterY = (rnd.nextDouble() - 0.5) * (0.12 / grid.rows);
      return Offset(
        (col / grid.cols + jitterX).clamp(0.0, 1.0),
        (row / grid.rows + jitterY).clamp(0.0, 1.0),
      );
    });
  }

  void _handleDrop(String pieceId, String slotId) {
    if (pieceId == slotId) {
      setState(() => placed.add(pieceId));
      if (placed.length == pieces.length) {
        Future.delayed(const Duration(milliseconds: 450), () {
          if (mounted) {
            setState(() => showWin = true);
            _winCtrl.forward();
            for (int i = 0; i < _starCtrls.length; i++) {
              Future.delayed(Duration(milliseconds: 400 + i * 180), () {
                if (mounted) _starCtrls[i].forward();
              });
            }
          }
        });
      }
    } else {
      setState(() => wrongFlash = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => wrongFlash = false);
      });
    }
  }

  void _handleReset() {
    setState(() {
      placed.clear();
      showWin = false;
      pieces.shuffle();
      introDone = false;
      final rnd = Random();
      scatterFrac = _scatterFrac(pieces.length, rnd);
      scatterRot =
          List.generate(pieces.length, (_) => (rnd.nextDouble() - 0.5) * 0.5);
    });
    _winCtrl.reset();
    for (final c in _starCtrls) {
      c.reset();
    }
    _playIntro();
  }

  String get _puzzleName {
    return AppLocalizations.of(context)!.itemTitle(imageAsset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return const _RotateDevicePrompt();
          }
          return _buildGame(context);
        },
      ),
    );
  }

  Widget _buildGame(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF72D8F5),
            Color(0xFFB0EAFC),
            Color(0xFFCAF5E2),
            Color(0xFFB0E8A8)
          ],
        ),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalW = constraints.maxWidth;
                final totalH = constraints.maxHeight;
                final trayW = totalW / 3;
                final boardAreaW = totalW - trayW;

                // ── Tray geometry (absolute coords, same space as the board) ──
                final trayOuter =
                    Rect.fromLTWH(0, 0, trayW, totalH).deflate(kTrayMargin);
                final scatterArea = Rect.fromLTWH(
                  trayOuter.left + kTrayPad,
                  trayOuter.top + kTrayHeaderH + kTrayPad,
                  trayOuter.width - kTrayPad * 2,
                  trayOuter.height - kTrayHeaderH - kTrayPad * 2,
                );
                // Where each piece starts resting (roughly one per grid
                // cell — see _scatterGridDims) was already picked back in
                // initState/_handleReset. The actual on-screen *size* of
                // each piece is computed fresh below, against the real
                // scatter area, so it stays correctly sized regardless of
                // device.
                // Size each tray piece to fit its own grid cell (with a
                // little breathing room) instead of a fixed 55% of the
                // whole scatter area regardless of how many pieces there
                // are — that fixed size is what made pieces pile up on
                // top of each other once there were more than a handful.
                //
                // Rather than guessing a device-size threshold (phone vs.
                // tablet), pick the cols/rows split that best matches the
                // *actual* scatter area's real aspect ratio, so pieces are
                // always as big as they can possibly be without
                // overlapping too much — this alone makes pieces bigger on
                // a tablet (more real estate → bigger cells) without any
                // magic size-boost constants to tune per device class.
                final n = pieces.length;
                final arenaAspect = scatterArea.width / scatterArea.height;
                int sizingCols = sqrt(n * arenaAspect).round().clamp(1, n);
                int sizingRows = (n / sizingCols).ceil();
                final trayCellW = scatterArea.width / sizingCols;
                final trayCellH = scatterArea.height / sizingRows;
                // Pieces are irregular jigsaw shapes with a lot of
                // transparent margin around the actual art, so letting the
                // box run a bit larger than its cell (1.15x) still reads
                // as "nicely sized pieces in a pile", not clutter.
                final pieceBoxW = min(trayCellW, trayCellH) * 1.15;
                final pieceBoxH = pieceBoxW;

                // ── Board geometry (absolute coords) ──
                final boardOuter = Rect.fromLTWH(trayW, 0, boardAreaW, totalH)
                    .deflate(kBoardMargin);
                final boardPadded = boardOuter.deflate(kBoardPad);
                final squareSize = min(
                  min(boardPadded.width, boardPadded.height),
                  totalH * kBoardMaxHeightFraction,
                );
                final boardRect = Rect.fromCenter(
                    center: boardPadded.center,
                    width: squareSize,
                    height: squareSize);

                final boardW = boardRect.width;
                final boardH = boardRect.height;
                final frameW = boardW * kFrameFraction;
                final frameH = boardH * kFrameFraction;
                final innerW = boardW - frameW * 2;
                final innerH = boardH - frameH * 2;
                final cellW = innerW / cols;
                final cellH = innerH / rows;
                final overflowW = cellW * 0.3;
                final overflowH = cellH * 0.3;

                Rect pieceBoardRect(JigsawPiece p) => Rect.fromLTWH(
                      boardRect.left + frameW + p.col * cellW - overflowW,
                      boardRect.top + frameH + p.row * cellH - overflowH,
                      cellW + overflowW * 2,
                      cellH + overflowH * 2,
                    );

                Rect pieceTrayRect(int i) => Rect.fromLTWH(
                      scatterArea.left +
                          scatterFrac[i].dx * (scatterArea.width - pieceBoxW),
                      scatterArea.top +
                          scatterFrac[i].dy * (scatterArea.height - pieceBoxH),
                      pieceBoxW,
                      pieceBoxH,
                    );

                return AnimatedBuilder(
                  animation: introCtrl,
                  builder: (context, _) {
                    return Stack(
                      key: _stackKey,
                      clipBehavior: Clip.none,
                      children: [
                        // ── static chrome ── no boxed panels: back button and
                        // counter float directly on the background, and the
                        // board/tray areas use the full space instead of being
                        // constrained inside a separate white container.
                        Positioned(
                          left: trayOuter.left + 4,
                          top: trayOuter.top + 4,
                          width: trayOuter.width - 8,
                          height: kTrayHeaderH - 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _BackButton(onTap: widget.onBack),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                    '${placed.length} / ${pieces.length}',
                                    style: const TextStyle(
                                        fontFamily: 'Baloo2 ExtraBold',
                                        fontSize: 16,
                                        color: Color(0xFF7854B8),
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),

                        // board frame image — always fully visible, pixel-perfect.
                        // Unsolved cells get covered individually below (per-piece,
                        // exact jigsaw shape) instead of one big rectangle, so there's
                        // no seam where a placed piece's edge meets a flat placeholder.
                        Positioned.fromRect(
                          rect: boardRect,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(imageAsset, fit: BoxFit.fill),
                          ),
                        ),
                        if (wrongFlash)
                          Positioned.fromRect(
                            rect: boardRect,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFF5050)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          ),

                        // ── unified cover for all not-yet-solved pieces ──
                        // Instead of drawing each unsolved cell's cover as its own
                        // independent ClipPath (which can leave a hairline gap where
                        // two adjacent curves don't rasterize in perfect agreement,
                        // letting the picture underneath peek through), we union all
                        // of their shapes into ONE path first. Any edge shared between
                        // two unsolved neighbors becomes an interior edge of that union
                        // and is never drawn at all — so there is nothing left that can
                        // show a seam between them.
                        Builder(builder: (context) {
                          Path? combinedCover;
                          for (int i = 0; i < pieces.length; i++) {
                            final p = pieces[i];
                            final isPlacedNow = introDone
                                ? placed.contains(p.id)
                                : _localProgress(i) <= 0.0;
                            if (isPlacedNow) continue;
                            final piecePath = JigsawClipper(
                                    p,
                                    cellW,
                                    cellH,
                                    frameW + p.col * cellW,
                                    frameH + p.row * cellH)
                                .getClip(Size(boardW, boardH));
                            combinedCover = combinedCover == null
                                ? piecePath
                                : Path.combine(PathOperation.union,
                                    combinedCover, piecePath);
                          }
                          if (combinedCover == null)
                            return const SizedBox.shrink();
                          return Positioned.fromRect(
                            rect: boardRect,
                            child: ClipPath(
                              clipper: _StaticPathClipper(combinedCover),
                              child: Container(color: const Color(0xFFE3A868)),
                            ),
                          );
                        }),

                        // ── board drop target ──
                        // ONE DragTarget covering the whole board, instead
                        // of a separate small target per piece. We figure
                        // out which cell a drop belongs to from *where* it
                        // lands (nearest cell, clamped to the grid), which
                        // is far more forgiving than requiring the piece to
                        // land inside its own small, oftentimes-overlapping
                        // target rect — that overlap was exactly what made
                        // it so easy to "miss" on a phone, where fingers
                        // are big relative to the cells.
                        Positioned.fromRect(
                          rect: boardOuter,
                          child: DragTarget<String>(
                            onAcceptWithDetails: (details) {
                              final cell = _cellAt(
                                details.offset,
                                boardRect,
                                frameW,
                                frameH,
                                cellW,
                                cellH,
                                rows,
                                cols,
                                dragCenterOffset:
                                    Offset(pieceBoxW * 0.5, pieceBoxH * 0.5),
                              );
                              if (cell == null) return;
                              final target = pieces.firstWhere((p) =>
                                  p.row == cell.row && p.col == cell.col);
                              _handleDrop(details.data, target.id);
                            },
                            builder: (context, candidates, rejected) {
                              // No hover highlight — keeps the board clean
                              // while dragging.
                              return const SizedBox.shrink();
                            },
                          ),
                        ),

                        // ── flying / resting tray pieces ──
                        for (int i = 0; i < pieces.length; i++)
                          if (!(introDone && placed.contains(pieces[i].id)) &&
                              (introDone || _localProgress(i) > 0.0))
                            Builder(builder: (context) {
                              final local = introDone ? 1.0 : _localProgress(i);
                              final rect = Rect.lerp(pieceBoardRect(pieces[i]),
                                  pieceTrayRect(i), local)!;
                              final angle = scatterRot[i] * local;
                              return Positioned.fromRect(
                                rect: rect,
                                child: Transform.rotate(
                                  angle: angle,
                                  child: IgnorePointer(
                                    ignoring: !introDone,
                                    child: _TrayPiece(
                                      piece: pieces[i],
                                      imageAsset: imageAsset,
                                      rows: rows,
                                      cols: cols,
                                      onDragEnd: (details) {
                                        // Move this piece's resting spot to
                                        // wherever it was dropped, clamped
                                        // to stay inside the tray. We used
                                        // to bail out entirely (leaving the
                                        // piece at its old spot) whenever
                                        // the drop point measured as just
                                        // outside the scatter area — but
                                        // that early-exit is exactly what
                                        // made drops feel like they
                                        // "silently failed" and snapped
                                        // back, even for drops that looked
                                        // perfectly fine inside the tray.
                                        // Always clamping instead means a
                                        // drop is *never* silently ignored:
                                        // worst case it lands at the
                                        // nearest valid tray edge instead
                                        // of exactly where you aimed.
                                        //
                                        // `details.offset` is also the
                                        // *top-left* of the dragged piece,
                                        // not where you visually dropped
                                        // it — adding half the piece size
                                        // recovers its center.
                                        final stackBox = _stackKey
                                            .currentContext
                                            ?.findRenderObject() as RenderBox?;
                                        if (stackBox == null) return;
                                        final localPoint = stackBox
                                            .globalToLocal(details.offset +
                                                Offset(pieceBoxW / 2,
                                                    pieceBoxH / 2));
                                        final fx = ((localPoint.dx -
                                                    scatterArea.left) /
                                                (scatterArea.width - pieceBoxW))
                                            .clamp(0.0, 1.0);
                                        final fy =
                                            ((localPoint.dy - scatterArea.top) /
                                                    (scatterArea.height -
                                                        pieceBoxH))
                                                .clamp(0.0, 1.0);
                                        setState(() =>
                                            scatterFrac[i] = Offset(fx, fy));
                                      },
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          if (showWin)
            _WinOverlay(
              animalName: _puzzleName,
              winCtrl: _winCtrl,
              celebCtrl: _celebCtrl,
              starCtrls: _starCtrls,
              onReset: _handleReset,
              onBack: widget.onBack,
              onNextGame: widget.onNextGame ?? () {},
              placedCount: placed.length,
              totalCount: pieces.length,
            ),
        ],
      ),
    );
  }
}

/// Plain rounded translucent background panel, reused for both the tray
/// and the board's outer chrome.
// ─────────────────────────────────────────────
//  ROTATE-DEVICE PROMPT (shown while in portrait)
// ─────────────────────────────────────────────
class _RotateDevicePrompt extends StatefulWidget {
  const _RotateDevicePrompt();

  @override
  State<_RotateDevicePrompt> createState() => _RotateDevicePromptState();
}

class _RotateDevicePromptState extends State<_RotateDevicePrompt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF72D8F5),
            Color(0xFFB0EAFC),
            Color(0xFFCAF5E2),
            Color(0xFFB0E8A8)
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) {
                final angle = (-90 * (1 - _ctrl.value)) * pi / 180;
                return Transform.rotate(angle: angle, child: child);
              },
              child: const Icon(Icons.stay_current_portrait_rounded,
                  size: 90, color: Color(0xFF5C28A0)),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.rotateDevicePrompt,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Baloo2 ExtraBold',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C28A0)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TRAY PIECE (Draggable) — used both at rest in the tray and, wrapped in
//  an IgnorePointer + Transform by the parent, as the flying piece during
//  the intro animation.
// ─────────────────────────────────────────────
class _TrayPiece extends StatelessWidget {
  final JigsawPiece piece;
  final String imageAsset;
  final int rows, cols;
  final void Function(DraggableDetails)? onDragEnd;
  const _TrayPiece(
      {required this.piece,
      required this.imageAsset,
      required this.rows,
      required this.cols,
      this.onDragEnd});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double widgetW = constraints.maxWidth;
        double widgetH = constraints.maxHeight;

        double cellW = widgetW / 1.6;
        double cellH = widgetH / 1.6;
        double overflowW = cellW * 0.3;
        double overflowH = cellH * 0.3;

        // The grid only covers the inner (1 - 2*kFrameFraction) portion of the
        // full image — render the FULL image at a proportionally larger
        // virtual size, then shift it by the frame offset, exactly mirroring
        // what the board does, so tray and board always crop identically.
        double boardW = cellW * cols / (1 - 2 * kFrameFraction);
        double boardH = cellH * rows / (1 - 2 * kFrameFraction);
        double frameW = boardW * kFrameFraction;
        double frameH = boardH * kFrameFraction;

        Widget content = Center(
          child: SizedBox(
            width: cellW + overflowW * 2,
            height: cellH + overflowH * 2,
            child: ClipPath(
              clipper: JigsawClipper(piece, cellW, cellH, overflowW, overflowH),
              child: Stack(
                children: [
                  Positioned(
                    left: -(frameW + piece.col * cellW) + overflowW,
                    top: -(frameH + piece.row * cellH) + overflowH,
                    width: boardW,
                    height: boardH,
                    child: Image.asset(imageAsset, fit: BoxFit.fill),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1.5),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );

        return Draggable<String>(
          data: piece.id,
          feedback: Material(
            color: Colors.transparent,
            child: Transform.scale(
                scale: 1.2,
                child: Opacity(
                    opacity: 0.9,
                    child: SizedBox(
                        width: widgetW, height: widgetH, child: content))),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: content),
          onDragEnd: onDragEnd,
          child: content,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  BACK BUTTON
// ─────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Icon(Icons.chevron_left_rounded,
            size: 28, color: Color(0xFF5C28A0)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIN OVERLAY
// ─────────────────────────────────────────────
//
// Asset checklist — add these files and register them under `assets:` in
// pubspec.yaml before running:
//   assets/images/win/win_flame.webp    (yellow frame + balloons + stars + confetti, all baked in)
//   assets/images/win/roket_hippo.webp  (mascot)
class _WinOverlay extends StatelessWidget {
  final String animalName;
  final AnimationController winCtrl, celebCtrl;
  final List<AnimationController> starCtrls;
  final VoidCallback onReset;
  final VoidCallback onBack;
  final VoidCallback onNextGame;
  final int placedCount;
  final int totalCount;

  const _WinOverlay({
    required this.animalName,
    required this.winCtrl,
    required this.celebCtrl,
    required this.starCtrls,
    required this.onReset,
    required this.onBack,
    required this.onNextGame,
    required this.placedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: winCtrl, curve: Curves.easeIn),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          // ── 1. Dimmed / blurred glimpse of the fairground scene behind ──
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withValues(alpha: 0.18)),
            ),
          ),

          // ── 2. The win card (frame image + ribbon + mascot + buttons) ──
          Center(
            child: ScaleTransition(
              scale: CurvedAnimation(parent: winCtrl, curve: Curves.elasticOut),
              child: _WinCard(
                animalName: animalName,
                celebCtrl: celebCtrl,
                onReset: onReset,
                onNextGame: onNextGame,
              ),
            ),
          ),

          // ── 3. Top bar (Geri + X / Y) — stays on top of everything ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BackButton(onTap: onBack),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$placedCount / $totalCount',
                      style: const TextStyle(
                          fontFamily: 'Baloo2 ExtraBold',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF5C28A0)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIN CARD
//  A single pre-made frame image (win_flame.webp — yellow scalloped
//  border, stars, balloons, confetti all baked in) with the ribbon,
//  mascot and buttons layered on top of its blank inner area.
//
//  Everything below is laid out on a fixed-size "design canvas"
//  (_designWidth × _designHeight) and then the *whole* canvas is scaled
//  uniformly to fit the device via FittedBox. That keeps every proportion
//  (button size, mascot size, ribbon size...) identical on a phone and on
//  a tablet — it just gets bigger or smaller as one piece, so buttons
//  never spill past the frame and the card never looks tiny on iPad.
// ─────────────────────────────────────────────
class _WinCard extends StatelessWidget {
  final String animalName;
  final AnimationController celebCtrl;
  final VoidCallback onReset;
  final VoidCallback onNextGame;

  // Matches the win_flame.webp source dimensions (1536×1024).
  static const double _frameAspectRatio = 1536 / 1024;
  static const double _designWidth = 480;
  static const double _designHeight =
      _designWidth / _frameAspectRatio; // ~320px

  const _WinCard({
    required this.animalName,
    required this.celebCtrl,
    required this.onReset,
    required this.onNextGame,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.hasBoundedWidth ? constraints.maxWidth : 800.0;
        final maxH =
            constraints.hasBoundedHeight ? constraints.maxHeight : 800.0;
        final shortSide = maxW < maxH ? maxW : maxH;

        // Base size: scales up on tablets
        double cardWidth = (shortSide * 0.92).clamp(340.0, 820.0);

        final maxCardHeight = maxH * 0.82;
        if (cardWidth / _frameAspectRatio > maxCardHeight) {
          cardWidth = maxCardHeight * _frameAspectRatio;
        }

        return SizedBox(
          width: cardWidth,
          height: cardWidth / _frameAspectRatio,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _designWidth,
              height: _designHeight,
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  // 1. Frame background (yellow scalloped border + balloons + stars)
                  Image.asset(
                    'assets/images/win_flame.webp',
                    width: _designWidth,
                    height: _designHeight,
                    fit: BoxFit.fill,
                  ),

                  // 2. Hippo Mascot — static (no movement animation), sitting lower
                  // so its lower body tucks behind the buttons row.
                  Positioned(
                    top: 92,
                    child: Image.asset(
                      'assets/images/hippo.webp',
                      height: 155,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // 3. Ribbon banner ("Harika!"), sitting clearly above Hippo's head
                  Positioned(
                    top: 36,
                    child: SizedBox(
                      width: 210,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/ribbon.webp',
                            fit: BoxFit.contain,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              AppLocalizations.of(context)!.awesome,
                              style: const TextStyle(
                                  fontFamily: 'Baloo2 ExtraBold',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Buttons, right at the frame's bottom edge, painted over Hippo's legs
                  Positioned(
                    bottom: -8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _WinButton(
                          label: AppLocalizations.of(context)!.playAgain,
                          icon: Icons.refresh_rounded,
                          colors: const [Color(0xFF8CDB4E), Color(0xFF5CB82E)],
                          onTap: onReset,
                        ),
                        const SizedBox(width: 10),
                        _WinButton(
                          label: 'Diğer Oyuna Geç',
                          icon: Icons.arrow_forward_rounded,
                          colors: const [Color(0xFF5AB8FF), Color(0xFF2E8CE0)],
                          onTap: onNextGame,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  WIN SCREEN PILL BUTTON (Tekrar Oyna / Diğer Oyuna Geç)
// ─────────────────────────────────────────────
class _WinButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _WinButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.5),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Two overlapping icons (a soft dark "shadow" copy behind the
            // white one) give the glyph extra visual weight — reads as a
            // bolder icon without needing a custom icon asset.
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon,
                    color: Colors.black.withValues(alpha: 0.18), size: 16),
                Icon(icon, color: Colors.white, size: 15),
              ],
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                  fontFamily: 'Baloo2 ExtraBold',
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
