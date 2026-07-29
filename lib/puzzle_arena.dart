import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  ANIMAL ID
// ─────────────────────────────────────────────
enum AnimalId { lion, elephant, giraffe }

// ─────────────────────────────────────────────
//  PUZZLE DATA MODELS
// ─────────────────────────────────────────────
class CropBox {
  final double vx, vy, vw, vh, fullW, fullH;
  const CropBox({
    required this.vx, required this.vy,
    required this.vw, required this.vh,
    required this.fullW, required this.fullH,
  });
}

class PieceData {
  final String id;
  final String label;
  final Color cardColor;
  final Color cardShadow;
  final CropBox crop;
  const PieceData({
    required this.id, required this.label,
    required this.cardColor, required this.cardShadow,
    required this.crop,
  });
}

class AnimalConfig {
  final String label;
  final double assemblyW, assemblyH;
  final CustomPainter Function(bool colored) painterBuilder;
  final List<PieceData> pieces;
  const AnimalConfig({
    required this.label,
    required this.assemblyW, required this.assemblyH,
    required this.painterBuilder,
    required this.pieces,
  });
}

// ─────────────────────────────────────────────
//  CONFIGS
// ─────────────────────────────────────────────
final Map<AnimalId, AnimalConfig> kConfigs = {
  AnimalId.lion: AnimalConfig(
    label: 'Lion', assemblyW: 110, assemblyH: 150,
    painterBuilder: (c) => LionPainter(colored: c),
    pieces: const [
      PieceData(id: 'mane_head', label: 'Head',
        cardColor: Color(0xFFFFB347), cardShadow: Color(0xFFC05000),
        crop: CropBox(vx:4, vy:0, vw:102, vh:82, fullW:110, fullH:150)),
      PieceData(id: 'body', label: 'Body',
        cardColor: Color(0xFFF5A623), cardShadow: Color(0xFFB06010),
        crop: CropBox(vx:15, vy:80, vw:80, vh:52, fullW:110, fullH:150)),
      PieceData(id: 'tail', label: 'Tail',
        cardColor: Color(0xFFE67E22), cardShadow: Color(0xFFA04000),
        crop: CropBox(vx:70, vy:55, vw:40, vh:60, fullW:110, fullH:150)),
      PieceData(id: 'legs', label: 'Legs',
        cardColor: Color(0xFFF0A030), cardShadow: Color(0xFFB07010),
        crop: CropBox(vx:15, vy:115, vw:80, vh:35, fullW:110, fullH:150)),
    ],
  ),
  AnimalId.elephant: AnimalConfig(
    label: 'Elephant', assemblyW: 124, assemblyH: 148,
    painterBuilder: (c) => ElephantPainter(colored: c),
    pieces: const [
      PieceData(id: 'head_trunk', label: 'Head',
        cardColor: Color(0xFF5DADE2), cardShadow: Color(0xFF1A60B0),
        crop: CropBox(vx:5, vy:0, vw:114, vh:90, fullW:124, fullH:148)),
      PieceData(id: 'ears', label: 'Ears',
        cardColor: Color(0xFF4090C8), cardShadow: Color(0xFF1050A0),
        crop: CropBox(vx:0, vy:18, vw:124, vh:60, fullW:124, fullH:148)),
      PieceData(id: 'body', label: 'Body',
        cardColor: Color(0xFF6BBDE8), cardShadow: Color(0xFF2070B8),
        crop: CropBox(vx:5, vy:72, vw:114, vh:56, fullW:124, fullH:148)),
      PieceData(id: 'legs', label: 'Legs',
        cardColor: Color(0xFF3A90D8), cardShadow: Color(0xFF0A50A0),
        crop: CropBox(vx:10, vy:118, vw:104, vh:30, fullW:124, fullH:148)),
    ],
  ),
  AnimalId.giraffe: AnimalConfig(
    label: 'Giraffe', assemblyW: 90, assemblyH: 162,
    painterBuilder: (c) => GiraffePainter(colored: c),
    pieces: const [
      PieceData(id: 'head_neck', label: 'Head',
        cardColor: Color(0xFFFFD93D), cardShadow: Color(0xFFB07000),
        crop: CropBox(vx:10, vy:0, vw:70, vh:62, fullW:90, fullH:162)),
      PieceData(id: 'neck_spots', label: 'Neck',
        cardColor: Color(0xFFF5C020), cardShadow: Color(0xFF9A5800),
        crop: CropBox(vx:24, vy:30, vw:46, vh:80, fullW:90, fullH:162)),
      PieceData(id: 'body', label: 'Body',
        cardColor: Color(0xFFFFE566), cardShadow: Color(0xFFC08000),
        crop: CropBox(vx:8, vy:82, vw:82, vh:66, fullW:90, fullH:162)),
      PieceData(id: 'legs', label: 'Legs',
        cardColor: Color(0xFFFFC820), cardShadow: Color(0xFFA06000),
        crop: CropBox(vx:10, vy:132, vw:72, vh:30, fullW:90, fullH:162)),
    ],
  ),
};

