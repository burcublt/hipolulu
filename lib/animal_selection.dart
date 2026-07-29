import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  ANIMAL ID
// ─────────────────────────────────────────────
enum AnimalId { lion, elephant, giraffe, tiger, penguin, rabbit }

// ─────────────────────────────────────────────
//  ANIMAL DATA
// ─────────────────────────────────────────────
class AnimalData {
  final AnimalId id;
  final String name;
  final String emoji;
  final List<Color> gradientColors;
  final Color shadow;
  final Color border;
  final int stars;
  final bool locked;

  const AnimalData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.gradientColors,
    required this.shadow,
    required this.border,
    required this.stars,
    required this.locked,
  });
}

final List<AnimalData> kAnimals = [
  AnimalData(
    id: AnimalId.lion,
    name: 'Lion',
    emoji: '🦁',
    gradientColors: const [Color(0xFFFFCE7A), Color(0xFFFF9940)],
    shadow: const Color(0xFFC05000),
    border: const Color(0xFFFFD250).withValues(alpha: 0.6),
    stars: 0,
    locked: false,
  ),
  AnimalData(
    id: AnimalId.elephant,
    name: 'Elephant',
    emoji: '🐘',
    gradientColors: const [Color(0xFF90D0FF), Color(0xFF3A9EE0)],
    shadow: const Color(0xFF1A60B0),
    border: const Color(0xFF64BEFF).withValues(alpha: 0.6),
    stars: 0,
    locked: false,
  ),
  AnimalData(
    id: AnimalId.giraffe,
    name: 'Giraffe',
    emoji: '🦒',
    gradientColors: const [Color(0xFFFFF075), Color(0xFFFFD020)],
    shadow: const Color(0xFFB07000),
    border: const Color(0xFFFFE632).withValues(alpha: 0.6),
    stars: 0,
    locked: false,
  ),
  AnimalData(
    id: AnimalId.tiger,
    name: 'Tiger',
    emoji: '🐯',
    gradientColors: const [Color(0xFFFFB060), Color(0xFFFF7020)],
    shadow: const Color(0xFFA04000),
    border: const Color(0xFFFFA050).withValues(alpha: 0.5),
    stars: 0,
    locked: true,
  ),
  AnimalData(
    id: AnimalId.penguin,
    name: 'Penguin',
    emoji: '🐧',
    gradientColors: const [Color(0xFFB0C8F8), Color(0xFF6090E0)],
    shadow: const Color(0xFF2050A0),
    border: const Color(0xFF8CB4F0).withValues(alpha: 0.5),
    stars: 0,
    locked: true,
  ),
  AnimalData(
    id: AnimalId.rabbit,
    name: 'Rabbit',
    emoji: '🐰',
    gradientColors: const [Color(0xFFF8C0E8), Color(0xFFE070C0)],
    shadow: const Color(0xFFA02080),
    border: const Color(0xFFF0A0DC).withValues(alpha: 0.5),
    stars: 0,
    locked: true,
  ),
];

// ─────────────────────────────────────────────
//  ANIMAL SELECTION SCREEN
// ─────────────────────────────────────────────
class AnimalSelection extends StatelessWidget {
  final VoidCallback onBack;
  final void Function(AnimalId) onSelect;

  const AnimalSelection({
    super.key,
    required this.onBack,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SceneBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── TOP BAR ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _BackButton(onTap: onBack),
                ),
              ),

