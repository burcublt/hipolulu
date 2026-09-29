import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'puzzle_arena_layout.dart';
import 'puzzle_placement_effect.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'package:hippolulu/l10n/game_l10n.dart';

/// Fraction of the board's width/height reserved for the static image
/// "frame" around the edges. The jigsaw pieces are cut only from the
/// remaining inner area, so the frame and the pieces never show the same
/// part of the picture twice. Change this single value to make the frame
/// thicker or thinner everywhere (board, tray pieces, and placed pieces
/// all read from it).
const double kFrameFraction = 0.03;

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
/// 6  -> 3x2   8  -> 4x2   12 -> 4x3   (fallback: roughly square)
class _GridSize {
  final int rows, cols;
  const _GridSize(this.rows, this.cols);
}

_GridSize _gridSizeForPieceCount(int count) {
  switch (count) {
    case 6:
      return const _GridSize(3, 2);
    case 8:
      return const _GridSize(4, 2);
    case 12:
      return const _GridSize(4, 3);
    default:
      final cols = sqrt(count).ceil();
      final rows = (count / cols).ceil();
      return _GridSize(rows, cols);
  }
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
  final double edgeInflation;
  JigsawClipper(this.piece, this.cellW, this.cellH, this.ox, this.oy,
      {this.edgeInflation = 1.5});

  @override
  Path getClip(Size size) {
    // Push every corner outward by a small margin so this piece's shape
    // slightly overlaps its neighbors instead of exactly touching them.
    // Two independently-clipped shapes that only just touch can leave a
    // hairline, anti-aliased gap at the seam (letting whatever is behind
    // peek through); a small deliberate overlap guarantees there's never
    // a gap, and since the overlap shows the same picture/color on both
    // sides, it's invisible in practice.
    final eps = edgeInflation;

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

  /// Called when the player taps "Diğer Oyuna Geç" on the win screen. If
  /// you pass this explicitly it always wins. If you don't, but you *do*
  /// pass [themeImages] + [currentIndex], PuzzleArena builds a sensible
  /// default itself: replace this screen with a fresh PuzzleArena for the
  /// next image in the same theme (wrapping back to the first after the
  /// last one). If neither is supplied, the button simply does nothing.
  final VoidCallback? onNextGame;

  /// All image paths for the current theme, in the same order shown on
  /// PuzzleItemSelection — together with [currentIndex], this is what
  /// lets "Diğer Oyuna Geç" figure out which puzzle comes next.
  final List<String>? themeImages;

  /// This puzzle's position within [themeImages].
  final int? currentIndex;

  /// How many pieces the puzzle should have (6 / 8 / 12 map to a matching
  /// grid via _gridSizeForPieceCount; any other count falls back to a
  /// roughly-square grid).
  final int pieceCount;

  const PuzzleArena({
    super.key,
    required this.imagePath,
    required this.onBack,
    this.onNextGame,
    this.themeImages,
    this.currentIndex,
    this.pieceCount = 12,
  });

  @override
  State<PuzzleArena> createState() => _PuzzleArenaState();
}

class _PuzzleArenaState extends State<PuzzleArena>
    with TickerProviderStateMixin {
  // pushReplacement briefly keeps both puzzle routes mounted.
  static int _activeArenas = 0;
  bool _introStarted = false;
  late final int rows;
  late final int cols;
  late final List<JigsawPiece> pieces;
  final Set<String> placed = {};
  final Map<String, Offset> _settling = {};
  final Map<String, double> _settlingScales = {};
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
  final GlobalKey _stackKey =
      GlobalKey(); // outer Stack — used to convert drop offsets to local coords

  /// The callback actually wired to "Diğer Oyuna Geç": whatever the
  /// caller passed explicitly, or — if they instead gave us the theme's
  /// image list + our position in it — a default that replaces this
  /// screen with a fresh PuzzleArena for the next image (wrapping back to
  /// the first one after the last). Null (button does nothing) only if
  /// neither was supplied.
  VoidCallback? get _resolvedOnNextGame {
    if (widget.onNextGame != null) return widget.onNextGame;
    final images = widget.themeImages;
    final index = widget.currentIndex;
    if (images == null || images.isEmpty || index == null) return null;
    return () {
      final nextIndex = (index + 1) % images.length;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          // IMPORTANT: build a fresh onBack tied to *this* builder's own
          // context (nextCtx), not widget.onBack. pushReplacement disposes
          // the screen we're on right now, so anything the next screen's
          // "Geri" button captured from *our* context would be pointing
          // at an already-deactivated widget the moment it's pressed —
          // exactly the "deactivated widget's ancestor" crash. Popping
          // nextCtx instead lands in the same place (whatever was below
          // us in the stack, e.g. PuzzleItemSelection) but stays safe no
          // matter how many times we've chained through "Diğer Oyuna Geç".
          builder: (nextCtx) => PuzzleArena(
            imagePath: images[nextIndex],
            onBack: () => Navigator.of(nextCtx).pop(),
            pieceCount: widget.pieceCount,
            themeImages: images,
            currentIndex: nextIndex,
          ),
        ),
      );
    };
  }

  @override
  void initState() {
    super.initState();
    _activeArenas++;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    imageAsset = widget.imagePath;

    final grid = _gridSizeForPieceCount(widget.pieceCount);
    rows = grid.rows;
    cols = grid.cols;
    pieces = generateGrid(rows, cols)..shuffle();

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
    _activeArenas--;
    if (_activeArenas == 0) {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
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

  void _handleDrop(String pieceId, String slotId,
      {Offset startOffset = Offset.zero, double startScale = 1}) {
    if (pieceId == slotId) {
      if (placed.contains(pieceId)) return;
      setState(() {
        placed.add(pieceId);
        _settling[pieceId] = startOffset;
        _settlingScales[pieceId] = startScale;
      });
    } else {
      setState(() => wrongFlash = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => wrongFlash = false);
      });
    }
  }

  void _finishPlacement(String id) {
    if (!mounted || !_settling.containsKey(id)) return;
    setState(() {
      _settling.remove(id);
      _settlingScales.remove(id);
      if (placed.length == pieces.length && _settling.isEmpty) showWin = true;
    });
    if (showWin) {
      _winCtrl.forward();
      for (int i = 0; i < _starCtrls.length; i++) {
        Future.delayed(Duration(milliseconds: 400 + i * 180), () {
          if (mounted && showWin) _starCtrls[i].forward();
        });
      }
    }
  }

  void _handleReset() {
    setState(() {
      placed.clear();
      _settling.clear();
      _settlingScales.clear();
      showWin = false;
      pieces.shuffle();
      introDone = false;
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
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth <= constraints.maxHeight) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: _BackButton(onTap: widget.onBack)),
                  Expanded(
                      child: Center(
                          child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.screen_rotation_rounded,
                          size: 64, color: Color(0xFF6127C9)),
                      const SizedBox(height: 20),
                      Text(AppLocalizations.of(context)!.rotateDevicePrompt,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22,
                              color: Color(0xFF6127C9),
                              fontWeight: FontWeight.bold)),
                    ],
                  ))),
                ],
              ),
            ),
          );
        }
        if (!_introStarted) {
          _introStarted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _playIntro();
          });
        }
        return _buildGame(context);
      }),
    );
  }

  Widget _buildGame(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF1C9),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              MediaQuery.of(context).size.width >
                      MediaQuery.of(context).size.height
                  ? 'assets/images/puzzle_theme/background_theme_landscape.webp'
                  : 'assets/images/puzzle_theme/background_theme.webp',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFF3D3).withValues(alpha: 0.12),
                    const Color(0xFFFFF3D3).withValues(alpha: 0.98),
                    const Color(0xFFFFF0C6).withValues(alpha: 0.98),
                    const Color(0xFFFFF0C6).withValues(alpha: 0.18),
                  ],
                  stops: const [0, 0.17, 0.86, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalW = constraints.maxWidth;
                final totalH = constraints.maxHeight;
                final layout = PuzzleArenaLayout.fit(
                  Size(totalW, totalH),
                  pieces.length,
                  rows,
                  cols,
                );
                final boardRect = layout.board;

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

                Rect pieceTrayRect(int i) => layout.homes[i];

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
                          left: 16,
                          top: 6,
                          width: totalW - 32,
                          height: 52,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _BackButton(onTap: widget.onBack),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E9),
                                  border: Border.all(
                                      color: const Color(0xFFFFCE78), width: 2),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color(0x447B481A),
                                        offset: Offset(0, 3),
                                        blurRadius: 3)
                                  ],
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.extension_rounded,
                                        color: Color(0xFF6282D9), size: 28),
                                    const SizedBox(width: 10),
                                    Text('${placed.length}/${pieces.length}',
                                        key: const ValueKey('puzzle-progress'),
                                        style: const TextStyle(
                                            fontFamily: 'Baloo2 ExtraBold',
                                            fontSize: 22,
                                            color: Color(0xFF72432C),
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Positioned.fromRect(
                          rect: boardRect.inflate(10),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFFDF83), Color(0xFFFFBB4D)],
                              ),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  color: const Color(0xFFFFF8D5), width: 3),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0xFFC58534),
                                    offset: Offset(0, 4)),
                                BoxShadow(
                                    color: Color(0x33714219),
                                    offset: Offset(0, 7),
                                    blurRadius: 10),
                              ],
                            ),
                          ),
                        ),
                        // The opaque cream cover below reveals only pieces that
                        // have not yet flown out or have been correctly placed.
                        Positioned.fromRect(
                          rect: boardRect,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(imageAsset, fit: BoxFit.cover),
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
                          // Cover the picture's outer strip too, so no image
                          // remains visible around the empty board's edges.
                          var combinedCover = Path.combine(
                            PathOperation.difference,
                            Path()
                              ..addRect(Rect.fromLTWH(0, 0, boardW, boardH)),
                            Path()
                              ..addRect(Rect.fromLTWH(
                                frameW,
                                frameH,
                                innerW,
                                innerH,
                              )),
                          );
                          for (int i = 0; i < pieces.length; i++) {
                            final p = pieces[i];
                            final isPlacedNow = introDone
                                ? placed.contains(p.id) &&
                                    !_settling.containsKey(p.id)
                                : _localProgress(i) <= 0.0;
                            if (isPlacedNow) continue;
                            final piecePath = JigsawClipper(
                                    p,
                                    cellW,
                                    cellH,
                                    frameW + p.col * cellW,
                                    frameH + p.row * cellH)
                                .getClip(Size(boardW, boardH));
                            combinedCover = Path.combine(
                                PathOperation.union, combinedCover, piecePath);
                          }
                          return Positioned.fromRect(
                            rect: boardRect,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: ClipPath(
                                clipper: _StaticPathClipper(combinedCover),
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFFEBCD),
                                        Color(0xFFFFF3DB)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        Positioned.fromRect(
                          rect: boardRect,
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _PuzzleGuidePainter(
                                  pieces, cellW, cellH, frameW, frameH),
                            ),
                          ),
                        ),
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
                          rect: boardRect,
                          child: DragTarget<String>(
                            onAcceptWithDetails: (details) {
                              final pieceIndex = pieces
                                  .indexWhere((p) => p.id == details.data);
                              if (pieceIndex < 0 ||
                                  placed.contains(details.data)) {
                                return;
                              }
                              final home = layout.homes[pieceIndex];
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
                                    Offset(home.width * 0.5, home.height * 0.5),
                              );
                              if (cell == null) return;
                              final target = pieces.firstWhere((p) =>
                                  p.row == cell.row && p.col == cell.col);
                              final box = _stackKey.currentContext!
                                  .findRenderObject() as RenderBox;
                              final dropCenter = box.globalToLocal(
                                  details.offset +
                                      Offset(home.width / 2, home.height / 2));
                              final destination = pieceBoardRect(target);
                              final delta = dropCenter - destination.center;
                              _handleDrop(details.data, target.id,
                                  startOffset: Offset(
                                      delta.dx / destination.width,
                                      delta.dy / destination.height),
                                  startScale:
                                      home.width * 1.2 / destination.width);
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
                              const angle = 0.0;
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
                                      // Incorrect drops return to their own home,
                                      // keeping every piece visible and separated.
                                    ),
                                  ),
                                ),
                              );
                            }),
                        for (final piece in pieces)
                          if (_settling.containsKey(piece.id))
                            Positioned.fromRect(
                                rect: pieceBoardRect(piece),
                                child: PuzzlePlacementEffect(
                                  key: ValueKey('placement-${piece.id}'),
                                  startOffset: _settling[piece.id]!,
                                  startScale: _settlingScales[piece.id]!,
                                  onCompleted: () => _finishPlacement(piece.id),
                                  child: _TrayPiece(
                                      piece: piece,
                                      imageAsset: imageAsset,
                                      rows: rows,
                                      cols: cols,
                                      draggable: false),
                                )),
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
              onNextGame: _resolvedOnNextGame ?? () {},
              placedCount: placed.length,
              totalCount: pieces.length,
            ),
        ],
      ),
    );
  }
}