// ─────────────────────────────────────────────
//  PUZZLE ARENA
// ─────────────────────────────────────────────
class PuzzleArena extends StatefulWidget {
  final AnimalId animal;
  final VoidCallback onBack;

  const PuzzleArena({super.key, required this.animal, required this.onBack});

  @override
  State<PuzzleArena> createState() => _PuzzleArenaState();
}

class _PuzzleArenaState extends State<PuzzleArena> with TickerProviderStateMixin {
  late AnimalConfig config;
  final Set<String> placed = {};
  bool wrongFlash = false;
  bool showWin = false;

  // Assembly display dimensions
  static const double displayW = 200;
  late double displayH;

  // Win animation controllers
  late AnimationController _winCtrl;
  late AnimationController _celebCtrl;
  final List<AnimationController> _starCtrls = [];

  @override
  void initState() {
    super.initState();
    config = kConfigs[widget.animal]!;
    displayH = (displayW * config.assemblyH / config.assemblyW).roundToDouble();

    _winCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _celebCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);

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
      if (placed.length == config.pieces.length) {
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
    });
    _winCtrl.reset();
    for (final c in _starCtrls) c.reset();
  }

  double get progress => placed.length / config.pieces.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.45, 0.80, 1.0],
            colors: [Color(0xFF72D8F5), Color(0xFFB0EAFC), Color(0xFFCAF5E2), Color(0xFFB0E8A8)],
          ),
        ),
        child: Stack(
          children: [
            // BG blobs
            Positioned(top: -60, left: -60,
              child: Container(width: 200, height: 200,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.13)))),
            Positioned(bottom: 80, right: -30,
              child: Container(width: 140, height: 140,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFC4A8E8).withOpacity(0.16)))),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // ── TOP BAR ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BackButton(onTap: widget.onBack),
                        _ProgressBar(placed: placed.length, total: config.pieces.length, progress: progress),
                      ],
                    ),
                  ),

                  // ── TITLE ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                    child: Column(
                      children: [
                        Text('${config.label} Puzzle 🧩',
                          style: const TextStyle(
                            fontFamily: 'Fredoka One', fontSize: 26,
                            color: Color(0xFF5C28A0),
                            shadows: [Shadow(color: Colors.white54, offset: Offset(0, 3))],
                          )),
                        const Text('Drag the pieces to build the animal!',
                          style: TextStyle(
                            fontFamily: 'Fredoka', fontSize: 13,
                            color: Color(0xFF7854B8), fontWeight: FontWeight.w500,
                          )),
                      ],
                    ),
                  ),

                  // ── ASSEMBLY ZONE ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _AssemblyZone(
                      config: config,
                      placed: placed,
                      displayW: displayW,
                      displayH: displayH,
                      wrongFlash: wrongFlash,
                      onDrop: _handleDrop,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── PIECE TRAY ──
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: _PieceTray(config: config, placed: placed),
                    ),
                  ),
                ],
              ),
            ),

            // ── WIN OVERLAY ──
            if (showWin)
              _WinOverlay(
                config: config,
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
//  TOP BAR WIDGETS
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
      onTapUp: (_) { setState(() => _scale = 1.0); widget.onTap(); },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 20, 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.68),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [BoxShadow(color: const Color(0xFF643CC8).withOpacity(0.15), blurRadius: 14, offset: const Offset(0, 4))],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chevron_left_rounded, size: 24, color: Color(0xFF5C28A0)),
              SizedBox(width: 2),
              Text('Back', style: TextStyle(fontFamily: 'Fredoka One', fontSize: 19, color: Color(0xFF5C28A0))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int placed, total;
  final double progress;
  const _ProgressBar({required this.placed, required this.total, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$placed / $total',
          style: const TextStyle(fontFamily: 'Fredoka', fontSize: 13, color: Color(0xFF7854B8), fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 90, height: 10,
            color: Colors.white.withOpacity(0.45),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                widthFactor: progress,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFA8D85C), Color(0xFF5AAA20)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  ASSEMBLY ZONE
// ─────────────────────────────────────────────
class _AssemblyZone extends StatelessWidget {
  final AnimalConfig config;
  final Set<String> placed;
  final double displayW, displayH;
  final bool wrongFlash;
  final void Function(String pieceId, String slotId) onDrop;

  const _AssemblyZone({
    required this.config, required this.placed,
    required this.displayW, required this.displayH,
    required this.wrongFlash, required this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.32),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.55), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFF5C28A0).withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Zone label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('🎯', style: TextStyle(fontSize: 14)),
              SizedBox(width: 4),
              Text('ASSEMBLY AREA',
                style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w700, fontSize: 12,
                    color: Color(0xFF9575CD), letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 10),

          // Assembly SVG + drop slots
          Center(
            child: SizedBox(
              width: displayW,
              height: displayH,
              child: Stack(
                children: [
                  // Ghost silhouette
                  CustomPaint(
                    size: Size(displayW, displayH),
                    painter: _ScaledAnimalPainter(
                      inner: config.painterBuilder(false),
                      assemblyW: config.assemblyW,
                      assemblyH: config.assemblyH,
                    ),
                  ),

                  // Placed colored pieces (clipped)
                  for (final piece in config.pieces)
                    if (placed.contains(piece.id))
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: ClipRect(
                          clipper: _PieceClipper(
                            piece: piece,
                            displayW: displayW,
                            displayH: displayH,
                            assemblyW: config.assemblyW,
                            assemblyH: config.assemblyH,
                          ),
                          child: CustomPaint(
                            size: Size(displayW, displayH),
                            painter: _ScaledAnimalPainter(
                              inner: config.painterBuilder(true),
                              assemblyW: config.assemblyW,
                              assemblyH: config.assemblyH,
                            ),
                          ),
                        ),
                      ),

                  // Wrong flash overlay
                  if (wrongFlash)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5050).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),

                  // Drop slots
                  for (final piece in config.pieces)
                    _PieceSlot(
                      piece: piece,
                      config: config,
                      placed: placed.contains(piece.id),
                      displayW: displayW,
                      displayH: displayH,
                      onDrop: onDrop,
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

// Clips the canvas to a piece's crop region
class _PieceClipper extends CustomClipper<Rect> {
  final PieceData piece;
  final double displayW, displayH, assemblyW, assemblyH;

  const _PieceClipper({
    required this.piece, required this.displayW, required this.displayH,
    required this.assemblyW, required this.assemblyH,
  });

  @override
  Rect getClip(Size size) {
    final sx = displayW / assemblyW;
    final sy = displayH / assemblyH;
    return Rect.fromLTWH(
      piece.crop.vx * sx, piece.crop.vy * sy,
      piece.crop.vw * sx, piece.crop.vh * sy,
    );
  }

  @override
  bool shouldReclip(_PieceClipper old) => false;
}

// Wraps any CustomPainter and scales it to fit displayW/displayH
class _ScaledAnimalPainter extends CustomPainter {
  final CustomPainter inner;
  final double assemblyW, assemblyH;

  const _ScaledAnimalPainter({required this.inner, required this.assemblyW, required this.assemblyH});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / assemblyW, size.height / assemblyH);
    inner.paint(canvas, Size(assemblyW, assemblyH));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScaledAnimalPainter o) => false;
}

// ─────────────────────────────────────────────
//  DROP SLOT
// ─────────────────────────────────────────────
class _PieceSlot extends StatefulWidget {
  final PieceData piece;
  final AnimalConfig config;
  final bool placed;
  final double displayW, displayH;
  final void Function(String pieceId, String slotId) onDrop;

  const _PieceSlot({
    required this.piece, required this.config, required this.placed,
    required this.displayW, required this.displayH, required this.onDrop,
  });

  @override
  State<_PieceSlot> createState() => _PieceSlotState();
}

class _PieceSlotState extends State<_PieceSlot> with SingleTickerProviderStateMixin {
  bool isOver = false;
  late AnimationController _checkCtrl;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    if (widget.placed) _checkCtrl.forward();
  }

  @override
  void didUpdateWidget(_PieceSlot old) {
    super.didUpdateWidget(old);
    if (widget.placed && !old.placed) _checkCtrl.forward();
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sx = widget.displayW / widget.config.assemblyW;
    final sy = widget.displayH / widget.config.assemblyH;
    final left   = widget.piece.crop.vx * sx;
    final top    = widget.piece.crop.vy * sy;
    final width  = widget.piece.crop.vw * sx;
    final height = widget.piece.crop.vh * sy;

    final borderColor = widget.placed
        ? const Color(0xFFA8D85C)
        : isOver ? const Color(0xFFFFD93D) : const Color(0xFFB4A0DC).withOpacity(0.6);
    final bgColor = widget.placed
        ? Colors.transparent
        : isOver ? const Color(0xFFFFD93D).withOpacity(0.18) : Colors.transparent;

    return Positioned(
      left: left, top: top, width: width, height: height,
      child: DragTarget<String>(
        onWillAcceptWithDetails: (details) {
          if (!widget.placed) setState(() => isOver = true);
          return !widget.placed;
        },
        onLeave: (_) => setState(() => isOver = false),
        onAcceptWithDetails: (details) {
          setState(() => isOver = false);
          widget.onDrop(details.data, widget.piece.id);
        },
        builder: (context, candidates, rejected) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: 2.5,
                style: BorderStyle.solid,
              ),
            ),
            child: widget.placed
                ? Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: ScaleTransition(
                        scale: CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut),
                        child: Container(
                          width: 18, height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFFA8D85C),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Color(0x6650A028), blurRadius: 6, offset: Offset(0, 2))],
                          ),
                          child: const Center(child: Text('✓', style: TextStyle(fontSize: 10, color: Colors.white))),
                        ),
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PIECE TRAY
// ─────────────────────────────────────────────
class _PieceTray extends StatelessWidget {
  final AnimalConfig config;
  final Set<String> placed;