              // ── TITLE ──
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: _TitleSection(),
              ),

              // ── GRID ──
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: kAnimals.length,
                  itemBuilder: (ctx, i) => _AnimalCard(
                    animal: kAnimals[i],
                    index: i,
                    onTap: kAnimals[i].locked
                        ? null
                        : () => onSelect(kAnimals[i].id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chevron_left_rounded,
                  size: 24, color: Color(0xFF5C28A0)),
              SizedBox(width: 2),
              Text('Back',
                  style: TextStyle(
                    fontFamily: 'Fredoka Bold',
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
//  TITLE SECTION
// ─────────────────────────────────────────────
class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Pick an Animal! 🐾',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Fredoka Bold',
            fontSize: 34,
            height: 1,
            color: Color(0xFF5C28A0),
            shadows: [Shadow(color: Color(0xFFD0A8F0), offset: Offset(0, 4))],
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Choose your puzzle buddy',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 15,
            color: Color(0xFF7854B8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  ANIMAL CARD
// ─────────────────────────────────────────────
class _AnimalCard extends StatefulWidget {
  final AnimalData animal;
  final int index;
  final VoidCallback? onTap;

  const _AnimalCard({
    required this.animal,
    required this.index,
    this.onTap,
  });

  @override
  State<_AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends State<_AnimalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ribbonCtrl;
  double _scale = 1.0;
  double _pressY = 0;

  @override
  void initState() {
    super.initState();
    _ribbonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (!widget.animal.locked) _ribbonCtrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ribbonCtrl.dispose();
    super.dispose();
  }

  Widget _buildIllustration(AnimalId id, bool locked) {
    final opacity = locked ? 0.6 : 1.0;
    switch (id) {
      case AnimalId.lion:
        return Opacity(opacity: opacity, child: const LionWidget());
      case AnimalId.elephant:
        return Opacity(opacity: opacity, child: const ElephantWidget());
      case AnimalId.giraffe:
        return Opacity(opacity: opacity, child: const GiraffeWidget());
      default:
        // Locked animals: show emoji
        return ColorFiltered(
          colorFilter: locked
              ? const ColorFilter.matrix([
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ])
              : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
          child:
              Text(widget.animal.emoji, style: const TextStyle(fontSize: 52)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.animal;
    const lockedGrad = [Color(0xFFDDD8F0), Color(0xFFC4BDE4)];

    return GestureDetector(
      onTapDown: a.locked
          ? null
          : (_) => setState(() {
                _scale = 0.93;
                _pressY = 4;
              }),
      onTapUp: a.locked
          ? null
          : (_) {
              setState(() {
                _scale = 1.0;
                _pressY = 0;
              });
              widget.onTap?.call();
            },
      onTapCancel: a.locked
          ? null
          : () => setState(() {
                _scale = 1.0;
                _pressY = 0;
              }),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: AnimatedSlide(
          offset: Offset(0, _pressY / 300),
          duration: const Duration(milliseconds: 100),
          child: Opacity(
            opacity: a.locked ? 0.62 : 1.0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── CARD ──
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: a.locked ? lockedGrad : a.gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: a.locked
                          ? Colors.white.withValues(alpha: 0.4)
                          : a.border,
                      width: 3,
                    ),
                    boxShadow: a.locked
                        ? [
                            const BoxShadow(
                                color: Color(0xFFA8A0CC), offset: Offset(0, 6)),
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                offset: const Offset(0, 8),
                                blurRadius: 18),
                          ]
                        : [
                            BoxShadow(
                                color: a.shadow, offset: const Offset(0, 7)),
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                offset: const Offset(0, 12),
                                blurRadius: 24),
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glare
                        if (!a.locked)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 70,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.42),
                                    Colors.white.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animal illustration
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Center(
                                    child: _buildIllustration(a.id, a.locked)),
                              ),
                              const SizedBox(height: 6),

                              // Name
                              Text(
                                a.name,
                                style: TextStyle(
                                  fontFamily: 'Fredoka Bold',
                                  fontSize: 18,
                                  color: a.locked
                                      ? const Color(0xFF8878B8)
                                      : Colors.white,
                                  shadows: a.locked
                                      ? null
                                      : const [
                                          Shadow(
                                              color: Color(0x2E000000),
                                              offset: Offset(0, 2),
                                              blurRadius: 4)
                                        ],
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Stars or Lock
                              if (a.locked)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.lock_rounded,
                                          size: 11, color: Color(0xFF7868A8)),
                                      SizedBox(width: 4),
                                      Text('Locked',
                                          style: TextStyle(
                                            fontFamily: 'Fredoka',
                                            fontSize: 11,
                                            color: Color(0xFF7868A8),
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ],
                                  ),
                                )
                              else
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                      3,
                                      (idx) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 1.5),
                                            child: Icon(
                                              Icons.star_rounded,
                                              size: 14,
                                              color: idx < a.stars
                                                  ? const Color(0xFFFFD93D)
                                                  : Colors.white
                                                      .withValues(alpha: 0.4),
                                            ),
                                          )),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── PLAY! RIBBON ──
                if (!a.locked)
                  Positioned(
                    top: -8,
                    right: -4,
                    child: AnimatedBuilder(
                      animation: _ribbonCtrl,
                      builder: (_, child) {
                        final angle = (-3 + 6 * _ribbonCtrl.value) * pi / 180;
                        final dy = -_ribbonCtrl.value;
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: Transform.rotate(angle: angle, child: child),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF4444), Color(0xFFDD0000)],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC80000)
                                  .withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Text(
                          'PLAY!',
                          style: TextStyle(
                            fontFamily: 'Fredoka Bold',
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

// ─────────────────────────────────────────────
//  ANIMAL WIDGETS (SVG → CustomPainter)
// ─────────────────────────────────────────────

// ── LION ──
class LionWidget extends StatelessWidget {
  const LionWidget({super.key});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _LionPainter(), size: const Size(62, 79));
}

class _LionPainter extends CustomPainter {
  // viewBox: 0 0 110 140  →  62 x 79
  static const double vw = 110, vh = 140, tw = 62, th = 79;
  Offset p(double x, double y) => Offset(x / vw * tw, y / vh * th);
  double sx(double v) => v / vw * tw;
  double sy(double v) => v / vh * th;

  void oval(Canvas c, double cx, double cy, double rx, double ry, Color col,
      {double op = 1}) {
    c.drawOval(
        Rect.fromCenter(
            center: p(cx, cy), width: sx(rx * 2), height: sy(ry * 2)),
        Paint()..color = col.withValues(alpha: op));
  }

  void rrect(
      Canvas c, double x, double y, double w, double h, double r, Color col) {
    c.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(p(x, y).dx, p(x, y).dy, sx(w), sy(h)),
          Radius.circular(sx(r))),
      Paint()..color = col,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    const mane = Color(0xFFE67E22);
    const head = Color(0xFFF5A623);
    const snout = Color(0xFFFCD5A0);
    const accent = Color(0xFFC0590A);
    const pink = Color(0xFFF8A5C2);

    // Mane
    oval(canvas, 55, 52, 40, 40, mane);
    // Head
    oval(canvas, 55, 52, 29, 29, head);
    // Ears
    oval(canvas, 30, 28, 11, 11, head);
    oval(canvas, 80, 28, 11, 11, head);
    oval(canvas, 30, 28, 6, 6, pink);
    oval(canvas, 80, 28, 6, 6, pink);
    // Snout
    oval(canvas, 55, 64, 17, 12, snout);
    // Eyes
    oval(canvas, 42, 46, 7, 7, Colors.white);
    oval(canvas, 68, 46, 7, 7, Colors.white);
    oval(canvas, 44, 46, 4.5, 4.5, const Color(0xFF1A0A30));
    oval(canvas, 70, 46, 4.5, 4.5, const Color(0xFF1A0A30));
    canvas.drawCircle(p(45.5, 44), sx(1.8), Paint()..color = Colors.white);
    canvas.drawCircle(p(71.5, 44), sx(1.8), Paint()..color = Colors.white);
    // Nose
    oval(canvas, 55, 61, 5, 4, accent);
    // Whisker dots
    for (final d in [
      [40.0, 67.0],
      [45.0, 70.0],
      [65.0, 67.0],
      [70.0, 70.0]
    ]) {
      canvas.drawCircle(p(d[0], d[1]), sx(1.5),
          Paint()..color = accent.withValues(alpha: 0.6));
    }
    // Smile
    canvas.drawPath(
      Path()
        ..moveTo(p(43, 72).dx, p(43, 72).dy)
        ..quadraticBezierTo(
            p(55, 82).dx, p(55, 82).dy, p(67, 72).dx, p(67, 72).dy),
      Paint()
        ..color = accent
        ..strokeWidth = sx(2.5)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    // Body
    oval(canvas, 55, 112, 30, 26, head);
    // Legs
    rrect(canvas, 24, 122, 18, 24, 9, head);
    rrect(canvas, 68, 122, 18, 24, 9, head);
    // Tail
    canvas.drawPath(
      Path()
        ..moveTo(p(83, 104).dx, p(83, 104).dy)
        ..quadraticBezierTo(
            p(100, 86).dx, p(100, 86).dy, p(94, 66).dx, p(94, 66).dy),
      Paint()
        ..color = head
        ..strokeWidth = sx(6)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(p(93, 63), sx(8), Paint()..color = mane);
  }

  @override
  bool shouldRepaint(_LionPainter o) => false;
}

// ── ELEPHANT ──
class ElephantWidget extends StatelessWidget {
  const ElephantWidget({super.key});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ElephantPainter(), size: const Size(62, 72));
}

class _ElephantPainter extends CustomPainter {
  // viewBox: 0 0 120 140  → scaled to 62 x 72
  static const double vw = 120, vh = 140, tw = 62, th = 72;
  Offset p(double x, double y) => Offset(x / vw * tw, y / vh * th);
  double sx(double v) => v / vw * tw;
  double sy(double v) => v / vh * th;

  void oval(Canvas c, double cx, double cy, double rx, double ry, Color col,
      {double op = 1}) {
    c.drawOval(
        Rect.fromCenter(
            center: p(cx, cy), width: sx(rx * 2), height: sy(ry * 2)),
        Paint()..color = col.withValues(alpha: op));
  }

  void rrect(
      Canvas c, double x, double y, double w, double h, double r, Color col) {
    c.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(p(x, y).dx, p(x, y).dy, sx(w), sy(h)),
          Radius.circular(sx(r))),
      Paint()..color = col,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    const body = Color(0xFF5DADE2);
    const dark = Color(0xFF4090C8);
    const light = Color(0xFFA8D8F8);
    const pink = Color(0xFFF8A5C2);

    // Body
    oval(canvas, 62, 104, 48, 34, body);
    // Ears
    oval(canvas, 14, 55, 20, 28, dark);
    oval(canvas, 110, 55, 20, 28, dark);
    oval(canvas, 14, 55, 11, 17, pink, op: 0.45);
    oval(canvas, 110, 55, 11, 17, pink, op: 0.45);
    // Head
    oval(canvas, 62, 52, 36, 36, body);
    // Head highlight
    oval(canvas, 58, 38, 22, 16, light, op: 0.4);
    // Trunk
    canvas.drawPath(
      Path()
        ..moveTo(p(50, 78).dx, p(50, 78).dy)
        ..quadraticBezierTo(
            p(34, 96).dx, p(34, 96).dy, p(40, 118).dx, p(40, 118).dy)
        ..quadraticBezierTo(
            p(44, 128).dx, p(44, 128).dy, p(54, 124).dx, p(54, 124).dy),
      Paint()
        ..color = body
        ..strokeWidth = sx(16)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(p(50, 78).dx, p(50, 78).dy)
        ..quadraticBezierTo(
            p(34, 96).dx, p(34, 96).dy, p(40, 118).dx, p(40, 118).dy)
        ..quadraticBezierTo(
            p(44, 128).dx, p(44, 128).dy, p(54, 124).dx, p(54, 124).dy),
      Paint()
        ..color = dark.withValues(alpha: 0.25)
        ..strokeWidth = sx(10)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    // Eyes
    oval(canvas, 48, 44, 8, 8, Colors.white);
    oval(canvas, 76, 44, 8, 8, Colors.white);
    oval(canvas, 50, 44, 5, 5, const Color(0xFF1A0A30));
    oval(canvas, 78, 44, 5, 5, const Color(0xFF1A0A30));
    canvas.drawCircle(p(51.5, 42), sx(2), Paint()..color = Colors.white);
    canvas.drawCircle(p(79.5, 42), sx(2), Paint()..color = Colors.white);
    // Tusk
    canvas.save();
    canvas.translate(p(52, 72).dx, p(52, 72).dy);
    canvas.rotate(-25 * pi / 180);
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: sx(14), height: sy(6)),
        Paint()..color = Colors.white);
    canvas.restore();
    // Smile
    canvas.drawPath(
      Path()
        ..moveTo(p(48, 68).dx, p(48, 68).dy)
        ..quadraticBezierTo(
            p(62, 78).dx, p(62, 78).dy, p(76, 68).dx, p(76, 68).dy),
      Paint()
        ..color = dark
        ..strokeWidth = sx(2.5)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    // Legs
    rrect(canvas, 18, 128, 22, 16, 11, body);
    rrect(canvas, 44, 132, 22, 12, 11, body);
    rrect(canvas, 70, 132, 22, 12, 11, body);
    // Tail
    canvas.drawPath(
      Path()
        ..moveTo(p(108, 96).dx, p(108, 96).dy)
        ..quadraticBezierTo(
            p(118, 82).dx, p(118, 82).dy, p(112, 70).dx, p(112, 70).dy),
      Paint()
        ..color = body
        ..strokeWidth = sx(5)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(p(111, 68), sx(6), Paint()..color = dark);
  }

  @override
  bool shouldRepaint(_ElephantPainter o) => false;
}

// ── GIRAFFE ──
class GiraffeWidget extends StatelessWidget {
  const GiraffeWidget({super.key});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GiraffePainter(), size: const Size(52, 90));
}

class _GiraffePainter extends CustomPainter {
  // viewBox: 0 0 90 155  → scaled to 52 x 90
  static const double vw = 90, vh = 155, tw = 52, th = 90;
  Offset p(double x, double y) => Offset(x / vw * tw, y / vh * th);
  double sx(double v) => v / vw * tw;
  double sy(double v) => v / vh * th;

  void oval(Canvas c, double cx, double cy, double rx, double ry, Color col,
      {double op = 1, double rot = 0}) {
    if (rot != 0) {
      c.save();
      c.translate(p(cx, cy).dx, p(cx, cy).dy);
      c.rotate(rot * pi / 180);
      c.drawOval(
          Rect.fromCenter(
              center: Offset.zero, width: sx(rx * 2), height: sy(ry * 2)),
          Paint()..color = col.withValues(alpha: op));
      c.restore();
    } else {
      c.drawOval(
          Rect.fromCenter(
              center: p(cx, cy), width: sx(rx * 2), height: sy(ry * 2)),
          Paint()..color = col.withValues(alpha: op));
    }
  }

  void rrect(
      Canvas c, double x, double y, double w, double h, double r, Color col) {
    c.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(p(x, y).dx, p(x, y).dy, sx(w), sy(h)),
          Radius.circular(sx(r))),
      Paint()..color = col,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    const body = Color(0xFFFFD93D);
    const spots = Color(0xFFE07820);
    const dark = Color(0xFFC05808);
    const snout = Color(0xFFF5C68A);
    const pink = Color(0xFFF8A5C2);

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
    oval(canvas, 27, 14, 5, 8, pink, rot: -20);
    oval(canvas, 60, 12, 9, 14, body, rot: 20);
    oval(canvas, 60, 12, 5, 8, pink, rot: 20);
    // Horns
    rrect(canvas, 24, 2, 6, 16, 3, dark);
    canvas.drawCircle(p(27, 2), sx(5), Paint()..color = dark);
    rrect(canvas, 56, 0, 6, 16, 3, dark);
    canvas.drawCircle(p(59, 0), sx(5), Paint()..color = dark);
    // Spots on neck
    oval(canvas, 44, 58, 7, 9, spots, op: 0.8);
    oval(canvas, 46, 82, 6, 8, spots, op: 0.8);
    oval(canvas, 44, 104, 8, 6, spots, op: 0.75);
    // Spots on body
    oval(canvas, 34, 106, 9, 7, spots, op: 0.7);
    oval(canvas, 60, 118, 8, 6, spots, op: 0.7);
    oval(canvas, 36, 124, 6, 5, spots, op: 0.65);
    // Eye
    oval(canvas, 40, 23, 5.5, 5.5, Colors.white);
    oval(canvas, 42, 23, 3.5, 3.5, const Color(0xFF1A0A30));
    canvas.drawCircle(p(43.5, 21), sx(1.4), Paint()..color = Colors.white);
    // Nostrils
    oval(canvas, 65, 33, 3, 2.5, dark);
    oval(canvas, 70, 32, 3, 2.5, dark);
    // Smile
    canvas.drawPath(
      Path()
        ..moveTo(p(56, 37).dx, p(56, 37).dy)
        ..quadraticBezierTo(
            p(63, 43).dx, p(63, 43).dy, p(70, 37).dx, p(70, 37).dy),
      Paint()
        ..color = dark
        ..strokeWidth = sx(2)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    // Legs
    for (final d in [
      [18.0, 138.0, 13.0, 22.0],
      [34.0, 140.0, 13.0, 20.0],
      [52.0, 140.0, 13.0, 20.0],
      [68.0, 138.0, 13.0, 22.0]
    ]) {
      rrect(canvas, d[0], d[1], d[2], d[3], 6.5, body);
    }
    // Hooves
    for (final d in [
      [18.0, 157.0],
      [34.0, 157.0],
      [52.0, 157.0],
      [68.0, 157.0]
    ]) {
      rrect(canvas, d[0], d[1], 13, 5, 3, dark);
    }
    // Tail
    canvas.drawPath(
      Path()
        ..moveTo(p(80, 108).dx, p(80, 108).dy)
        ..quadraticBezierTo(
            p(88, 94).dx, p(88, 94).dy, p(84, 80).dx, p(84, 80).dy),
      Paint()
        ..color = body
        ..strokeWidth = sx(5)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(p(83, 78), sx(7), Paint()..color = spots);
  }

  @override
  bool shouldRepaint(_GiraffePainter o) => false;
}

// ─────────────────────────────────────────────
//  SCENE BACKGROUND
// ─────────────────────────────────────────────
class SceneBackground extends StatelessWidget {
  final Widget child;
  const SceneBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.3, 0.55, 0.78, 1.0],
          colors: [
            Color(0xFF72D8F5),
            Color(0xFF9EE8F8),
            Color(0xFFB8F0FA),
            Color(0xFFCAF5E8),
            Color(0xFFB0E8A8),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: CustomPaint(painter: _SkyPainter()),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              child: CustomPaint(painter: _HillsPainter()),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 390, sy = size.height / 320;
    canvas.drawCircle(Offset(352 * sx, 52 * sy), 38 * sx,
        Paint()..color = const Color(0xFFFFE566).withValues(alpha: 0.9));
    canvas.drawCircle(Offset(352 * sx, 52 * sy), 30 * sx,
        Paint()..color = const Color(0xFFFFD93D));
    final rp = Paint()
      ..color = const Color(0xFFFFC300).withValues(alpha: 0.8)
      ..strokeWidth = 5 * sx
      ..strokeCap = StrokeCap.round;
    for (final d in [0, 40, 80, 120, 160, 200, 240, 280, 320]) {
      final r = d * pi / 180;
      canvas.drawLine(
          Offset(352 * sx + cos(r) * 42 * sx, 52 * sy + sin(r) * 42 * sy),
          Offset(352 * sx + cos(r) * 56 * sx, 52 * sy + sin(r) * 56 * sy),
          rp);
    }
    void cloud(double cx, double cy, double sc, double op) {
      final p = Paint()..color = Colors.white.withValues(alpha: op);
      void e(double ex, double ey, double rx, double ry) {
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset((cx + ex) * sx, (cy + ey) * sy),
                width: rx * 2 * sx * sc,
                height: ry * 2 * sy * sc),
            p);
      }

      e(0, 10, 34, 26);
      e(32, 2, 38, 30);
      e(70, 8, 30, 24);
      e(100, 14, 26, 20);
      e(52, 18, 54, 18);
    }

    cloud(-10, 40, 0.85, 0.95);
    cloud(200, 18, 0.70, 0.90);
    cloud(90, 100, 0.60, 0.80);
    cloud(270, 110, 0.55, 0.75);
    cloud(-20, 160, 0.50, 0.65);
    cloud(300, 190, 0.45, 0.60);
  }

  @override
  bool shouldRepaint(_SkyPainter o) => false;
}

class _HillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 390, sy = size.height / 200;
    void e(double cx, double cy, double rx, double ry, Color c) {
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx * sx, cy * sy),
              width: rx * 2 * sx,
              height: ry * 2 * sy),
          Paint()..color = c);
    }

    e(320, 170, 280, 120, const Color(0xFF6ABF62));
    e(80, 180, 260, 115, const Color(0xFF78CC70));
    e(230, 190, 300, 110, const Color(0xFF8AD880));
    canvas.drawRect(Rect.fromLTWH(0, 155 * sy, size.width, 45 * sy),
        Paint()..color = const Color(0xFF8AD880));
    final cols = [
      const Color(0xFFFFD93D),
      const Color(0xFFFF9F7F),
      const Color(0xFFF48FB1),
      const Color(0xFFA8D85C)
    ];
    for (int i = 0; i < [22.0, 68, 118, 175, 235, 295, 348].length; i++) {
      final x = [22.0, 68, 118, 175, 235, 295, 348][i] * sx;
      final y = (138 + (i % 3) * 6) * sy;
      canvas.drawCircle(Offset(x, y), 6 * sx, Paint()..color = cols[i % 4]);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(x, y + 7 * sy),
                  width: 3 * sx,
                  height: 10 * sy),
              const Radius.circular(2)),
          Paint()..color = const Color(0xFF5AAA50));
    }
  }

  @override
  bool shouldRepaint(_HillsPainter o) => false;
}