class _PuzzleGuidePainter extends CustomPainter {
  final List<JigsawPiece> pieces;
  final double cellW, cellH, frameW, frameH;
  _PuzzleGuidePainter(
      this.pieces, this.cellW, this.cellH, this.frameW, this.frameH);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC99B64).withValues(alpha: 0.48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;
    for (final piece in pieces) {
      canvas.drawPath(
          JigsawClipper(piece, cellW, cellH, frameW + piece.col * cellW,
                  frameH + piece.row * cellH,
                  edgeInflation: 0)
              .getClip(size),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PuzzleGuidePainter old) =>
      old.cellW != cellW || old.cellH != cellH || old.pieces != pieces;
}

class _TrayPiece extends StatelessWidget {
  final bool draggable;
  final JigsawPiece piece;
  final String imageAsset;
  final int rows, cols;
  const _TrayPiece(
      {this.draggable = true,
      required this.piece,
      required this.imageAsset,
      required this.rows,
      required this.cols});

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
            child: PhysicalShape(
              elevation: 4,
              color: const Color(0xFFFFE5AC),
              shadowColor: const Color(0xAA774519),
              clipBehavior: Clip.antiAlias,
              clipper: JigsawClipper(piece, cellW, cellH, overflowW, overflowH),
              child: Stack(
                children: [
                  Positioned(
                    left: -(frameW + piece.col * cellW) + overflowW,
                    top: -(frameH + piece.row * cellH) + overflowH,
                    width: boardW,
                    height: boardH,
                    child: Image.asset(imageAsset, fit: BoxFit.cover),
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

        if (!draggable) return content;
        return Draggable<String>(
          key: ValueKey('puzzle-piece-${piece.id}'),
          data: piece.id,
          maxSimultaneousDrags: 1,
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
          child: content,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  BACK BUTTON
// ─────────────────────────────────────────────
class _BackButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.88),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 20, 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF643CC8).withValues(alpha: 0.15),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chevron_left_rounded,
                  size: 24, color: Color(0xFF5C28A0)),
              const SizedBox(width: 2),
              Text(AppLocalizations.of(context)!.back,
                  style: const TextStyle(
                    fontFamily: 'Baloo2 ExtraBold',
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    color: Color(0xFF5C28A0),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIN OVERLAY
// ─────────────────────────────────────────────
//
const _celebrationAssets = 'assets/puzzle/level_complete/';

class _WinOverlay extends StatelessWidget {
  final String animalName;
  final AnimationController winCtrl, celebCtrl;
  final List<AnimationController> starCtrls;
  final VoidCallback onReset, onBack, onNextGame;
  final int placedCount, totalCount;

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
        children: [
          Image.asset('${_celebrationAssets}background.webp',
              fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BackButton(onTap: onBack),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5DF),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x55764B21),
                                offset: Offset(0, 3),
                                blurRadius: 6)
                          ],
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.extension_rounded,
                              color: Color(0xFF11A9F1), size: 28),
                          const SizedBox(width: 10),
                          Text('$placedCount / $totalCount',
                              style: const TextStyle(
                                fontFamily: 'Baloo2 ExtraBold',
                                fontSize: 22,
                                color: Color(0xFF784226),
                                fontWeight: FontWeight.w900,
                              )),
                        ]),
                      ),
                    ],
                  ),
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      final width = min(
                          constraints.maxWidth, constraints.maxHeight * 1.5);
                      return Center(
                        child: SizedBox(
                          width: width,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: AnimatedBuilder(
                                    animation: celebCtrl,
                                    builder: (_, child) => Opacity(
                                      opacity: 0.65 + celebCtrl.value * 0.25,
                                      child: child,
                                    ),
                                    child: Image.asset(
                                        '${_celebrationAssets}glow.webp',
                                        fit: BoxFit.contain),
                                  ),
                                ),
                              ),
                              ...List.generate(16, (index) {
                                const assets = [
                                  'star',
                                  'pink_confetti',
                                  'blue_confetti',
                                  'green_confetti',
                                  'purple_confetti',
                                  'sparkle'
                                ];
                                final x = [
                                  0.04,
                                  0.87,
                                  0.18,
                                  0.77,
                                  0.02,
                                  0.91,
                                  0.12,
                                  0.82
                                ][index % 8];
                                final y = (index ~/ 2) / 9;
                                final side =
                                    width * (index % 6 == 0 ? 0.11 : 0.065);
                                return Positioned(
                                  left: x * (width - side),
                                  top: y * (constraints.maxHeight - side),
                                  width: side,
                                  height: side,
                                  child: IgnorePointer(
                                      child: Image.asset(
                                          '$_celebrationAssets${assets[index % assets.length]}.webp')),
                                );
                              }),
                              Positioned(
                                top: constraints.maxHeight * 0.21,
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.88, end: 1)
                                      .animate(CurvedAnimation(
                                          parent: winCtrl,
                                          curve: Curves.easeOutBack)),
                                  child: Image.asset(
                                      '${_celebrationAssets}hippoInBox.webp',
                                      alignment: Alignment.bottomCenter,
                                      fit: BoxFit.contain),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: width * 0.06,
                                right: width * 0.06,
                                height: constraints.maxHeight * 0.27,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: _CelebrationTitle(
                                      text: AppLocalizations.of(context)!
                                          .awesome),
                                ),
                              ),
                              Positioned(
                                left: 8,
                                right: 8,
                                bottom: 12,
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 460),
                                    child: Row(children: [
                                      Expanded(
                                          child: _WinButton(
                                        label: AppLocalizations.of(context)!
                                            .playAgain,
                                        icon: Icons.refresh_rounded,
                                        colors: const [
                                          Color(0xFF9CEC34),
                                          Color(0xFF35B514)
                                        ],
                                        onTap: onReset,
                                      )),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: _WinButton(
                                        label: 'Diğer Oyuna Geç',
                                        icon: Icons.arrow_forward_rounded,
                                        colors: const [
                                          Color(0xFF45D6FF),
                                          Color(0xFF0094F4)
                                        ],
                                        onTap: onNextGame,
                                      )),
                                    ]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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