  const _PieceTray({required this.config, required this.placed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.72), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFF5C28A0).withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('🐾', style: TextStyle(fontSize: 14)),
              SizedBox(width: 4),
              Text('DRAG THE PIECES ABOVE!',
                style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w700, fontSize: 12,
                    color: Color(0xFF9575CD), letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: config.pieces.map((p) => _PieceCard(
                piece: p,
                config: config,
                isPlaced: placed.contains(p.id),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PIECE CARD (draggable)
// ─────────────────────────────────────────────
class _PieceCard extends StatefulWidget {
  final PieceData piece;
  final AnimalConfig config;
  final bool isPlaced;

  const _PieceCard({required this.piece, required this.config, required this.isPlaced});

  @override
  State<_PieceCard> createState() => _PieceCardState();
}

class _PieceCardState extends State<_PieceCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  Widget _buildThumbnail() {
    final p = widget.piece.crop;
    final double thumbW = 60;
    final double thumbH = thumbW * (p.vh / p.vw);
    final double scaleX = thumbW / p.vw;
    final double scaleY = thumbH / p.vh;

    return ClipRect(
      child: SizedBox(
        width: thumbW,
        height: thumbH,
        child: CustomPaint(
          size: Size(thumbW, thumbH),
          painter: _CroppedPainter(
            inner: widget.config.painterBuilder(!widget.isPlaced),
            crop: p,
            scaleX: scaleX,
            scaleY: scaleY,
            assemblyW: widget.config.assemblyW,
            assemblyH: widget.config.assemblyH,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPlaced = widget.isPlaced;

    final card = AnimatedOpacity(
      opacity: isPlaced ? 0.3 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: isPlaced
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [
                        widget.piece.cardColor.withOpacity(0.93),
                        widget.piece.cardColor.withOpacity(0.73),
                      ],
                    ),
              color: isPlaced ? const Color(0xFFA8D85C).withOpacity(0.15) : null,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isPlaced ? const Color(0xFFA8D85C).withOpacity(0.4) : Colors.white.withOpacity(0.6),
                width: 2.5,
                style: isPlaced ? BorderStyle.solid : BorderStyle.solid,
              ),
              boxShadow: isPlaced ? null : [
                BoxShadow(color: widget.piece.cardShadow, offset: const Offset(0, 6)),
                BoxShadow(color: Colors.black.withOpacity(0.15), offset: const Offset(0, 10), blurRadius: 18),
              ],
            ),
            child: Stack(
              children: [
                if (!isPlaced)
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.white.withOpacity(0.38), Colors.white.withOpacity(0)],
                        ),
                      ),
                    ),
                  ),
                Center(child: _buildThumbnail()),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(widget.piece.label,
            style: TextStyle(
              fontFamily: 'Fredoka', fontSize: 12, fontWeight: FontWeight.w600,
              color: isPlaced ? const Color(0xFF7854B8).withOpacity(0.4) : const Color(0xFF7854B8),
            )),
        ],
      ),
    );

