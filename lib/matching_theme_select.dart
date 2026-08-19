import 'dart:math';
import 'package:flutter/material.dart';
import 'matching_game.dart';
import 'package:hippolulu/l10n/app_localizations.dart';

// ─────────────────────────────────────────────
//  THEME DATA
// ─────────────────────────────────────────────
class _ThemeData {
  final MatchingTheme id;
  final String label, emoji, desc;
  final List<String> emojis;
  final List<Color> gradientColors;
  final Color shadow, border;

  const _ThemeData({
    required this.id,
    required this.label,
    required this.emoji,
    required this.desc,
    required this.emojis,
    required this.gradientColors,
    required this.shadow,
    required this.border,
  });
}

List<_ThemeData> matchingThemes(AppLocalizations l10n) => [
      _ThemeData(
        id: MatchingTheme.animals,
        label: l10n.matchingAnimals,
        emoji: 'animals/lion.webp',
        desc: l10n.matchingAnimalsDesc,
        emojis: [
          'animals/lion.webp',
          'animals/cat.webp',
          'animals/giraffe.webp'
        ],
        gradientColors: const [Color(0xFFFFCE7A), Color(0xFFFF9940)],
        shadow: const Color(0xFFC05000),
        border: const Color(0xFFFFD250).withValues(alpha: 0.6),
      ),
      _ThemeData(
        id: MatchingTheme.fruits,
        label: l10n.matchingFruits,
        emoji: 'fruits/apple.webp',
        desc: l10n.matchingFruitsDesc,
        emojis: [
          'fruits/apple.webp',
          'fruits/banana.webp',
          'fruits/orange.webp'
        ],
        gradientColors: const [Color(0xFFFFB2D1), Color(0xFFE85B93)],
        shadow: const Color(0xFFB02A60),
        border: const Color(0xFFFFC4DD).withValues(alpha: 0.6),
      ),
      _ThemeData(
        id: MatchingTheme.vegetables,
        label: l10n.matchingVegetables,
        emoji: 'vegetables/carrot.webp',
        desc: l10n.matchingVegetablesDesc,
        emojis: [
          'vegetables/carrot.webp',
          'vegetables/tomato.webp',
          'vegetables/cucumber.webp',
        ],
        gradientColors: const [Color(0xFF76D7C4), Color(0xFF1ABC9C)],
        shadow: const Color(0xFF117A65),
        border: const Color(0xFF8CE4D3).withValues(alpha: 0.6),
      ),
      _ThemeData(
        id: MatchingTheme.vehicles,
        label: l10n.matchingVehicles,
        emoji: 'vehicles/car.webp',
        desc: l10n.matchingVehiclesDesc,
        emojis: [
          'vehicles/car.webp',
          'vehicles/airplane.webp',
          'vehicles/train.webp'
        ],
        gradientColors: const [Color(0xFF90D0FF), Color(0xFF3A9EE0)],
        shadow: const Color(0xFF1A60B0),
        border: const Color(0xFF64BEFF).withValues(alpha: 0.6),
      ),
      _ThemeData(
        id: MatchingTheme.foods,
        label: l10n.matchingFoods,
        emoji: 'foods/bread.webp',
        desc: l10n.matchingFoodsDesc,
        emojis: ['foods/bread.webp', 'foods/cheese.webp', 'foods/pizza.webp'],
        gradientColors: const [Color(0xFFFFF176), Color(0xFFFBC02D)],
        shadow: const Color(0xFFB88600),
        border: const Color(0xFFFFF59D).withValues(alpha: 0.6),
      ),
      _ThemeData(
        id: MatchingTheme.objects,
        label: l10n.matchingObjects,
        emoji: '🎁',
        desc: l10n.matchingObjectsDesc,
        emojis: ['🍎', '⭐', '🎈'],
        gradientColors: const [Color(0xFFD4B8F8), Color(0xFF9E78D8)],
        shadow: const Color(0xFF6040B8),
        border: const Color(0xFFC4A8F0).withValues(alpha: 0.6),
      ),
    ];

// ─────────────────────────────────────────────
//  MATCHING THEME SELECT SCREEN
// ─────────────────────────────────────────────
class MatchingThemeSelect extends StatelessWidget {
  final VoidCallback onBack;
  final void Function(MatchingTheme) onSelect;

