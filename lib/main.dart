import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'package:hippolulu/language_picker.dart';
import 'package:hippolulu/locale_provider.dart';
import 'level_selection.dart';
import 'puzzle_item_selection.dart';
import 'matching_theme_select.dart';
import 'matching_game.dart';
import 'puzzle_arena.dart';
import 'asset_service.dart';
import 'splash_screen.dart';

// ─────────────────────────────────────────────
//  ENTRY POINT
// ─────────────────────────────────────────────
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeProvider = LocaleProvider();
  await localeProvider.load();
  await AssetService().load();
  runApp(HippoLuluApp(localeProvider: localeProvider));
}

class HippoLuluApp extends StatelessWidget {
  final LocaleProvider localeProvider;

  const HippoLuluApp({Key? key, required this.localeProvider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LocaleProviderScope(
      notifier: localeProvider,
      child: ListenableBuilder(
        listenable: localeProvider,
        builder: (context, _) {
          return MaterialApp(
            title: 'HippoLulu',
            theme: ThemeData(
              fontFamily: 'Baloo2 ExtraBold',
            ),
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (localeProvider.locale != null) {
                return localeProvider.locale!;
              }
              if (deviceLocale != null) {
                for (final supported in supportedLocales) {
                  if (supported.languageCode == deviceLocale.languageCode) {
                    return supported;
                  }
                }
              }
              return const Locale('en');
            },
            home: const CustomSplashScreen(),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SPLASH SCREEN
//  The actual animated sequence lives in splash_screen.dart (SplashScreen)
//  — this just wires its completion callback to the same MainMenu routing
//  the old timer-based splash used.
// ─────────────────────────────────────────────
class CustomSplashScreen extends StatelessWidget {
  const CustomSplashScreen({Key? key}) : super(key: key);

  void _goToMainMenu(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => MainMenu(
          onModeSelect: (modeId) async {
            await SystemChrome.setPreferredOrientations(
                    DeviceOrientation.values)
                .catchError((_) {});
            if (modeId == 'puzzles') {
              await Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (navCtx) => LevelSelection(
                    onBack: () => Navigator.of(navCtx).pop(),
                    onSelect: (theme) {
                      Navigator.of(navCtx).push(
                        MaterialPageRoute(
                          builder: (selectionCtx) => PuzzleItemSelection(
                            themeId: theme.id,
                            themeTitle: theme.label,
                            onBack: () => Navigator.of(selectionCtx).pop(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            } else if (modeId == 'matching') {
              await Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (navCtx) => MatchingThemeSelect(
                    onBack: () => Navigator.of(navCtx).pop(),
                    onSelect: (theme) {
                      Navigator.of(navCtx).push(
                        MaterialPageRoute(
                          builder: (gameCtx) => MatchingGame(
                            theme: theme,
                            onBack: () => Navigator.of(gameCtx).pop(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]).catchError((_) {});
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(onFinished: () => _goToMainMenu(context));
  }
}

// ─────────────────────────────────────────────
//  GAME MODE DATA
// ─────────────────────────────────────────────
class GameMode {
  final String id;
  final String label;
  final String emoji;
  final String sublabel;
  final Color bg;
  final Color shadow;
  final Color outline;
  final Color textColor;
  final bool locked;

  GameMode({
    required this.id,
    required this.label,
    required this.emoji,
    required this.sublabel,
    required this.bg,
    required this.shadow,
    required this.outline,
    required this.textColor,
    required this.locked,
  });
}

List<GameMode> gameModes(AppLocalizations l10n) => [
      GameMode(
        id: 'puzzles',
        label: l10n.gamePuzzles,
        emoji: '🧩',
        sublabel: l10n.gamePuzzlesSub,
        bg: const Color(0xFFFFD93D),
        shadow: const Color(0xFFC49200),
        outline: const Color(0xFFFFA500),
        textColor: const Color(0xFF5A3000),
        locked: false,
      ),
      GameMode(
        id: 'matching',
        label: l10n.gameMatching,
        emoji: '💡',
        sublabel: l10n.gameMatchingSub,
        bg: const Color(0xFF7DE87A),
        shadow: const Color(0xFF1A9418),
        outline: const Color(0xFF22B820),
        textColor: const Color(0xFF0A2E00),
        locked: false,
      ),
      GameMode(
        id: 'coloring',
        label: l10n.gameColoring,
        emoji: '🎨',
        sublabel: l10n.gameColoringSub,
        bg: const Color(0xFFFF85C2),
        shadow: const Color(0xFFC03080),
        outline: const Color(0xFFFF4FA0),
        textColor: const Color(0xFF4A0030),
        locked: true,
      ),
      GameMode(
        id: 'counting',
        label: l10n.gameCounting,
        emoji: '🔢',
        sublabel: l10n.gameCountingSub,
        bg: const Color(0xFF64D2FF),
        shadow: const Color(0xFF0080C8),
        outline: const Color(0xFF0099FF),
        textColor: const Color(0xFF003060),
        locked: true,
      ),
    ];

// ─────────────────────────────────────────────
//  MAIN MENU
// ─────────────────────────────────────────────
class MainMenu extends StatefulWidget {
  final void Function(String) onModeSelect;
  const MainMenu({Key? key, required this.onModeSelect}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  void initState() {
    super.initState();
    _lockPortrait();
  }

  void _lockPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    //_lockPortrait();
    final l10n = AppLocalizations.of(context)!;
    final screenW = MediaQuery.of(context).size.width;
    final isTablet = screenW > 600;

    return Scaffold(
      body: SceneBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ── TOP BAR ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StarsBadge(starsText: l10n.starsBadge),
                      const _SettingsButton(),
                    ],
                  ),
                ),

                // ── HERO STACK (Logo + Hippo) ──
                _HeroStack(
                  tagline: l10n.tagline,
                ),

                // ── GAME MODE GRID (in decorative frame) ──
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: isTablet ? 100 : 48,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _GameFrame(
                          child:
                              _GameModeGrid(onModeSelect: widget.onModeSelect),
                        ),
                      ),
                      Positioned(
                        top: -15,
                        child: _SectionPill(label: l10n.chooseGame),
                      ),
                    ],
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
//  TOP BAR
// ─────────────────────────────────────────────
class _StarsBadge extends StatelessWidget {
  final String starsText;

  const _StarsBadge({required this.starsText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFFFD54F),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF643CC8).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 5),
          Text(
            starsText,
            style: const TextStyle(
              fontFamily: 'Baloo2 ExtraBold',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF5C28A0),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsButton extends StatefulWidget {
  const _SettingsButton();

  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.88),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        LanguagePickerSheet.show(context);
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.90),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE0D0FF),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF643CC8).withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.language_rounded,
              size: 22, color: Color(0xFF5C28A0)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HERO STACK (logo plaque + hippo + tagline ribbon + choose game pill)
// ─────────────────────────────────────────────
class _HeroStack extends StatelessWidget {
  final String tagline;

  const _HeroStack({
    required this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenW = MediaQuery.of(context).size.width;
    final isTablet = screenW > 600;
    final logoWidth = isTablet ? 1000.0 : 500.0;
    final logoHeight = logoWidth / 1.74;
    final hippoWidth = isTablet ? 600.0 : 225.0;
    final hippoHeight = hippoWidth / 0.945;

    final stackHeight = isTablet ? 600.0 : 235.0;

    return SizedBox(
      width: double.infinity,
      height: stackHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. Logo Plaque (background of header)
          Positioned(
            top: -30,
            child: SizedBox(
              width: logoWidth,
              height: logoHeight,
              child: Image.asset(
                'assets/images/logo.webp',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 2. Hippo Mascot
          Positioned(
            top: isTablet ? 280 : 130,
            child: SizedBox(
              width: hippoWidth,
              height: hippoHeight,
              child: Image.asset(
                'assets/images/hippo.webp',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DASHED BORDER PAINTER (reused for plaque + game frame)
// ─────────────────────────────────────────────
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  // Extra gap between the dashed line and the outer edge of the widget
  // it's painted on. 0 = dashes sit right on the edge. Increase this to
  // push the dashed strip further inward, away from the frame's edge.
  final double inset;

  _DashedBorderPainter({
    required this.color,
    this.radius = 24,
    this.strokeWidth = 3,
    this.dashWidth = 7,
    this.dashGap = 5,
    this.inset = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final totalInset = strokeWidth / 2 + inset;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(totalInset, totalInset, size.width - totalInset * 2,
          size.height - totalInset * 2),
      Radius.circular(radius - inset),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.inset != inset;
}

// ─────────────────────────────────────────────
//  TAGLINE RIBBON (real ribbon.png asset + text overlay)
// ─────────────────────────────────────────────
class _TaglineRibbon extends StatelessWidget {
  final String tagline;

  const _TaglineRibbon({required this.tagline});

  @override
  Widget build(BuildContext context) {
    const width = 210.0;
    const height = width / 3.79;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/ribbon.png',
            fit: BoxFit.fill,
          ),
          CustomPaint(
            size: const Size(width, height),
            painter: _CurvedTextPainter(
              text: tagline,
              textStyle: const TextStyle(
                fontFamily: 'Baloo2 ExtraBold',
                fontSize: 13.5,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.1,
                shadows: [
                  Shadow(
                    color: Color(0x88000000),
                    offset: Offset(0, 1),
                    blurRadius: 2,
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

class _CurvedTextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;

  _CurvedTextPainter({
    required this.text,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cleanText = text.replaceAll(RegExp(r'^[✨⭐\s]+'), '').trim();
    if (cleanText.isEmpty) return;

    const startX = 22.0;
    final endX = size.width - 22.0;
    final startY = size.height * 0.58;
    final endY = size.height * 0.58;
    final controlX = size.width / 2;
    final controlY = size.height * 0.28;

    final path = Path()
      ..moveTo(startX, startY)
      ..quadraticBezierTo(controlX, controlY, endX, endY);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final pathLength = metric.length;

    final refPainter = TextPainter(
      text: TextSpan(text: 'X', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final baseHeight = refPainter.height;

    final graphemes = cleanText.characters.toList();

    final charPainters = <TextPainter>[];
    double totalWidth = 0;
    for (final charStr in graphemes) {
      final tp = TextPainter(
        text: TextSpan(text: charStr, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      charPainters.add(tp);
      totalWidth += tp.width;
    }

    if (totalWidth == 0) return;

    double currentOffset = (pathLength - totalWidth) / 2;

    for (int i = 0; i < graphemes.length; i++) {
      final tp = charPainters[i];
      final charWidth = tp.width;

      if (charWidth == 0) {
        currentOffset += charWidth;
        continue;
      }

      final charCenterOffset =
          (currentOffset + charWidth / 2).clamp(0.0, pathLength);
      final tangent = metric.getTangentForOffset(charCenterOffset);

      if (tangent != null) {
        canvas.save();
        canvas.translate(tangent.position.dx, tangent.position.dy);
        canvas.rotate(tangent.angle);
        tp.paint(canvas, Offset(-charWidth / 2, -baseHeight * 0.50));
        canvas.restore();
      }

      currentOffset += charWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedTextPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.textStyle != textStyle;
  }
}

// ─────────────────────────────────────────────
//  SECTION PILL ("🎮 Bir Oyun Seç!")
// ─────────────────────────────────────────────
class _SectionPill extends StatelessWidget {
  final String label;

  const _SectionPill({required this.label});

  @override
  Widget build(BuildContext context) {
    // The CustomPaint now wraps the whole decorated Container (background +
    // padding + text), so it sizes itself to the full pill instead of just
    // the text — the dashed border is painted right on the pill's true
    // outer edge instead of hugging tightly around the label.
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: const Color(0xFFFFC94D),
        radius: 999,
        strokeWidth: 2,
        dashWidth: 6,
        dashGap: 4,
        inset: 4, // 👈 kesikli şerit ile pill'in kenarı arasındaki boşluk (px)
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 237, 194),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF643CC8).withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Baloo2 ExtraBold',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF5C28A0),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  GAME FRAME (dashed, light-bulb bordered panel around the grid)
// ─────────────────────────────────────────────
class _GameFrame extends StatelessWidget {
  final Widget child;

  const _GameFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      // The red border + light-bulb ring is painted at the true outer
      // edge of this widget now, so there's no cream margin outside it
      // and the bulbs sit right on the visible edge (like the reference).
      child: CustomPaint(
        foregroundPainter: _LightBulbBorderPainter(),
        child: Container(
          // Matches the strokeW (9) in _LightBulbBorderPainter exactly,
          // so the warm fill butts right up against the red band with
          // no transparent gap showing through in between.
          margin: const EdgeInsets.all(9),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // Warmer amusement-park cream/tan instead of near-white.
            color: const Color.fromARGB(255, 247, 199, 169),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _LightBulbBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const strokeW = 9.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeW / 2, strokeW / 2, size.width - strokeW,
          size.height - strokeW),
      const Radius.circular(22),
    );

    // Thick red arcade frame border
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color.fromARGB(255, 240, 96, 94)
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke,
    );

    // Yellow glowing bulbs around the frame
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      const spacing = 15.0;
      double distance = spacing / 2;
      while (distance < metric.length) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(
            tangent.position,
            4.5,
            Paint()..color = const Color(0xFFFFEB3B),
          );
          canvas.drawCircle(
            tangent.position,
            3.0,
            Paint()..color = const Color(0xFFFFFDE7),
          );
          canvas.drawCircle(
            tangent.position,
            4.5,
            Paint()
              ..color = const Color(0xFFFF9800)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.8,
          );
        }
        distance += spacing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LightBulbBorderPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
//  GAME MODE GRID
// ─────────────────────────────────────────────
class _GameModeGrid extends StatelessWidget {
  final void Function(String) onModeSelect;
  const _GameModeGrid({required this.onModeSelect});

  @override
  Widget build(BuildContext context) {
    final modes = gameModes(AppLocalizations.of(context)!);
    final screenW = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    int crossAxisCount = (screenW > 600 || isLandscape) ? 4 : 2;
    double childAspectRatio =
        isLandscape ? 1.05 : ((screenW > 600) ? 0.76 : 0.88);

    return Align(
      alignment: Alignment.topCenter,
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: childAspectRatio,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(modes.length, (i) {
          return _GameModeCard(
            mode: modes[i],
            index: i,
            onTap: modes[i].locked ? null : () => onModeSelect(modes[i].id),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  GAME MODE CARD
// ─────────────────────────────────────────────
class _GameModeCard extends StatefulWidget {
  final GameMode mode;
  final int index;
  final VoidCallback? onTap;

  const _GameModeCard({
    required this.mode,
    required this.index,
    this.onTap,
  });

  @override
  State<_GameModeCard> createState() => _GameModeCardState();
}

class _GameModeCardState extends State<_GameModeCard>
    with TickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late AnimationController _emojiCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _ribbonCtrl;

  double _pressScale = 1.0;
  double _pressY = 0.0;

  @override
  void initState() {
    super.initState();

    _emojiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (!widget.mode.locked) {
      Timer(
        Duration(milliseconds: (2000 + widget.index * 700)),
        () {
          if (mounted) {
            _emojiCtrl.repeat(
                period: const Duration(milliseconds: 1200 + 2000));
          }
        },
      );
    }

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _ribbonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _emojiCtrl.dispose();
    _pulseCtrl.dispose();
    _ribbonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    final cardBg = mode.bg;
    final cardShadow = mode.shadow;

    return GestureDetector(
      onTapDown: (_) {
        if (!mode.locked) {
          setState(() {
            _pressScale = 0.93;
            _pressY = 4;
          });
        }
      },
      onTapUp: (_) {
        setState(() {
          _pressScale = 1.0;
          _pressY = 0;
        });
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() {
        _pressScale = 1.0;
        _pressY = 0;
      }),
      child: AnimatedScale(
        scale: _pressScale,
        duration: const Duration(milliseconds: 100),
        child: AnimatedSlide(
          offset: Offset(0, _pressY / 200),
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.65),
                width: 3.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: cardShadow,
                  offset: const Offset(0, 6),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  offset: const Offset(0, 8),
                  blurRadius: 16,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glare
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.40),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Center(
                      child: FittedBox(
                        // `contain` (not `scaleDown`) so the icon/label
                        // also scale *up* to fill a bigger card on a
                        // tablet, instead of staying pinned to their
                        // natural small size in the middle of empty space.
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _EmojiCircle(
                              emoji: mode.emoji,
                              locked: mode.locked,
                              controller: _emojiCtrl,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              mode.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Baloo2 ExtraBold',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: mode.textColor,
                                letterSpacing: 0.3,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              mode.sublabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Baloo2 ExtraBold',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: mode.textColor.withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (mode.locked)
                              _LockBadge(
                                label: AppLocalizations.of(context)!.locked,
                              )
                            else
                              _PlayArrowCircle(arrowColor: mode.shadow),
                          ],
                        ),
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

class _EmojiCircle extends StatelessWidget {
  final String emoji;
  final bool locked;
  final AnimationController controller;

  const _EmojiCircle({
    required this.emoji,
    required this.locked,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    Widget circle = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: locked
            ? Colors.white.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.38),
        shape: BoxShape.circle,
        boxShadow: locked
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 34)),
      ),
    );

    if (locked) return circle;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        // Keyframe: rotate [-12, 12, -6, 6, 0], scale [1, 1.15, 1.15, 1.05, 1]
        final t = controller.value;
        final angle = _lerpKeyframes(t, [0, -12, 12, -6, 6, 0]) * pi / 180;
        final scale = _lerpKeyframes(t, [1, 1.15, 1.15, 1.05, 1]);
        return Transform.scale(
          scale: scale,
          child: Transform.rotate(angle: angle, child: child),
        );
      },
      child: circle,
    );
  }

  double _lerpKeyframes(double t, List<double> frames) {
    if (frames.length < 2) return frames.first;
    final segments = frames.length - 1;
    final scaledT = t * segments;
    final i = scaledT.floor().clamp(0, segments - 1);
    final frac = scaledT - i;
    return frames[i] + (frames[i + 1] - frames[i]) * frac;
  }
}

class _LockBadge extends StatelessWidget {
  final String label;

  const _LockBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_rounded, size: 13, color: Color(0xFF5C28A0)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Baloo2 ExtraBold',
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF5C28A0),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayArrowCircle extends StatelessWidget {
  final Color arrowColor;

  const _PlayArrowCircle({required this.arrowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.keyboard_arrow_right_rounded,
          size: 28,
          color: arrowColor,
        ),
      ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  final String label;
  final Color textColor;
  final AnimationController controller;

  const _PlayBadge({
    required this.label,
    required this.textColor,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final scale = 1.0 + 0.12 * controller.value;
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Baloo2 ExtraBold',
            fontSize: 12,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _NewRibbon extends StatelessWidget {
  final String label;
  final AnimationController controller;

  const _NewRibbon({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final angle = (-4 + 8 * controller.value) * pi / 180;
        final dy = -controller.value;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.rotate(angle: angle, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF4444), Color(0xFFDD0000)],
          ),
          borderRadius: BorderRadius.circular(999),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC80000).withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Baloo2 ExtraBold',
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  COMING SOON FOOTER
// ─────────────────────────────────────────────
class _ComingSoonFooter extends StatefulWidget {
  final String text;

  const _ComingSoonFooter({required this.text});

  @override
  State<_ComingSoonFooter> createState() => _ComingSoonFooterState();
}

class _ComingSoonFooterState extends State<_ComingSoonFooter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
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
      builder: (_, child) => Opacity(
        opacity: 0.6 + 0.4 * _ctrl.value,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          '🚀  ${widget.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Baloo2 ExtraBold',
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SCENE BACKGROUND (aynı önceki versiyondan)
// ─────────────────────────────────────────────
class SceneBackground extends StatelessWidget {
  final Widget child;
  const SceneBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Circus / ferris-wheel park background image
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
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
    final sx = size.width / 390;
    final sy = size.height / 320;

    canvas.drawCircle(Offset(352 * sx, 52 * sy), 38 * sx,
        Paint()..color = const Color(0xFFFFE566).withValues(alpha: 0.9));
    canvas.drawCircle(Offset(352 * sx, 52 * sy), 30 * sx,
        Paint()..color = const Color(0xFFFFD93D));

    final rayPaint = Paint()
      ..color = const Color(0xFFFFC300).withValues(alpha: 0.8)
      ..strokeWidth = 5 * sx
      ..strokeCap = StrokeCap.round;
    for (final deg in [0, 40, 80, 120, 160, 200, 240, 280, 320]) {
      final rad = deg * pi / 180;
      canvas.drawLine(
        Offset(352 * sx + cos(rad) * 42 * sx, 52 * sy + sin(rad) * 42 * sy),
        Offset(352 * sx + cos(rad) * 56 * sx, 52 * sy + sin(rad) * 56 * sy),
        rayPaint,
      );
    }

    void drawCloud(double cx, double cy, double sc, double op) {
      final p = Paint()..color = Colors.white.withValues(alpha: op);
      void e(double ex, double ey, double rx, double ry) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset((cx + ex) * sx, (cy + ey) * sy),
            width: rx * 2 * sx * sc,
            height: ry * 2 * sy * sc,
          ),
          p,
        );
      }

      e(0, 10, 34, 26);
      e(32, 2, 38, 30);
      e(70, 8, 30, 24);
      e(100, 14, 26, 20);
      e(52, 18, 54, 18);
    }

    drawCloud(-10, 40, 0.85, 0.95);
    drawCloud(200, 18, 0.70, 0.90);
    drawCloud(90, 100, 0.60, 0.80);
    drawCloud(270, 110, 0.55, 0.75);
    drawCloud(-20, 160, 0.50, 0.65);
    drawCloud(300, 190, 0.45, 0.60);
  }

  @override
  bool shouldRepaint(_SkyPainter o) => false;
}

class _HillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 390;
    final sy = size.height / 200;
    void e(double cx, double cy, double rx, double ry, Color c) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx * sx, cy * sy),
            width: rx * 2 * sx,
            height: ry * 2 * sy),
        Paint()..color = c,
      );
    }

    e(320, 170, 280, 120, const Color(0xFF6ABF62));
    e(80, 180, 260, 115, const Color(0xFF78CC70));
    e(230, 190, 300, 110, const Color(0xFF8AD880));
    canvas.drawRect(Rect.fromLTWH(0, 155 * sy, size.width, 45 * sy),
        Paint()..color = const Color(0xFF8AD880));

    final colors = [
      const Color(0xFFFFD93D),
      const Color(0xFFFF9F7F),
      const Color(0xFFF48FB1),
      const Color(0xFFA8D85C)
    ];
    final xs = [22.0, 68, 118, 175, 235, 295, 348];
    for (int i = 0; i < xs.length; i++) {
      final x = xs[i] * sx;
      final y = (138 + (i % 3) * 6) * sy;
      canvas.drawCircle(Offset(x, y), 6 * sx, Paint()..color = colors[i % 4]);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(x, y + 7 * sy), width: 3 * sx, height: 10 * sy),
            const Radius.circular(2)),
        Paint()..color = const Color(0xFF5AAA50),
      );
    }
  }

  @override
  bool shouldRepaint(_HillsPainter o) => false;
}

// ─────────────────────────────────────────────
//  HIPPO MASCOT (SVG → CustomPainter)
// ─────────────────────────────────────────────
class HippoMascot extends StatelessWidget {
  const HippoMascot({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _HippoPainter(), size: const Size(190, 190));
}

class _HippoPainter extends CustomPainter {
  // Scale from original 260x300 viewBox to 190x190
  static double _ox = 260, _oy = 300;
  static double _tw = 190, _th = 190;

  Offset _p(double x, double y) => Offset(x / _ox * _tw, y / _oy * _th);
  double _sx(double v) => v / _ox * _tw;
  double _sy(double v) => v / _oy * _th;

  void _oval(Canvas c, double cx, double cy, double rx, double ry, Color color,
      {double opacity = 1.0}) {
    c.drawOval(
      Rect.fromCenter(
          center: _p(cx, cy), width: _sx(rx * 2), height: _sy(ry * 2)),
      Paint()..color = color.withValues(alpha: opacity),
    );
  }

  void _rrect(
      Canvas c, double x, double y, double w, double h, double r, Color color) {
    c.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(_p(x, y).dx, _p(x, y).dy, _sx(w), _sy(h)),
          Radius.circular(r / _ox * _tw)),
      Paint()..color = color,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
        Rect.fromCenter(center: _p(130, 294), width: _sx(170), height: _sy(18)),
        Paint()..color = const Color(0xFF501EA0).withValues(alpha: 0.14));

    _rrect(canvas, 42, 170, 176, 118, 55, const Color(0xFF8C5CC8));
    _oval(canvas, 130, 218, 60, 44, const Color(0xFFA878DE));

    _rrect(canvas, 52, 252, 52, 46, 26, const Color(0xFF7A4AB8));
    _rrect(canvas, 155, 252, 52, 46, 26, const Color(0xFF7A4AB8));
    for (final d in [
      [56.0, 292.0],
      [68.0, 296.0],
      [80.0, 296.0],
      [92.0, 292.0],
      [159.0, 292.0],
      [171.0, 296.0],
      [183.0, 296.0],
      [195.0, 292.0],
    ]) {
      _oval(canvas, d[0], d[1], 8, 8, const Color(0xFF6C3CA8));
    }

    canvas.save();
    canvas.translate(_p(34, 200).dx, _p(34, 200).dy);
    canvas.rotate(-20 * pi / 180);
    _oval(canvas, 0, 0, 20, 32, const Color(0xFF8C5CC8));
    canvas.restore();
    _oval(canvas, 20, 226, 18, 14, const Color(0xFF9A6CD4));

    canvas.save();
    canvas.translate(_p(218, 188).dx, _p(218, 188).dy);
    canvas.rotate(40 * pi / 180);
    _oval(canvas, 0, 0, 18, 32, const Color(0xFF8C5CC8));
    canvas.restore();
    canvas.save();
    canvas.translate(_p(234, 158).dx, _p(234, 158).dy);
    canvas.rotate(20 * pi / 180);
    _oval(canvas, 0, 0, 15, 28, const Color(0xFF9A6CD4));
    canvas.restore();
    _oval(canvas, 240, 132, 17, 17, const Color(0xFFA878DE));
    for (final d in [
      [254.0, 120.0, 11.0],
      [257.0, 136.0, 11.0],
      [249.0, 149.0, 10.0],
      [226.0, 122.0, 10.0]
    ]) {
      _oval(canvas, d[0], d[1], d[2], d[2], const Color(0xFFB088E4));
    }

    _rrect(canvas, 88, 158, 82, 32, 16, const Color(0xFF9A6CD4));
    _oval(canvas, 130, 112, 80, 75, const Color(0xFFB088E4));
    _oval(canvas, 58, 66, 30, 27, const Color(0xFF9A6CD4));
    _oval(canvas, 58, 66, 17, 16, const Color(0xFFF08CB8));
    _oval(canvas, 202, 66, 30, 27, const Color(0xFF9A6CD4));
    _oval(canvas, 202, 66, 17, 16, const Color(0xFFF08CB8));
    _oval(canvas, 130, 112, 76, 71, const Color(0xFFB088E4));

    _oval(canvas, 130, 143, 50, 33, const Color(0xFFCAAFF0));
    _oval(canvas, 130, 136, 36, 16, const Color(0xFFD8BEF7), opacity: 0.6);
    _oval(canvas, 112, 141, 11, 8, const Color(0xFF7A4AB8));
    _oval(canvas, 148, 141, 11, 8, const Color(0xFF7A4AB8));
    canvas.drawCircle(_p(109, 138), _sx(3),
        Paint()..color = Colors.white.withValues(alpha: 0.35));
    canvas.drawCircle(_p(145, 138), _sx(3),
        Paint()..color = Colors.white.withValues(alpha: 0.35));

    final sp = Paint()
      ..color = const Color(0xFF7A4AB8)
      ..strokeWidth = _sx(4)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
        Path()
          ..moveTo(_p(96, 158).dx, _p(96, 158).dy)
          ..quadraticBezierTo(_p(130, 180).dx, _p(130, 180).dy, _p(164, 158).dx,
              _p(164, 158).dy),
        sp);
    _rrect(canvas, 116, 158, 13, 10, 4, Colors.white);
    _rrect(canvas, 131, 158, 13, 10, 4, Colors.white);

    _oval(canvas, 96, 98, 22, 22, Colors.white);
    _oval(canvas, 164, 98, 22, 22, Colors.white);
    _oval(canvas, 99, 98, 14, 14, const Color(0xFF4A28A0));
    _oval(canvas, 167, 98, 14, 14, const Color(0xFF4A28A0));
    _oval(canvas, 100, 98, 8, 8, const Color(0xFF150840));
    _oval(canvas, 168, 98, 8, 8, const Color(0xFF150840));
    canvas.drawCircle(_p(104, 91), _sx(5), Paint()..color = Colors.white);
    canvas.drawCircle(_p(172, 91), _sx(5), Paint()..color = Colors.white);
    canvas.drawCircle(_p(95, 103), _sx(2.5),
        Paint()..color = Colors.white.withValues(alpha: 0.7));
    canvas.drawCircle(_p(163, 103), _sx(2.5),
        Paint()..color = Colors.white.withValues(alpha: 0.7));

    _oval(canvas, 72, 124, 18, 12, const Color(0xFFF060A0), opacity: 0.38);
    _oval(canvas, 188, 124, 18, 12, const Color(0xFFF060A0), opacity: 0.38);

    canvas.drawPath(
        Path()
          ..moveTo(_p(78, 80).dx, _p(78, 80).dy)
          ..quadraticBezierTo(
              _p(96, 72).dx, _p(96, 72).dy, _p(112, 78).dx, _p(112, 78).dy),
        sp);
    canvas.drawPath(
        Path()
          ..moveTo(_p(148, 78).dx, _p(148, 78).dy)
          ..quadraticBezierTo(
              _p(164, 72).dx, _p(164, 72).dy, _p(182, 80).dx, _p(182, 80).dy),
        sp);

    void star(double tx, double ty, double rot, double r, Color color) {
      canvas.save();
      canvas.translate(_p(tx, ty).dx, _p(tx, ty).dy);
      canvas.rotate(rot * pi / 180);
      final path = Path();
      for (int i = 0; i < 10; i++) {
        final a = (i * 36 - 90) * pi / 180;
        final rad = i.isEven ? r : r * 0.45;
        final pt = Offset(cos(a) * _sx(rad), sin(a) * _sy(rad));
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = color);
      canvas.restore();
    }

    star(18, 42, 15, 10, const Color(0xFFFFD93D));
    star(234, 54, -10, 8, const Color(0xFFFFD93D));
    canvas.drawCircle(_p(30, 95), _sx(4),
        Paint()..color = const Color(0xFFFFD93D).withValues(alpha: 0.9));
    canvas.drawCircle(_p(24, 85), _sx(2.5),
        Paint()..color = const Color(0xFFFFD93D).withValues(alpha: 0.7));
    canvas.drawCircle(_p(228, 100), _sx(4),
        Paint()..color = const Color(0xFFFF9DE2).withValues(alpha: 0.9));
    canvas.drawCircle(_p(235, 90), _sx(2.5),
        Paint()..color = const Color(0xFFFF9DE2).withValues(alpha: 0.7));
  }

  @override
  bool shouldRepaint(_HippoPainter o) => false;
}