    if (isPlaced) return card;

    return Draggable<String>(
      data: widget.piece.id,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.1,
          child: Opacity(opacity: 0.9, child: card),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );
  }
}

// Crops + scales a CustomPainter to show only a piece's region
class _CroppedPainter extends CustomPainter {
  final CustomPainter inner;
  final CropBox crop;
  final double scaleX, scaleY, assemblyW, assemblyH;

  const _CroppedPainter({
    required this.inner, required this.crop,
    required this.scaleX, required this.scaleY,
    required this.assemblyW, required this.assemblyH,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Translate so crop origin becomes 0,0, then scale
    canvas.translate(-crop.vx * scaleX, -crop.vy * scaleY);
    canvas.scale(size.width / assemblyW * (assemblyW / crop.vw),
                 size.height / assemblyH * (assemblyH / crop.vh));
    inner.paint(canvas, Size(assemblyW, assemblyH));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CroppedPainter o) => false;
}

// ─────────────────────────────────────────────
//  WIN OVERLAY
// ─────────────────────────────────────────────
class _WinOverlay extends StatefulWidget {
  final AnimalConfig config;
  final AnimationController winCtrl, celebCtrl;
  final List<AnimationController> starCtrls;
  final VoidCallback onReset;

  const _WinOverlay({
    required this.config, required this.winCtrl, required this.celebCtrl,
    required this.starCtrls, required this.onReset,
  });