class _CelebrationTitle extends StatelessWidget {
  final String text;
  const _CelebrationTitle({required this.text});

  static const _style = TextStyle(
    fontFamily: 'Baloo2 ExtraBold',
    fontSize: 90,
    height: 1.2,
    fontWeight: FontWeight.w900,
  );

  @override
  Widget build(BuildContext context) {
    final letters = text.characters.toList();
    final widths = letters.map((letter) {
      final painter = TextPainter(
        text: TextSpan(text: letter, style: _style),
        textDirection: Directionality.of(context),
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }).toList();
    final totalWidth = widths.fold<double>(0, (sum, width) => sum + width);
    final rise = totalWidth * 0.10;
    const padding = 28.0;
    var left = 0.0;
    final glyphs = <Widget>[];
    for (var i = 0; i < letters.length; i++) {
      final width = widths[i];
      final position =
          totalWidth == 0 ? 0.0 : (left + width / 2) / totalWidth * 2 - 1;
      glyphs.add(Positioned(
        left: padding + left,
        top: padding + rise * position * position,
        child: Transform.rotate(
          angle: atan(0.4 * position),
          child: _letter(letters[i]),
        ),
      ));
      left += width;
    }
    return Semantics(
      label: text,
      header: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: totalWidth + padding * 2,
          height: 108 + rise + padding * 2,
          child: Stack(clipBehavior: Clip.none, children: glyphs),
        ),
      ),
    );
  }

  Widget _letter(String letter) => Stack(clipBehavior: Clip.none, children: [
        Text(letter,
            style: _style.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 14
                ..color = const Color(0xFF8F1EC4),
              shadows: const [
                Shadow(
                    color: Color(0xFF5B148F),
                    offset: Offset(0, 7),
                    blurRadius: 3)
              ],
            )),
        Text(letter,
            style: _style.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = const Color(0xFFFFF5B2))),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF499), Color(0xFFFFCF27), Color(0xFFFF9E19)],
          ).createShader(bounds),
          child: Text(letter, style: _style.copyWith(color: Colors.white)),
        ),
      ]);
}

class _WinButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  const _WinButton(
      {required this.label,
      required this.icon,
      required this.colors,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
              color: colors.last.withValues(alpha: 0.45),
              offset: const Offset(0, 4),
              blurRadius: 7)
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Flexible(
                  child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label,
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'Baloo2 ExtraBold',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    )),
              )),
            ]),
          ),
        ),
      ),
    );
  }
}
