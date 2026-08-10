import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';

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

List<JigsawPiece> generate3x3() {
  return [
    JigsawPiece(0, 0, EdgeType.flat, EdgeType.tab, EdgeType.blank, EdgeType.flat),
    JigsawPiece(0, 1, EdgeType.flat, EdgeType.blank, EdgeType.tab, EdgeType.blank),
    JigsawPiece(0, 2, EdgeType.flat, EdgeType.flat, EdgeType.tab, EdgeType.tab),
    JigsawPiece(1, 0, EdgeType.tab, EdgeType.tab, EdgeType.tab, EdgeType.flat),
    JigsawPiece(1, 1, EdgeType.blank, EdgeType.blank, EdgeType.blank, EdgeType.blank),
    JigsawPiece(1, 2, EdgeType.blank, EdgeType.flat, EdgeType.blank, EdgeType.tab),
    JigsawPiece(2, 0, EdgeType.blank, EdgeType.blank, EdgeType.flat, EdgeType.flat),
    JigsawPiece(2, 1, EdgeType.tab, EdgeType.tab, EdgeType.flat, EdgeType.tab),
    JigsawPiece(2, 2, EdgeType.tab, EdgeType.flat, EdgeType.flat, EdgeType.blank),
  ];
}

class JigsawClipper extends CustomClipper<Path> {
  final JigsawPiece piece;
  final double cellW, cellH;
  final double ox, oy;
  JigsawClipper(this.piece, this.cellW, this.cellH, this.ox, this.oy);

  @override
  Path getClip(Size size) {
    Path p = Path();
    Offset topLeft = Offset(ox, oy);
    Offset topRight = Offset(ox + cellW, oy);
    Offset botRight = Offset(ox + cellW, oy + cellH);
    Offset botLeft = Offset(ox, oy + cellH);

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

    // tab points to the LEFT of the vector
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

// ─────────────────────────────────────────────
//  PUZZLE ARENA WIDGET
// ─────────────────────────────────────────────
class PuzzleArena extends StatefulWidget {
  final String imagePath;
  final VoidCallback onBack;

  const PuzzleArena({super.key, required this.imagePath, required this.onBack});

  @override
  State<PuzzleArena> createState() => _PuzzleArenaState();
}

class _PuzzleArenaState extends State<PuzzleArena> with TickerProviderStateMixin {
  final List<JigsawPiece> pieces = generate3x3();
  final Set<String> placed = {};
  bool wrongFlash = false;
  bool showWin = false;

  late String imageAsset;

  // Win animation controllers
  late AnimationController _winCtrl;
  late AnimationController _celebCtrl;
  final List<AnimationController> _starCtrls = [];

  @override
  void initState() {
    super.initState();
    imageAsset = widget.imagePath;
    
    // Shuffle pieces randomly in the tray
    pieces.shuffle();

    _winCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _celebCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    for (int i = 0; i < 3; i++) {
      _starCtrls.add(AnimationController(vsync: this, duration: const Duration(milliseconds: 400)));
    }
  }

  @override
  void dispose() {
    _winCtrl.dispose();
    _celebCtrl.dispose();
    for (final c in _starCtrls) c.dispose();
    super.dispose();
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
    });
    _winCtrl.reset();
    for (final c in _starCtrls) c.reset();
  }

