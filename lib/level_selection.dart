import 'main.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hippolulu/l10n/app_localizations.dart';

// ─────────────────────────────────────────────
//  THEME DATA
// ─────────────────────────────────────────────
class PuzzleTheme {
  final String id;
  final String label;
  final String sublabel;
  final List<Color> gradientColors;
  final Color shadow;
  final Color border;
  final bool locked;
  final int stars;
  final Widget Function() illustration;

  PuzzleTheme({
    required this.id,
    required this.label,
    required this.sublabel,
    required this.gradientColors,
    required this.shadow,
    required this.border,
    required this.locked,
    required this.stars,
    required this.illustration,
  });
}

List<PuzzleTheme> puzzleThemes(AppLocalizations l10n) => [
      PuzzleTheme(
        id: 'animals',
        label: l10n.themeAnimals,
        sublabel: l10n.puzzlesCount(12),
        gradientColors: const [Color(0xFFFFCE7A), Color(0xFFFF9940)],
        shadow: const Color(0xFFD4650A),
        border: const Color(0xFFFFD264).withOpacity(0.6),
        locked: false,
        stars: 3,
        illustration: () => AnimalsIllustration(),
      ),
      PuzzleTheme(
        id: 'vehicles',
        label: l10n.themeVehicles,
        sublabel: l10n.puzzlesCount(12),
        gradientColors: const [Color(0xFF90D0FF), Color(0xFF4A9EE8)],
        shadow: const Color(0xFF2A6AB8),
        border: const Color(0xFF90D0FF).withOpacity(0.5),
        locked: true,
        stars: 0,
        illustration: () => VehiclesIllustration(),
      ),
      PuzzleTheme(
        id: 'shapes',
        label: l10n.themeShapes,
        sublabel: l10n.puzzlesCount(10),
        gradientColors: const [Color(0xFFD4B8F8), Color(0xFF9E78D8)],
        shadow: const Color(0xFF6840B8),
        border: const Color(0xFFC4A8F0).withOpacity(0.5),
        locked: true,
        stars: 0,
        illustration: () => ShapesIllustration(),
      ),
    ];