  const MatchingThemeSelect({
    super.key,
    required this.onBack,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themes = matchingThemes(l10n);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: SceneBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Padding(
                  padding: EdgeInsets.fromLTRB(20, isLandscape ? 5 : 20, 20, 0),
                  child: _TitleSection(l10n: l10n, isLandscape: isLandscape),
                ),

                // ── HOW TO PLAY BANNER ──
                Padding(
                  padding: EdgeInsets.fromLTRB(20, isLandscape ? 5 : 14, 20, 0),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        16, isLandscape ? 8 : 12, 16, isLandscape ? 8 : 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7), width: 2),
                    ),
                    child: Row(
                      children: [
                        Text('👀',
                            style: TextStyle(fontSize: isLandscape ? 20 : 28)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Fredoka Bold',
                                fontSize: isLandscape ? 11 : 13,
                                color: const Color(0xFF5C28A0),
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(text: l10n.howToPlayPart1),
                                TextSpan(
                                  text: l10n.howToPlayHighlight,
                                  style:
                                      const TextStyle(color: Color(0xFFFF5500)),
                                ),
                                TextSpan(text: l10n.howToPlayPart2),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── THEME CARDS ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWide = constraints.maxWidth > 500;
                      return Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: themes.map((t) {
                          return SizedBox(
                            width: isWide
                                ? (constraints.maxWidth - 14) / 2
                                : constraints.maxWidth,
                            child: _ThemeCard(
                              theme: t,
                              moreLabel: l10n.moreLabel,
                              onTap: () => onSelect(t.id),
                            ),
                          );
                        }).toList(),
                      );
                    },
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
                  offset: const Offset(0, 4))
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
                      fontFamily: 'Fredoka Bold',
                      fontSize: 19,
                      color: Color(0xFF5C28A0))),
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
  final AppLocalizations l10n;
  final bool isLandscape;

  const _TitleSection({required this.l10n, this.isLandscape = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: isLandscape ? 0 : 6),
        Text(l10n.matchingGameTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka Bold',
              fontSize: isLandscape ? 26 : 34,
              color: const Color(0xFF5C28A0),
              shadows: const [
                Shadow(color: Color(0xFFD0A8F0), offset: Offset(0, 4))
              ],
            )),
        SizedBox(height: isLandscape ? 0 : 4),
        Text(l10n.pickCategoryToMatch,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isLandscape ? 13 : 15,
              color: const Color(0xFF7854B8),
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  THEME CARD
// ─────────────────────────────────────────────
class _ThemeCard extends StatefulWidget {
  final _ThemeData theme;
  final String moreLabel;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.moreLabel,
    required this.onTap,
  });
  @override
  State<_ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<_ThemeCard> {
  double _scale = 1.0, _pressY = 0;
  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return GestureDetector(
      onTapDown: (_) => setState(() {
        _scale = 0.94;
        _pressY = 4;
      }),
      onTapUp: (_) {
        setState(() {
          _scale = 1.0;
          _pressY = 0;
        });
        widget.onTap();
      },
      onTapCancel: () => setState(() {
        _scale = 1.0;
        _pressY = 0;
      }),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: AnimatedSlide(
          offset: Offset(0, _pressY / 300),
          duration: const Duration(milliseconds: 100),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: t.gradientColors,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: t.border, width: 3),
              boxShadow: [
                BoxShadow(color: t.shadow, offset: const Offset(0, 7)),
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    offset: const Offset(0, 12),
                    blurRadius: 26),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                children: [
                  // Glare
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.38),
                            Colors.white.withValues(alpha: 0)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                    child: Row(
                      children: [
                        // Big emoji circle
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3))
                            ],
                          ),
                          child: Center(
                              child: t.emoji.endsWith('.webp') ||
                                      t.emoji.endsWith('.png')
                                  ? Image.asset(
                                      t.emoji.startsWith('assets/')
                                          ? t.emoji
                                          : (t.emoji.startsWith('matching/')
                                              ? 'assets/images/${t.emoji}'
                                              : 'assets/images/matching/${t.emoji}'),
                                      width: 42,
                                      height: 42)
                                  : Text(t.emoji,
                                      style: const TextStyle(fontSize: 36))),
                        ),
                        const SizedBox(width: 16),
                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.label,
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka Bold',
                                    fontSize: 24,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                          color: Color(0x2E000000),
                                          offset: Offset(0, 2),
                                          blurRadius: 6)
                                    ],
                                  )),
                              const SizedBox(height: 3),
                              Text(t.desc,
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w500,
                                  )),
                              const SizedBox(height: 6),
                              // Sample emojis
                              Row(
                                children: [
                                  ...t.emojis.map((e) => Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.28),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: e.endsWith('.webp') ||
                                                e.endsWith('.png')
                                            ? Image.asset(
                                                e.startsWith('assets/')
                                                    ? e
                                                    : (e.startsWith('matching/')
                                                        ? 'assets/images/$e'
                                                        : 'assets/images/matching/$e'),
                                                width: 22,
                                                height: 22)
                                            : Text(e,
                                                style: const TextStyle(
                                                    fontSize: 20)),
                                      )),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.28),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(widget.moreLabel,
                                        style: const TextStyle(
                                          fontFamily: 'Fredoka',
                                          fontSize: 13,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Arrow
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chevron_right_rounded,
                              size: 20, color: Colors.white),
                        ),
                      ],
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

// ─────────────────────────────────────────────
//  SCENE BACKGROUND (shared)
// ─────────────────────────────────────────────
class SceneBackground extends StatelessWidget {
  final Widget child;
  const SceneBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
            Color(0xFFB0E8A8)
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
                  height: MediaQuery.of(context).size.height * 0.60,
                  child: CustomPaint(painter: _SkyPainter()))),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.28,
                  child: CustomPaint(painter: _HillsPainter()))),
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
      void e(double ex, double ey, double rx, double ry) => canvas.drawOval(
          Rect.fromCenter(
              center: Offset((cx + ex) * sx, (cy + ey) * sy),
              width: rx * 2 * sx * sc,
              height: ry * 2 * sy * sc),
          p);
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
    void e(double cx, double cy, double rx, double ry, Color c) =>
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx * sx, cy * sy),
                width: rx * 2 * sx,
                height: ry * 2 * sy),
            Paint()..color = c);
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
      final x = [22.0, 68, 118, 175, 235, 295, 348][i] * sx,
          y = (138 + (i % 3) * 6) * sy;
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