  String get _puzzleName {
    final filename = imageAsset.split('/').last.split('.').first;
    return filename
        .split('_')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF72D8F5), Color(0xFFB0EAFC), Color(0xFFCAF5E2), Color(0xFFB0E8A8)],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isPortrait = constraints.maxHeight > constraints.maxWidth;
                  
                  Widget trayContent = Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.72), width: 2),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _BackButton(onTap: widget.onBack),
                              Text('${placed.length} / ${pieces.length}',
                                  style: const TextStyle(fontFamily: 'Fredoka', fontSize: 18, color: Color(0xFF7854B8), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, trayConstraints) {
                              return GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isPortrait ? 3 : 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.0,
                                ),
                                itemCount: pieces.length,
                                itemBuilder: (ctx, i) {
                                  final p = pieces[i];
                                  if (placed.contains(p.id)) return const SizedBox();
                                  return _TrayPiece(piece: p, imageAsset: imageAsset);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );

                  Widget boardContent = Center(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.32),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white.withOpacity(0.55), width: 2),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: LayoutBuilder(
                          builder: (ctx, boardConstraints) {
                            double boardW = boardConstraints.maxWidth;
                            double boardH = boardConstraints.maxHeight;
                            double cellW = boardW / 3;
                            double cellH = boardH / 3;

                            return Stack(
                              children: [
                                Opacity(
                                  opacity: 0.15,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(imageAsset, width: boardW, height: boardH, fit: BoxFit.fill),
                                  ),
                                ),
                                if (wrongFlash)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(color: const Color(0xFFFF5050).withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                                    ),
                                  ),
                                for (var p in generate3x3())
                                  _BoardSlot(
                                    piece: p,
                                    cellW: cellW, cellH: cellH,
                                    boardW: boardW, boardH: boardH,
                                    isPlaced: placed.contains(p.id),
                                    imageAsset: imageAsset,
                                    onDrop: _handleDrop,
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );

                  if (isPortrait) {
                    return Column(
                      children: [
                        Expanded(flex: 2, child: boardContent),
                        Expanded(flex: 2, child: trayContent),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Expanded(flex: 1, child: trayContent),
                        Expanded(flex: 2, child: boardContent),
                      ],
                    );
                  }
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
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TRAY PIECE (Draggable)
// ─────────────────────────────────────────────
class _TrayPiece extends StatelessWidget {
  final JigsawPiece piece;
  final String imageAsset;
  const _TrayPiece({required this.piece, required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // We just render the piece as if board size was 3x this container
        double widgetW = constraints.maxWidth;
        double widgetH = constraints.maxHeight;
        
        double cellW = widgetW / 1.6; // Scale down so tabs fit inside the box
        double cellH = widgetH / 1.6;
        double overflowW = cellW * 0.3;
        double overflowH = cellH * 0.3;
        double boardW = cellW * 3;
        double boardH = cellH * 3;

        Widget content = Center(
          child: SizedBox(
            width: cellW + overflowW * 2,
            height: cellH + overflowH * 2,
            child: ClipPath(
              clipper: JigsawClipper(piece, cellW, cellH, overflowW, overflowH),
              child: Stack(
                children: [
                  Positioned(
                    left: -(piece.col * cellW) + overflowW,
                    top: -(piece.row * cellH) + overflowH,
                    width: boardW,
                    height: boardH,
                    child: Image.asset(imageAsset, fit: BoxFit.fill),
                  ),
                  // Add a subtle border effect via shadow or overlay if desired
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
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
            child: Transform.scale(scale: 1.2, child: Opacity(opacity: 0.9, child: SizedBox(width: widgetW, height: widgetH, child: content))),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: content),
          child: content,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  BOARD SLOT (DragTarget)
// ─────────────────────────────────────────────
class _BoardSlot extends StatefulWidget {
  final JigsawPiece piece;
  final double cellW, cellH, boardW, boardH;
  final bool isPlaced;
  final String imageAsset;
  final void Function(String, String) onDrop;

  const _BoardSlot({
    required this.piece, required this.cellW, required this.cellH,
    required this.boardW, required this.boardH,
    required this.isPlaced, required this.imageAsset, required this.onDrop,
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
    
    return Positioned(
      left: widget.piece.col * widget.cellW - overflowW,
      top: widget.piece.row * widget.cellH - overflowH,
      width: widget.cellW + overflowW * 2,
      height: widget.cellH + overflowH * 2,
      child: DragTarget<String>(
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
            return ClipPath(
              clipper: JigsawClipper(widget.piece, widget.cellW, widget.cellH, overflowW, overflowH),
              child: Stack(
                children: [
                  Positioned(
                    left: -(widget.piece.col * widget.cellW) + overflowW,
                    top: -(widget.piece.row * widget.cellH) + overflowH,
                    width: widget.boardW,
                    height: widget.boardH,
                    child: Image.asset(widget.imageAsset, fit: BoxFit.fill),
                  ),
                ],
              ),
            );
          }

          // Slot outline
          return Stack(
            children: [
              if (isOver)
                ClipPath(
                  clipper: JigsawClipper(widget.piece, widget.cellW, widget.cellH, overflowW, overflowH),
                  child: Container(color: Colors.white.withOpacity(0.4)),
                ),
            ],
          );
        },
      ),
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
          color: Colors.white.withOpacity(0.68),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Icon(Icons.chevron_left_rounded, size: 28, color: Color(0xFF5C28A0)),
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
    required this.animalName, required this.winCtrl, required this.celebCtrl,
    required this.starCtrls, required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: winCtrl, curve: Curves.easeIn),
      child: Container(
        color: const Color(0xFF78C850).withOpacity(0.93),
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
                const Text('Awesome!', style: TextStyle(fontFamily: 'Fredoka One', fontSize: 46, color: Colors.white)),
                Text('$animalName puzzle complete! 🌟', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ScaleTransition(scale: CurvedAnimation(parent: starCtrls[i], curve: Curves.elasticOut), child: const Text('⭐', style: TextStyle(fontSize: 40))),
                  )),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: onReset,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                    child: const Text('Play Again! 🔄', style: TextStyle(fontFamily: 'Fredoka One', fontSize: 22, color: Color(0xFF3A7A10))),
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