// ─────────────────────────────────────────────
//  LEVEL SELECTION SCREEN
// ─────────────────────────────────────────────
class LevelSelection extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSelect;

  LevelSelection({Key? key, required this.onBack, required this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themes = puzzleThemes(l10n);

    return Scaffold(
      body: SceneBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── TOP BAR ──
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _BackButton(onTap: onBack),
                ),
              ),

              // ── TITLE ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: _TitleSection(l10n: l10n),
              ),

              // ── CARDS ──
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(themes.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ThemeCard(
                          theme: themes[i],
                          index: i,
                          playNowLabel: l10n.playNow,
                          onTap: themes[i].locked ? null : onSelect,
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // ── FOOTER ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: _FooterHint(text: l10n.unlockAnimalsHint),
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
  _BackButton({required this.onTap});

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
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.fromLTRB(14, 10, 20, 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.68),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF643CC8).withOpacity(0.15),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chevron_left_rounded,
                  size: 24, color: Color(0xFF5C28A0)),
              SizedBox(width: 2),
              Text(
                AppLocalizations.of(context)!.back,
                style: const TextStyle(
                  fontFamily: 'Fredoka One',
                  fontSize: 19,
                  color: Color(0xFF5C28A0),
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
//  TITLE SECTION
// ─────────────────────────────────────────────
class _TitleSection extends StatelessWidget {
  final AppLocalizations l10n;

  const _TitleSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          l10n.chooseTheme,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Fredoka One',
            fontSize: 36,
            height: 1,
            color: Color(0xFF5C28A0),
            shadows: [
              Shadow(color: Color(0xFFD0B0F0), offset: Offset(0, 4)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.pickYourAdventure,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 16,
            color: Color(0xFF7854B8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  THEME CARD
// ─────────────────────────────────────────────
class _ThemeCard extends StatefulWidget {
  final PuzzleTheme theme;
  final int index;
  final String playNowLabel;
  final VoidCallback? onTap;

  const _ThemeCard({
    required this.theme,
    required this.index,
    required this.playNowLabel,
    this.onTap,
  });

  @override
  State<_ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<_ThemeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ribbonCtrl;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _ribbonCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );
    if (!widget.theme.locked) _ribbonCtrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ribbonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final lockedGradient = [Color(0xFFDDD8F0), Color(0xFFC0B8E0)];

    return GestureDetector(
      onTapDown: theme.locked ? null : (_) => setState(() => _scale = 0.96),
      onTapUp: theme.locked
          ? null
          : (_) {
              setState(() => _scale = 1.0);
              widget.onTap?.call();
            },
      onTapCancel: theme.locked ? null : () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Opacity(
          opacity: theme.locked ? 0.70 : 1.0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── CARD BODY ──
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: theme.locked ? lockedGradient : theme.gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: theme.border, width: 3),
                  boxShadow: theme.locked
                      ? [
                          BoxShadow(
                            color: Color(0xFFA8A0C8),
                            offset: Offset(0, 5),
                            blurRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            offset: Offset(0, 8),
                            blurRadius: 20,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: theme.shadow,
                            offset: Offset(0, 7),
                            blurRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            offset: Offset(0, 12),
                            blurRadius: 28,
                          ),
                        ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Row(
                    children: [
                      // Illustration panel
                      Container(
                        width: 130,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          border: Border(
                            right: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(child: theme.illustration()),
                      ),

                      // Text panel
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 14, 12, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                theme.label,
                                style: TextStyle(
                                  fontFamily: 'Fredoka One',
                                  fontSize: 22,
                                  color: theme.locked
                                      ? Color(0xFF7870A8)
                                      : Colors.white,
                                  shadows: theme.locked
                                      ? null
                                      : [
                                          Shadow(
                                            color: Color(0x2E000000),
                                            offset: Offset(0, 2),
                                            blurRadius: 6,
                                          ),
                                        ],
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                theme.sublabel,
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: theme.locked
                                      ? Color(0xFF9888C0)
                                      : Colors.white.withOpacity(0.85),
                                ),
                              ),
                              // Stars
                              if (!theme.locked) ...[
                                SizedBox(height: 8),
                                Row(
                                  children: List.generate(3, (idx) {
                                    final filled = idx < theme.stars;
                                    return Padding(
                                      padding: EdgeInsets.only(right: 4),
                                      child: Icon(
                                        filled
                                            ? Icons.star_rounded
                                            : Icons.star_rounded,
                                        size: 16,
                                        color: filled
                                            ? Color(0xFFFFD93D)
                                            : Colors.white.withOpacity(0.35),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Right icon
                      Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: theme.locked
                            ? SizedBox.shrink()
                            : Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Lock badge (locked cards)
              if (theme.locked)
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 16,
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(Icons.lock_rounded,
                          size: 20, color: Color(0xFF7870A8)),
                    ),
                  ),
                ),

              // PLAY NOW! ribbon (unlocked)
              if (!theme.locked)
                Positioned(
                  top: -10,
                  right: 14,
                  child: AnimatedBuilder(
                    animation: _ribbonCtrl,
                    builder: (_, child) {
                      final angle =
                          (-2 + 4 * _ribbonCtrl.value) * pi / 180;
                      return Transform.rotate(angle: angle, child: child);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF5F5F), Color(0xFFFF2020)],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFF2020).withOpacity(0.45),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.playNowLabel,
                        style: const TextStyle(
                          fontFamily: 'Fredoka One',
                          fontSize: 13,
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
    );
  }
}

// ─────────────────────────────────────────────
//  FOOTER HINT
// ─────────────────────────────────────────────
class _FooterHint extends StatefulWidget {
  final String text;

  const _FooterHint({required this.text});

  @override
  State<_FooterHint> createState() => _FooterHintState();
}

class _FooterHintState extends State<_FooterHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) =>
          Opacity(opacity: 0.6 + 0.4 * _ctrl.value, child: child),
      child: Text(
        widget.text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 14,
          color: Color(0xFF7854B8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ILLUSTRATIONS  (SVG → CustomPainter)
// ─────────────────────────────────────────────

// ── Animals ──
class AnimalsIllustration extends StatelessWidget {
  AnimalsIllustration({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _AnimalsPainter(), size: Size(120, 70));
}

class _AnimalsPainter extends CustomPainter {
  void _oval(Canvas c, double cx, double cy, double rx, double ry, Color col,
      {double op = 1}) {
    c.drawOval(
      Rect.fromCenter(
          center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      Paint()..color = col.withOpacity(op),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Ground
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 62, 120, 8), Radius.circular(4)),
      Paint()..color = Color(0xFF8AD880),
    );

    // ── Lion ──
    _oval(canvas, 22, 38, 14, 14, Color(0xFFE67E22));
    _oval(canvas, 22, 38, 10, 10, Color(0xFFF5A623));
    _oval(canvas, 16, 30, 4, 4, Color(0xFFF5A623));
    _oval(canvas, 28, 30, 4, 4, Color(0xFFF5A623));
    _oval(canvas, 22, 43, 5, 3, Color(0xFFFCD5A0));
    _oval(canvas, 17, 35, 2.5, 2.5, Color(0xFF1A0A30));
    _oval(canvas, 27, 35, 2.5, 2.5, Color(0xFF1A0A30));
    canvas.drawCircle(Offset(17.8, 33.8), 1, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(27.8, 33.8), 1, Paint()..color = Colors.white);
    canvas.drawPath(
      Path()
        ..moveTo(17, 44)
        ..quadraticBezierTo(22, 49, 27, 44),
      Paint()
        ..color = Color(0xFFC0590A)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // ── Elephant ──
    _oval(canvas, 60, 34, 16, 16, Color(0xFF5DADE2));
    _oval(canvas, 45, 34, 8, 11, Color(0xFF4FA0D5));
    _oval(canvas, 75, 34, 8, 11, Color(0xFF4FA0D5));
    _oval(canvas, 60, 34, 13, 13, Color(0xFF5DADE2));
    canvas.drawPath(
      Path()
        ..moveTo(55, 44)
        ..quadraticBezierTo(46, 56, 52, 62),
      Paint()
        ..color = Color(0xFF4FA0D5)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    _oval(canvas, 54, 29, 3, 3, Colors.white);
    _oval(canvas, 66, 29, 3, 3, Colors.white);
    _oval(canvas, 55, 29, 1.5, 1.5, Color(0xFF1A0A30));
    _oval(canvas, 67, 29, 1.5, 1.5, Color(0xFF1A0A30));

    // ── Giraffe ──
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(96, 10, 14, 44), Radius.circular(7)),
      Paint()..color = Color(0xFFFFD93D),
    );
    _oval(canvas, 103, 12, 12, 10, Color(0xFFFFD93D));
    _oval(canvas, 112, 14, 8, 6, Color(0xFFF5C68A));
    _oval(canvas, 99, 30, 4, 5, Color(0xFFE67E22), op: 0.7);
    _oval(canvas, 103, 42, 3, 4, Color(0xFFE67E22), op: 0.7);
    _oval(canvas, 100, 9, 2.5, 2.5, Colors.white);
    _oval(canvas, 101, 9, 1.2, 1.2, Color(0xFF1A0A30));
    // horns
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(97, 2, 4, 10), Radius.circular(2)),
      Paint()..color = Color(0xFFC0590A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(103, 0, 4, 10), Radius.circular(2)),
      Paint()..color = Color(0xFFC0590A),
    );
  }

  @override
  bool shouldRepaint(_AnimalsPainter o) => false;
}

// ── Vehicles ──
class VehiclesIllustration extends StatelessWidget {
  VehiclesIllustration({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Opacity(
        opacity: 0.55,
        child: CustomPaint(
            painter: _VehiclesPainter(), size: Size(120, 70)),
      );
}

class _VehiclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Ground
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 66, 120, 4), Radius.circular(2)),
      Paint()..color = Color(0xFF8AD880),
    );

    // Car body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(4, 36, 50, 22), Radius.circular(8)),
      Paint()..color = Color(0xFF74C0FC),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(12, 26, 34, 18), Radius.circular(6)),
      Paint()..color = Color(0xFFA8D8FF),
    );
    // Wheels
    for (final cx in [16.0, 42.0]) {
      canvas.drawCircle(
          Offset(cx, 60), 8, Paint()..color = Color(0xFF555555));
      canvas.drawCircle(
          Offset(cx, 60), 4, Paint()..color = Color(0xFF999999));
    }

    // Airplane body
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(82, 25), width: 60, height: 16),
      Paint()..color = Color(0xFFA8D8FF),
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(90, 20), width: 24, height: 12),
      Paint()..color = Color(0xFF74C0FC),
    );

    // Wings
    canvas.save();
    canvas.translate(62, 30);
    canvas.rotate(20 * pi / 180);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 20, height: 8),
      Paint()..color = Color(0xFF74C0FC),
    );
    canvas.restore();

    canvas.save();
    canvas.translate(106, 22);
    canvas.rotate(-10 * pi / 180);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 12, height: 5),
      Paint()..color = Color(0xFF74C0FC),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_VehiclesPainter o) => false;
}

