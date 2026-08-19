import 'main.dart';
import 'asset_service.dart';
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

  PuzzleTheme({
    required this.id,
    required this.label,
    required this.sublabel,
    required this.gradientColors,
    required this.shadow,
    required this.border,
    required this.locked,
    required this.stars,
  });
}

List<PuzzleTheme> puzzleThemes(AppLocalizations l10n) => [
      PuzzleTheme(
        id: 'animals',
        label: l10n.themeAnimals,
        sublabel: l10n.puzzlesCount(12),
        gradientColors: const [Color(0xFFFFCE7A), Color(0xFFFF9940)],
        shadow: const Color(0xFFD4650A),
        border: const Color(0xFFFFD264).withValues(alpha: 0.6),
        locked: false,
        stars: 3,
      ),
      PuzzleTheme(
        id: 'vehicles',
        label: l10n.themeVehicles,
        sublabel: l10n.puzzlesCount(12),
        gradientColors: const [Color(0xFF90D0FF), Color(0xFF4A9EE8)],
        shadow: const Color(0xFF2A6AB8),
        border: const Color(0xFF90D0FF).withValues(alpha: 0.5),
        locked: false,
        stars: 0,
      ),
      PuzzleTheme(
        id: 'fruits',
        label: l10n.themeFruits,
        sublabel: l10n.puzzlesCount(10),
        gradientColors: const [Color(0xFFD4B8F8), Color(0xFF9E78D8)],
        shadow: const Color(0xFF6840B8),
        border: const Color(0xFFC4A8F0).withValues(alpha: 0.5),
        locked: false,
        stars: 0,
      ),
    ];

// ─────────────────────────────────────────────
//  LEVEL SELECTION SCREEN
// ─────────────────────────────────────────────
class LevelSelection extends StatelessWidget {
  final VoidCallback onBack;
  final void Function(PuzzleTheme) onSelect;

  const LevelSelection({Key? key, required this.onBack, required this.onSelect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themes = puzzleThemes(l10n);
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
                  padding: EdgeInsets.fromLTRB(20, isLandscape ? 8 : 16, 20, 8),
                  child: _TitleSection(l10n: l10n, isLandscape: isLandscape),
                ),

                // ── THEME CARDS ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
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
                            child: _PuzzleThemeCard(
                              theme: t,
                              index: themes.indexOf(t),
                              playNowLabel: l10n.playNow,
                              onTap: t.locked ? null : () => onSelect(t),
                            ),
                          );
                        }).toList(),
                      );
                    },
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chevron_left_rounded,
                  size: 24, color: Color(0xFF5C28A0)),
              const SizedBox(width: 2),
              Text(
                AppLocalizations.of(context)!.back,
                style: const TextStyle(
                  fontFamily: 'Fredoka Bold',
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
  final bool isLandscape;

  const _TitleSection({required this.l10n, this.isLandscape = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: isLandscape ? 0 : 4),
        Text(
          l10n.chooseTheme,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Fredoka Bold',
            fontSize: isLandscape ? 26 : 34,
            height: 1,
            color: const Color(0xFF5C28A0),
            shadows: const [
              Shadow(color: Color(0xFFD0B0F0), offset: Offset(0, 4)),
            ],
          ),
        ),
        SizedBox(height: isLandscape ? 2 : 4),
        Text(
          l10n.pickYourAdventure,
          style: TextStyle(
            fontFamily: 'Fredoka Bold',
            fontSize: isLandscape ? 13 : 16,
            color: const Color(0xFF7854B8),
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
class _PuzzleThemeCard extends StatefulWidget {
  final PuzzleTheme theme;
  final int index;
  final String playNowLabel;
  final VoidCallback? onTap;

  const _PuzzleThemeCard({
    required this.theme,
    required this.index,
    required this.playNowLabel,
    this.onTap,
  });

  @override
  State<_PuzzleThemeCard> createState() => _PuzzleThemeCardState();
}

class _PuzzleThemeCardState extends State<_PuzzleThemeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ribbonCtrl;
  double _scale = 1.0;
  String? _firstImagePath;

  @override
  void initState() {
    super.initState();
    _ribbonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (!widget.theme.locked) _ribbonCtrl.repeat(reverse: true);

    _loadImage();
  }

  Future<void> _loadImage() async {
    await AssetService().load();
    final images = AssetService().getImagesForTheme(widget.theme.id);
    if (images.isNotEmpty && mounted) {
      setState(() {
        _firstImagePath = images.first;
      });
    }
  }

  @override
  void dispose() {
    _ribbonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final lockedGradient = [const Color(0xFFDDD8F0), const Color(0xFFC0B8E0)];

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
        duration: const Duration(milliseconds: 100),
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
                    colors:
                        theme.locked ? lockedGradient : theme.gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: theme.border, width: 3),
                  boxShadow: theme.locked
                      ? [
                          const BoxShadow(
                            color: Color(0xFFA8A0C8),
                            offset: Offset(0, 5),
                            blurRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            offset: const Offset(0, 8),
                            blurRadius: 20,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: theme.shadow,
                            offset: const Offset(0, 7),
                            blurRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            offset: const Offset(0, 12),
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
                          color: Colors.white.withValues(alpha: 0.22),
                          border: Border(
                            right: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: _firstImagePath != null
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      _firstImagePath!,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 70,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.image_not_supported,
                                  color: Colors.white54, size: 40),
                        ),
                      ),

                      // Text panel
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                theme.label,
                                style: TextStyle(
                                  fontFamily: 'Fredoka Bold',
                                  fontSize: 22,
                                  color: theme.locked
                                      ? const Color(0xFF7870A8)
                                      : Colors.white,
                                  shadows: theme.locked
                                      ? null
                                      : [
                                          const Shadow(
                                            color: Color(0x2E000000),
                                            offset: Offset(0, 2),
                                            blurRadius: 6,
                                          ),
                                        ],
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                theme.sublabel,
                                style: TextStyle(
                                  fontFamily: 'Fredoka Bold',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: theme.locked
                                      ? const Color(0xFF9888C0)
                                      : Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              // Stars
                              if (!theme.locked) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: List.generate(3, (idx) {
                                    final filled = idx < theme.stars;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Icon(
                                        filled
                                            ? Icons.star_rounded
                                            : Icons.star_rounded,
                                        size: 16,
                                        color: filled
                                            ? const Color(0xFFFFD93D)
                                            : Colors.white
                                                .withValues(alpha: 0.35),
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
                        padding: const EdgeInsets.only(right: 16),
                        child: theme.locked
                            ? const SizedBox.shrink()
                            : Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
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
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.lock_rounded,
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
                      final angle = (-2 + 4 * _ribbonCtrl.value) * pi / 180;
                      return Transform.rotate(angle: angle, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF5F5F), Color(0xFFFF2020)],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFFF2020).withValues(alpha: 0.45),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.playNowLabel,
                        style: const TextStyle(
                          fontFamily: 'Fredoka Bold',
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
      builder: (_, child) =>
          Opacity(opacity: 0.6 + 0.4 * _ctrl.value, child: child),
      child: Text(
        widget.text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Fredoka Bold',
          fontSize: 14,
          color: Color(0xFF7854B8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