  @override
  State<_WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<_WinOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _btnCtrl;
  double _btnScale = 1.0;

  @override
  void initState() {
    super.initState();
    _btnCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: widget.winCtrl, curve: Curves.easeIn),
      child: Container(
        color: const Color(0xFF78C850).withOpacity(0.93),
        child: Center(
          child: ScaleTransition(
            scale: CurvedAnimation(parent: widget.winCtrl, curve: Curves.elasticOut),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🎉 celebrate emoji
                  AnimatedBuilder(
                    animation: widget.celebCtrl,
                    builder: (_, child) {
                      final angle = (-10 + 20 * widget.celebCtrl.value) * pi / 180;
                      final scale = 1.0 + 0.15 * widget.celebCtrl.value;
                      return Transform.scale(
                        scale: scale,
                        child: Transform.rotate(angle: angle, child: child),
                      );
                    },
                    child: const Text('🎉', style: TextStyle(fontSize: 80)),
                  ),
                  const SizedBox(height: 12),

                  const Text('You did it!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka One', fontSize: 46, color: Colors.white,
                      shadows: [Shadow(color: Color(0x1F000000), offset: Offset(0, 5))],
                    )),

                  Text('${widget.config.label} puzzle complete! 🌟',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Fredoka', fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600,
                    )),

                  const SizedBox(height: 12),

                  // Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ScaleTransition(
                        scale: CurvedAnimation(parent: widget.starCtrls[i], curve: Curves.elasticOut),
                        child: Transform.rotate(
                          angle: -30 * pi / 180,
                          child: const Text('⭐', style: TextStyle(fontSize: 40)),
                        ),
                      ),
                    )),
                  ),

                  const SizedBox(height: 20),

                  // Play Again button
                  GestureDetector(
                    onTapDown: (_) => setState(() => _btnScale = 0.92),
                    onTapUp: (_) {
                      setState(() => _btnScale = 1.0);
                      widget.onReset();
                    },
                    onTapCancel: () => setState(() => _btnScale = 1.0),
                    child: AnimatedScale(
                      scale: _btnScale,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), offset: const Offset(0, 7))],
                        ),
                        child: const Text('Play Again! 🔄',
                          style: TextStyle(fontFamily: 'Fredoka One', fontSize: 22, color: Color(0xFF3A7A10))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  ANIMAL PAINTERS (full assembly — colored & silhouette)
// ═══════════════════════════════════════════════════════

// ── LION PAINTER ──
class LionPainter extends CustomPainter {
  final bool colored;
  const LionPainter({required this.colored});

  static const sil = Color(0xFFC0B8D8);

  void oval(Canvas c, double cx, double cy, double rx, double ry, Color col, {double op = 1}) {
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
        Paint()..color = col.withOpacity(op));
  }

  void rrect(Canvas c, double x, double y, double w, double h, double r, Color col) {
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)), Paint()..color = col);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final mane   = colored ? const Color(0xFFE67E22) : sil;
    final head   = colored ? const Color(0xFFF5A623) : sil;
    final snout  = colored ? const Color(0xFFFCD5A0) : sil;
    final accent = colored ? const Color(0xFFC0590A) : sil;
    final pink   = colored ? const Color(0xFFF8A5C2) : sil;

    // Mane
    oval(canvas, 55, 52, 40, 40, mane);
    // Head
    oval(canvas, 55, 52, 29, 29, head);
    // Ears
    oval(canvas, 30, 28, 11, 11, head);
    oval(canvas, 80, 28, 11, 11, head);
    if (colored) { oval(canvas, 30, 28, 6, 6, pink); oval(canvas, 80, 28, 6, 6, pink); }
    // Snout
    oval(canvas, 55, 64, 17, 12, snout);
    if (colored) {
      // Eyes
      oval(canvas, 42, 46, 7, 7, Colors.white); oval(canvas, 68, 46, 7, 7, Colors.white);
      oval(canvas, 44, 46, 4.5, 4.5, const Color(0xFF1A0A30)); oval(canvas, 70, 46, 4.5, 4.5, const Color(0xFF1A0A30));
      canvas.drawCircle(const Offset(45.5, 44), 1.8, Paint()..color = Colors.white);
      canvas.drawCircle(const Offset(71.5, 44), 1.8, Paint()..color = Colors.white);
      // Nose
      oval(canvas, 55, 61, 5, 4, accent);
      // Whisker dots
      for (final d in [[40.0,67.0],[45.0,70.0],[65.0,67.0],[70.0,70.0]]) {
        canvas.drawCircle(Offset(d[0], d[1]), 1.5, Paint()..color = accent.withOpacity(0.6));
      }
      // Smile
      canvas.drawPath(
        Path()..moveTo(43,72)..quadraticBezierTo(55,82,67,72),
        Paint()..color = accent..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
      );
    }
    // Body
    oval(canvas, 55, 112, 30, 26, head);
    // Legs
    rrect(canvas, 24, 122, 18, 24, 9, head); rrect(canvas, 68, 122, 18, 24, 9, head);
    // Tail
    canvas.drawPath(
      Path()..moveTo(83,104)..quadraticBezierTo(100,86,94,66),
      Paint()..color = head..strokeWidth = 6..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(93, 63), 8, Paint()..color = mane);
  }

  @override
  bool shouldRepaint(LionPainter o) => o.colored != colored;
}

