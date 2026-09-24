import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'package:hippolulu/language_picker.dart';
import 'package:hippolulu/locale_provider.dart';
import 'level_selection.dart';
import 'puzzle_theme_selections.dart';
import 'matching_theme_select.dart';
import 'matching_game.dart';
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
                  builder: (navCtx) => const ThemeSelectionScreen(),
                ),
              );
            } else if (modeId == 'matching') {
              await Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (navCtx) => const MatchingThemeSelectionScreen(),
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
// How much bigger the "Bir Oyun Seç!" pill (and the spacing around it)
// gets on a tablet vs. a phone. Shared by MainMenu (for positioning) and
// _SectionPill (for its own size) so the two always stay in sync — change
// this one number to make the pill bigger/smaller everywhere at once.
const double kSectionPillTabletScale = 1.8;

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
  final String cardAsset;

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
    required this.cardAsset,
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
        cardAsset: 'assets/cards/puzzle_card.webp',
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
        cardAsset: 'assets/cards/matching_card.webp',
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
        cardAsset: 'assets/cards/coloring_card.webp',
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
        cardAsset: 'assets/cards/number_card.webp',
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
    final l10n = AppLocalizations.of(context)!;
    final screenW = MediaQuery.of(context).size.width;
    final isTablet = screenW > 600;
    // Same scale _SectionPill computes internally for its own size — kept
    // in sync here so the *positioning* around it (how far it pokes above
    // the frame) grows together with the pill itself instead of staying
    // a fixed phone-tuned offset.
    final pillScale = isTablet ? kSectionPillTabletScale : 1.0;

    return Scaffold(
      body: SceneBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ── TOP BAR ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 3, 16, 2),
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
                    horizontal: isTablet ? 15 : 26,
                    vertical: isTablet ? 20 : 18,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        // Scales with the same factor _SectionPill uses
                        // for its own size — otherwise a much taller
                        // tablet pill sinks further down into the frame
                        // below it instead of just sitting proportionally
                        // higher above it, like on phone.
                        padding: EdgeInsets.only(top: 15 * pillScale),
                        child: _GameFrame(
                          child:
                              _GameModeGrid(onModeSelect: widget.onModeSelect),
                        ),
                      ),
                      Positioned(
                        top: -17 * pillScale,
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
//  HERO STACK
// ─────────────────────────────────────────────
class _HeroStack extends StatelessWidget {
  final String tagline;

  const _HeroStack({
    required this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isTablet = screenW > 600;
    final logoWidth = isTablet ? 1000.0 : 350.0;
    final logoHeight = logoWidth / 1.74;
    final hippoWidth = isTablet ? 600.0 : 180.0;
    final hippoHeight = hippoWidth / 0.945;

    final stackHeight = isTablet ? 710.0 : 200.0;

    return SizedBox(
      width: double.infinity,
      height: stackHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -35,
            child: SizedBox(
              width: logoWidth,
              height: logoHeight,
              child: Image.asset(
                'assets/images/logo.webp',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: isTablet ? 280 : 80,
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
//  DASHED BORDER PAINTER
// ─────────────────────────────────────────────
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
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
//  SECTION PILL ("🎮 Bir Oyun Seç!")
// ─────────────────────────────────────────────
class _SectionPill extends StatelessWidget {
  final String label;

  const _SectionPill({required this.label});

  @override
  Widget build(BuildContext context) {
    // Same isTablet pattern the rest of this screen (_HeroStack, the game
    // card panel) already uses — this pill just wasn't wired up to it
    // before, so it stayed phone-sized even on a tablet while everything
    // around it scaled up.
    final screenW = MediaQuery.of(context).size.width;
    final isTablet = screenW > 600;
    final scale = isTablet ? kSectionPillTabletScale : 1.0;

    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: const Color(0xFFFFC94D),
        radius: 999,
        strokeWidth: 1 * scale,
        dashWidth: 4 * scale,
        dashGap: 4 * scale,
        inset: 4 * scale,
      ),
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 253, 241, 217),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF643CC8).withValues(alpha: 0.15),
              blurRadius: 10 * scale,
              offset: Offset(0, 3 * scale),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Baloo2 ExtraBold',
            fontWeight: FontWeight.bold,
            fontSize: 18 * scale,
            color: const Color(0xFF5C28A0),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  GAME FRAME (updated for 3D cream border)
// ─────────────────────────────────────────────
class _GameFrame extends StatelessWidget {
  final Widget child;

  const _GameFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF1D9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFFBE4C5),
          width: 6,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8C531B).withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────
//  GAME MODE GRID (Görsel 2 Tasarımına Uygun)
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

    // Görsel 2'deki kart yüksekliği ve dikey orana ulaşmak için aspect ratio 0.58 olarak güncellendi.
    double childAspectRatio =
        (screenW > 600) ? 0.65 : (isLandscape ? 1.05 : 0.71);

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: crossAxisCount,
          //crossAxisSpacing: 2, // Kartlar arasındaki yatay boşluk azaltıldı
          //mainAxisSpacing: 2, // Kartlar arasındaki dikey boşluk azaltıldı
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

class _GameModeCardState extends State<_GameModeCard> {
  double _pressScale = 1.0;
  double _pressY = 0.0;

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      mode.cardAsset,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: constraints.maxHeight * 0.55,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mode.label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: 'Baloo2 ExtraBold',
                            fontWeight: FontWeight.bold,
                            fontSize: constraints.maxWidth * 0.100,
                            color: mode.textColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.003),
                        Text(
                          mode.sublabel,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: 'Baloo2 ExtraBold',
                            fontSize: constraints.maxWidth * 0.075,
                            fontWeight: FontWeight.w500,
                            color: mode.textColor.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //if (mode.locked)
                  // Positioned(
                  //   left: constraints.maxWidth * 0.36,
                  //   right: constraints.maxWidth * 0.09,
                  //   top: constraints.maxHeight * 0.725,
                  //   bottom: constraints.maxHeight * 0.175,
                  //   child: Align(
                  //     alignment: Alignment.centerLeft,
                  //     child: Text(
                  //       AppLocalizations.of(context)!.locked,
                  //       textAlign: TextAlign.left,
                  //       maxLines: 1,
                  //       style: TextStyle(
                  //         fontFamily: 'Baloo2 ExtraBold',
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: constraints.maxWidth * 0.085,
                  //         color: const Color(0xFF7854B8),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SCENE BACKGROUND
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
