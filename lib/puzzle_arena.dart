import 'dart:math';
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

  /// How many pieces the puzzle should have (6 / 8 / 12 map to a matching
  /// grid via _gridSizeForPieceCount; any other count falls back to a
  /// roughly-square grid).
  final int pieceCount;

  const PuzzleArena({
    super.key,
    required this.imagePath,
    required this.onBack,
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
    scatterFrac = List.generate(
        pieces.length, (_) => Offset(rnd.nextDouble(), rnd.nextDouble()));
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
      scatterFrac = List.generate(
          pieces.length, (_) => Offset(rnd.nextDouble(), rnd.nextDouble()));
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
                final pieceBoxW = scatterArea.width * 0.55;
                final pieceBoxH = pieceBoxW;

                // ── Board geometry (absolute coords) ──
                final boardOuter = Rect.fromLTWH(trayW, 0, boardAreaW, totalH)
                    .deflate(kBoardMargin);
                final boardPadded = boardOuter.deflate(kBoardPad);
                final squareSize = min(boardPadded.width, boardPadded.height);
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

                        // ── board slots (drag targets) ──
                        for (int i = 0; i < pieces.length; i++)
                          Positioned.fromRect(
                            rect: pieceBoardRect(pieces[i]),
                            child: _BoardSlot(
                              piece: pieces[i],
                              cellW: cellW,
                              cellH: cellH,
                              isPlaced: introDone
                                  ? placed.contains(pieces[i].id)
                                  : _localProgress(i) <= 0.0,
                              onDrop: _handleDrop,
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
                                        // Dropped somewhere — if that's inside the tray's
                                        // scatter area, move this piece's resting spot
                                        // there. If it's outside (e.g. on the board),
                                        // the board's own DragTarget already handled it
                                        // via _handleDrop, so we do nothing extra here.
                                        final stackBox = _stackKey
                                            .currentContext
                                            ?.findRenderObject() as RenderBox?;
                                        if (stackBox == null) return;
                                        final localPoint = stackBox
                                            .globalToLocal(details.offset);
                                        if (!scatterArea.contains(localPoint))
                                          return;
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
//  BOARD SLOT (DragTarget). No longer self-positions — the parent places
//  it via Positioned.fromRect so it shares the same coordinate space the
//  intro-flight math uses.
// ─────────────────────────────────────────────
class _BoardSlot extends StatefulWidget {
  final JigsawPiece piece;
  final double cellW, cellH;
  final bool isPlaced;
  final void Function(String, String) onDrop;

  const _BoardSlot({
    required this.piece,
    required this.cellW,
    required this.cellH,
    required this.isPlaced,
    required this.onDrop,
  });

  @override
  State<_BoardSlot> createState() => _BoardSlotState();
}

class _BoardSlotState extends State<_BoardSlot> {
  bool isOver = false;

  @override
  Widget build(BuildContext context) {
    double overflowW = widget.cellW * 0.3;
    double overflowH = widget.cellH * 0.3;

    return DragTarget<String>(
      onWillAcceptWithDetails: (_) {
        if (!widget.isPlaced) setState(() => isOver = true);
        return !widget.isPlaced;
      },
      onLeave: (_) => setState(() => isOver = false),
      onAcceptWithDetails: (details) {
        setState(() => isOver = false);
        widget.onDrop(details.data, widget.piece.id);
      },
      builder: (context, candidates, rejected) {
        if (widget.isPlaced) {
          // Nothing to draw: the full board image (painted once, underneath
          // everything) already shows the correct artwork here.
          return const SizedBox.shrink();
        }

        // The permanent cover for unsolved cells is drawn once, as a single
        // unioned shape, by the parent (see the "unified cover" builder in
        // _buildGame) — that's what avoids the seam. This slot only adds a
        // transient highlight while a piece is being dragged over it.
        if (!isOver) return const SizedBox.shrink();
        return ClipPath(
          clipper: JigsawClipper(
              widget.piece, widget.cellW, widget.cellH, overflowW, overflowH),
          child: Container(color: const Color(0xFFF5C68A)),
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
class _WinOverlay extends StatelessWidget {
  final String animalName;
  final AnimationController winCtrl, celebCtrl;
  final List<AnimationController> starCtrls;
  final VoidCallback onReset;

  const _WinOverlay({
    required this.animalName,
    required this.winCtrl,
    required this.celebCtrl,
    required this.starCtrls,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: winCtrl, curve: Curves.easeIn),
      child: Container(
        color: const Color(0xFF78C850).withValues(alpha: 0.93),
        child: Center(
          child: ScaleTransition(
            scale: CurvedAnimation(parent: winCtrl, curve: Curves.elasticOut),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: celebCtrl,
                      builder: (_, child) {
                        final angle = (-10 + 20 * celebCtrl.value) * pi / 180;
                        return Transform.rotate(angle: angle, child: child);
                      },
                      child: const Text('🐻', style: TextStyle(fontSize: 80)),
                    ),
                    const SizedBox(width: 20),
                    AnimatedBuilder(
                      animation: celebCtrl,
                      builder: (_, child) {
                        final angle = (10 - 20 * celebCtrl.value) * pi / 180;
                        return Transform.rotate(angle: angle, child: child);
                      },
                      child: const Text('👮', style: TextStyle(fontSize: 80)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context)!.awesome,
                    style: const TextStyle(
                        fontFamily: 'Baloo2 ExtraBold',
                        fontWeight: FontWeight.bold,
                        fontSize: 46,
                        color: Colors.white)),
                Text(AppLocalizations.of(context)!.puzzleComplete(animalName),
                    style: const TextStyle(
                        fontFamily: 'Baloo2 ExtraBold',
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      3,
                      (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ScaleTransition(
                                scale: CurvedAnimation(
                                    parent: starCtrls[i],
                                    curve: Curves.elasticOut),
                                child: const Text('⭐',
                                    style: TextStyle(fontSize: 40))),
                          )),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: onReset,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 44, vertical: 16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999)),
                    child: Text(AppLocalizations.of(context)!.playAgain,
                        style: const TextStyle(
                            fontFamily: 'Baloo2 ExtraBold',
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Color(0xFF3A7A10))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