// ── ELEPHANT PAINTER ──
class ElephantPainter extends CustomPainter {
  final bool colored;
  const ElephantPainter({required this.colored});

  static const sil = Color(0xFFC0B8D8);

  void oval(Canvas c, double cx, double cy, double rx, double ry, Color col, {double op = 1}) {
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
        Paint()..color = col.withOpacity(op));
  }

  void rrect(Canvas c, double x, double y, double w, double h, double r, Color col) {
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)), Paint()..color = col);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final body  = colored ? const Color(0xFF5DADE2) : sil;
    final dark  = colored ? const Color(0xFF4090C8) : sil;
    final light = colored ? const Color(0xFFA8D8F8) : sil;
    final pink  = colored ? const Color(0xFFF8A5C2) : sil;

    // Body
    oval(canvas, 62, 104, 48, 34, body);
    // Ears
    oval(canvas, 14, 55, 20, 28, dark); oval(canvas, 110, 55, 20, 28, dark);
    if (colored) { oval(canvas, 14, 55, 11, 17, pink, op: 0.45); oval(canvas, 110, 55, 11, 17, pink, op: 0.45); }
    // Head
    oval(canvas, 62, 52, 36, 36, body);
    if (colored) oval(canvas, 58, 38, 22, 16, light, op: 0.4);
    // Trunk
    final trunkPaint = Paint()..color = body..strokeWidth = 16..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final trunkPath = Path()..moveTo(50,78)..quadraticBezierTo(34,96,40,118)..quadraticBezierTo(44,128,54,124);
    canvas.drawPath(trunkPath, trunkPaint);
    if (colored) canvas.drawPath(trunkPath, Paint()..color = dark.withOpacity(0.25)..strokeWidth = 10..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    if (colored) {
      // Eyes
      oval(canvas, 48, 44, 8, 8, Colors.white); oval(canvas, 76, 44, 8, 8, Colors.white);
      oval(canvas, 50, 44, 5, 5, const Color(0xFF1A0A30)); oval(canvas, 78, 44, 5, 5, const Color(0xFF1A0A30));
      canvas.drawCircle(const Offset(51.5, 42), 2, Paint()..color = Colors.white);
      canvas.drawCircle(const Offset(79.5, 42), 2, Paint()..color = Colors.white);
      // Tusk
      canvas.save(); canvas.translate(52, 72); canvas.rotate(-25 * pi / 180);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 14, height: 6), Paint()..color = Colors.white);
      canvas.restore();
      // Smile
      canvas.drawPath(Path()..moveTo(48,68)..quadraticBezierTo(62,78,76,68),
          Paint()..color = dark..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    }
    // Legs
    rrect(canvas, 18, 128, 22, 16, 11, body); rrect(canvas, 44, 132, 22, 12, 11, body); rrect(canvas, 70, 132, 22, 12, 11, body);
    // Tail
    canvas.drawPath(Path()..moveTo(108,96)..quadraticBezierTo(118,82,112,70),
        Paint()..color = body..strokeWidth = 5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawCircle(const Offset(111, 68), 6, Paint()..color = dark);
  }

  @override
  bool shouldRepaint(ElephantPainter o) => o.colored != colored;
}