// ── Shapes ──
class ShapesIllustration extends StatelessWidget {
  ShapesIllustration({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Opacity(
        opacity: 0.55,
        child: CustomPaint(
            painter: _ShapesPainter(), size: Size(120, 70)),
      );
}

class _ShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Ground
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 64, 120, 6), Radius.circular(3)),
      Paint()..color = Color(0xFF8AD880),
    );

    // Star
    final starPath = Path();
    final starPoints = <Offset>[
      Offset(22.0, 8.0), Offset(26.0, 18.0), Offset(37.0, 18.0), Offset(28.0, 25.0), Offset(31.0, 36.0),
      Offset(22.0, 29.0), Offset(13.0, 36.0), Offset(16.0, 25.0), Offset(7.0, 18.0), Offset(18.0, 18.0)
    ];
    starPath.moveTo(starPoints[0].dx, starPoints[0].dy);
    for (int i = 1; i < starPoints.length; i++) {
      starPath.lineTo(starPoints[i].dx, starPoints[i].dy);
    }
    starPath.close();
    canvas.drawPath(starPath, Paint()..color = Color(0xFFFFD93D));
    canvas.drawPath(
      starPath,
      Paint()
        ..color = Color(0xFFE6B800)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Circle
    canvas.drawCircle(
        Offset(60, 35), 22, Paint()..color = Color(0xFFB39DDB));
    canvas.drawCircle(
        Offset(60, 35),
        22,
        Paint()
          ..color = Color(0xFF9575CD)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    canvas.drawCircle(
        Offset(60, 35), 14, Paint()..color = Color(0xFFC5B3E6));

    // Triangle
    final triPath = Path()
      ..moveTo(98, 8)
      ..lineTo(118, 60)
      ..lineTo(78, 60)
      ..close();
    canvas.drawPath(triPath, Paint()..color = Color(0xFFFF9F7F));
    canvas.drawPath(
      triPath,
      Paint()
        ..color = Color(0xFFE67E22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_ShapesPainter o) => false;
}

// ─────────────────────────────────────────────
//  SCENE BACKGROUND
// ─────────────────────────────────────────────
