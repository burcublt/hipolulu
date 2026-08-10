import 'package:flutter/material.dart';
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
              fontFamily: 'Fredoka Bold',
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
class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({Key? key}) : super(key: key);

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => MainMenu(
              onModeSelect: (modeId) {
                if (modeId == 'puzzles') {
                  Navigator.of(ctx).push(
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
                  Navigator.of(ctx).push(
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
              },
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18B5F6), // Görselin gökyüzü mavisi
      body: Align(
        alignment: Alignment.bottomCenter, // Görseli en alta yapıştırır
        child: Image.asset(
          'assets/images/splash.png',
          fit: BoxFit
              .fitWidth, // Genişliğe göre oturtur, alt çimenleri tabana sıfırlar
        ),
      ),
    );
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
class MainMenu extends StatelessWidget {
  final void Function(String) onModeSelect;
  const MainMenu({Key? key, required this.onModeSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SceneBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ── TOP BAR ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StarsBadge(starsText: l10n.starsBadge),
                    const _SettingsButton(),
                  ],
                ),
              ),

              // ── TITLE + HIPPO ROW ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: _TitleStack(tagline: l10n.tagline),
                      ),
                    ),
                    _HippoImage(),
                  ],
                ),
              ),

              // ── SECTION LABEL ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: _SectionLabel(label: l10n.chooseGame),
              ),

              // ── GAME MODE GRID ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: _GameModeGrid(onModeSelect: onModeSelect),
              ),

              // ── FOOTER ──
              _ComingSoonFooter(text: l10n.comingSoon),
              const SizedBox(height: 18),
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
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF643CC8).withValues(alpha: 0.15),
            blurRadius: 10,
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
              fontFamily: 'Fredoka',
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF6B3FA0),
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF643CC8).withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.language_rounded,
              size: 22, color: Color(0xFF7B6AB0)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TITLE STACK
// ─────────────────────────────────────────────
class _TitleStack extends StatelessWidget {
  final String tagline;

  const _TitleStack({required this.tagline});

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final titleStyle = TextStyle(
      fontFamily: 'Fredoka Bold',
      fontSize: isLandscape ? 30 : 44,
      height: 1.0,
      color: const Color(0xFF5C28A0),
      letterSpacing: 1,
      shadows: const [
        Shadow(color: Color(0xFFD0A8F0), offset: Offset(0, 4)),
        Shadow(
          color: Color(0x2E5C28A0),
          offset: Offset(0, 6),
          blurRadius: 14,
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hippo', style: titleStyle),
        const SizedBox(height: 0),
        Text('Lulu', style: titleStyle),
        const SizedBox(height: 4),
        Text(
          tagline,
          style: TextStyle(
            fontFamily: 'Fredoka SemiBold',
            fontSize: isLandscape ? 12 : 14,
            color: const Color(0xFF7854B8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  HIPPO IMAGE
// ─────────────────────────────────────────────
class _HippoImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final size = isLandscape ? 110.0 : 190.0;
    
    return SizedBox(
      width: size,
      height: size,
      child: Transform.scale(
        scale: 1.35,
        child: Image.asset(
          'assets/images/hippo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SECTION LABEL
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final divider = Expanded(
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          color: const Color(0xFF5C28A0).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );

    return Row(
      children: [
        divider,
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Fredoka Bold',
            fontSize: 17,
            color: Color(0xFF5C28A0),
          ),
        ),
        const SizedBox(width: 8),
        divider,
      ],
    );
  }
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
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 800 ? 4 : (screenWidth > 500 ? 3 : 2);

    return Align(
        alignment: Alignment.topCenter,
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1, // Makes the cards wider
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(modes.length, (i) {
            return _GameModeCard(
              mode: modes[i],
              index: i,
              onTap: modes[i].locked ? null : () => onModeSelect(modes[i].id),
            );
          }),
        ));
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

    // Emoji wiggle
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

    // TAP TO PLAY pulse
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (!widget.mode.locked) {
      Timer(const Duration(milliseconds: 600), () {
        if (mounted) {
          _pulseCtrl.repeat(
            period: const Duration(milliseconds: 1400 + 1000),
            reverse: true,
          );
        }
      });
    }

    // NEW ribbon wobble
    _ribbonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (!widget.mode.locked) {
      _ribbonCtrl.repeat(reverse: true);
    }

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
    final cardBg = mode.locked ? const Color(0xFFD4CEF0) : mode.bg;
    final cardShadow = mode.locked ? const Color(0xFFA8A0CC) : mode.shadow;

    return GestureDetector(
      onTapDown: (_) {
        if (!mode.locked) {
          setState(() {
            _pressScale = mode.locked ? 0.96 : 0.91;
            _pressY = mode.locked ? 0 : 5;
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
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // ── CARD BODY ──
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: mode.locked
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.65),
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cardShadow,
                      offset: const Offset(0, 7),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      offset: const Offset(0, 12),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glare
                      if (!mode.locked)
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
                                  Colors.white.withValues(alpha: 0.45),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Content
                      Padding(
                          padding: const EdgeInsets.fromLTRB(10, 18, 10, 16),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Emoji circle
                                _EmojiCircle(
                                  emoji: mode.emoji,
                                  locked: mode.locked,
                                  controller: _emojiCtrl,
                                ),
                                const SizedBox(height: 5),

                                // Label
                                Text(
                                  mode.label,
                                  style: TextStyle(
                                    fontFamily: 'Fredoka Bold',
                                    fontSize: 17,
                                    color: mode.locked
                                        ? const Color(0xFF8878B8)
                                        : mode.textColor,
                                    letterSpacing: 0.5,
                                    shadows: mode.locked
                                        ? null
                                        : [
                                            const Shadow(
                                              color: Colors.white54,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                ),

                                // Sublabel
                                Text(
                                  mode.sublabel,
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: mode.locked
                                        ? const Color(0xFFA898C8)
                                        : mode.textColor
                                            .withValues(alpha: 0.73),
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Lock / Play badge
                                if (mode.locked)
                                  _LockBadge(
                                      label:
                                          AppLocalizations.of(context)!.locked)
                                else
                                  _PlayBadge(
                                    label:
                                        AppLocalizations.of(context)!.tapToPlay,
                                    textColor: mode.textColor,
                                    controller: _pulseCtrl,
                                  ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              //── NEW! RIBBON ──
              if (!mode.locked)
                Positioned(
                  top: -9,
                  right: -4,
                  child: _NewRibbon(
                    label: AppLocalizations.of(context)!.newRibbon,
                    controller: _ribbonCtrl,
                  ),
                ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_rounded, size: 11, color: Color(0xFF7868A8)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 11,
              color: Color(0xFF7868A8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
            fontFamily: 'Fredoka',
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
            fontFamily: 'Fredoka',
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
        opacity: 0.5 + 0.5 * _ctrl.value,
        child: child,
      ),
      child: Text(
        widget.text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 13,
          color: Color(0xFF7854B8),
          fontWeight: FontWeight.w500,
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
              height: MediaQuery.of(context).size.height * 0.60,
              child: CustomPaint(painter: _SkyPainter()),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.28,
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