// ── GIRAFFE PAINTER ──
class GiraffePainter extends CustomPainter {
  final bool colored;
  const GiraffePainter({required this.colored});

  static const sil = Color(0xFFC0B8D8);

  void oval(Canvas c, double cx, double cy, double rx, double ry, Color col,
      {double op = 1, double rot = 0}) {
    if (rot != 0) {
      c.save(); c.translate(cx, cy); c.rotate(rot * pi / 180);
      c.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), Paint()..color = col.withOpacity(op));
      c.restore();
    } else {
      c.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), Paint()..color = col.withOpacity(op));
    }
  }

  void rrect(Canvas c, double x, double y, double w, double h, double r, Color col) {
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)), Paint()..color = col);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final body  = colored ? const Color(0xFFFFD93D) : sil;
    final spots = colored ? const Color(0xFFE07820) : sil;
    final dark  = colored ? const Color(0xFFC05808) : sil;
    final snout = colored ? const Color(0xFFF5C68A) : sil;
    final pink  = colored ? const Color(0xFFF8A5C2) : sil;

    // Body
    oval(canvas, 48, 114, 34, 30, body);
    // Neck
    rrect(canvas, 34, 34, 24, 86, 12, body);
    // Head
    oval(canvas, 46, 26, 24, 18, body);
    // Snout
    oval(canvas, 60, 30, 16, 11, snout);
    // Ears
    oval(canvas, 27, 14, 9, 14, body, rot: -20);
    if (colored) oval(canvas, 27, 14, 5, 8, pink, rot: -20);
    oval(canvas, 60, 12, 9, 14, body, rot: 20);
    if (colored) oval(canvas, 60, 12, 5, 8, pink, rot: 20);
    // Horns
    rrect(canvas, 24, 2, 6, 16, 3, dark); canvas.drawCircle(const Offset(27, 2), 5, Paint()..color = dark);
    rrect(canvas, 56, 0, 6, 16, 3, dark); canvas.drawCircle(const Offset(59, 0), 5, Paint()..color = dark);
    if (colored) {
      // Spots neck
      oval(canvas, 44, 58, 7, 9, spots, op: 0.8); oval(canvas, 46, 82, 6, 8, spots, op: 0.8);
      oval(canvas, 44, 104, 8, 6, spots, op: 0.75);
      // Spots body
      oval(canvas, 34, 106, 9, 7, spots, op: 0.7); oval(canvas, 60, 118, 8, 6, spots, op: 0.7);
      oval(canvas, 36, 124, 6, 5, spots, op: 0.65);
      // Eye
      oval(canvas, 40, 23, 5.5, 5.5, Colors.white);
      oval(canvas, 42, 23, 3.5, 3.5, const Color(0xFF1A0A30));
      canvas.drawCircle(const Offset(43.5, 21), 1.4, Paint()..color = Colors.white);
      // Nostrils
      oval(canvas, 65, 33, 3, 2.5, dark); oval(canvas, 70, 32, 3, 2.5, dark);
      // Smile
      canvas.drawPath(Path()..moveTo(56,37)..quadraticBezierTo(63,43,70,37),
          Paint()..color = dark..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    }
    // Legs
    for (final d in [[18.0,138.0,13.0,22.0],[34.0,140.0,13.0,20.0],[52.0,140.0,13.0,20.0],[68.0,138.0,13.0,22.0]]) {
      rrect(canvas, d[0], d[1], d[2], d[3], 6.5, body);
    }
    if (colored) {
      for (final d in [[18.0,157.0],[34.0,157.0],[52.0,157.0],[68.0,157.0]]) {
        rrect(canvas, d[0], d[1], 13, 5, 3, dark);
      }
    }
    // Tail
    canvas.drawPath(Path()..moveTo(80,108)..quadraticBezierTo(88,94,84,80),
        Paint()..color = body..strokeWidth = 5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawCircle(const Offset(83, 78), 7, Paint()..color = spots);
  }

  @override
  bool shouldRepaint(GiraffePainter o) => o.colored != colored;
}
