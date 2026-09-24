import 'package:flutter/material.dart';

// ============================================================================
// LEVEL COMPLETE ASSETS
// ============================================================================

class MatchingCompleteAssets {
  const MatchingCompleteAssets._();

  static const String lion = 'assets/matching/level_complete/lion.webp';

  static const String cat = 'assets/matching/level_complete/cat.webp';

  static const String elephant = 'assets/matching/level_complete/elephant.webp';

  static const String fox = 'assets/matching/level_complete/fox.webp';

  static const String frog = 'assets/matching/level_complete/frog.webp';

  static const String giraffe = 'assets/matching/level_complete/giraffe.webp';
}

// ============================================================================
// LEVEL COMPLETE DATA
// ============================================================================

class MatchingLevelCompleteData {
  final int level;

  /// Üstte gösterilecek karakter.
  final String characterAsset;

  /// Kazanılan yıldız sayısı.
  final int stars;

  const MatchingLevelCompleteData({
    required this.level,
    required this.characterAsset,
    this.stars = 3,
  });
}

// ============================================================================
// LEVEL -> CHARACTER
// ============================================================================

MatchingLevelCompleteData getMatchingLevelCompleteData(
  int level,
) {
  // İstersen daha sonra bunu level config dosyana taşıyabiliriz.
  switch (level) {
    case 1:
      return const MatchingLevelCompleteData(
        level: 1,
        characterAsset: MatchingCompleteAssets.lion,
      );

    case 2:
      return const MatchingLevelCompleteData(
        level: 2,
        characterAsset: MatchingCompleteAssets.cat,
      );

    case 3:
      return const MatchingLevelCompleteData(
        level: 3,
        characterAsset: MatchingCompleteAssets.elephant,
      );

    case 4:
      return const MatchingLevelCompleteData(
        level: 4,
        characterAsset: MatchingCompleteAssets.fox,
      );

    case 5:
      return const MatchingLevelCompleteData(
        level: 5,
        characterAsset: MatchingCompleteAssets.frog,
      );

    case 6:
      return const MatchingLevelCompleteData(
        level: 6,
        characterAsset: MatchingCompleteAssets.giraffe,
      );

    default:
      // 6'dan fazla level olduğunda karakterleri tekrar döndürür.
      const characters = [
        MatchingCompleteAssets.lion,
        MatchingCompleteAssets.cat,
        MatchingCompleteAssets.elephant,
        MatchingCompleteAssets.fox,
        MatchingCompleteAssets.frog,
        MatchingCompleteAssets.giraffe,
      ];

      return MatchingLevelCompleteData(
        level: level,
        characterAsset: characters[(level - 1) % characters.length],
      );
  }
}

// ============================================================================
// SHOW DIALOG
// ============================================================================

Future<void> showMatchingLevelCompleteDialog({
  required BuildContext context,
  required int level,
  required VoidCallback onNextLevel,
  required VoidCallback onRetry,
  VoidCallback? onMenu,
}) {
  final data = getMatchingLevelCompleteData(level);

  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Level Complete',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(
      milliseconds: 350,
    ),
    pageBuilder: (
      context,
      animation,
      secondaryAnimation,
    ) {
      return MatchingLevelCompleteDialog(
        data: data,
        onNextLevel: onNextLevel,
        onRetry: onRetry,
        onMenu: onMenu,
      );
    },
    transitionBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.82,
            end: 1.0,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

// ============================================================================
// LEVEL COMPLETE DIALOG
// ============================================================================

class MatchingLevelCompleteDialog extends StatelessWidget {
  final MatchingLevelCompleteData data;

  final VoidCallback onNextLevel;
  final VoidCallback onRetry;
  final VoidCallback? onMenu;

  const MatchingLevelCompleteDialog({
    super.key,
    required this.data,
    required this.onNextLevel,
    required this.onRetry,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final isLandscape = width > height;
            final isTablet = width >= 600;

            // --------------------------------------------------------------
            // RESPONSIVE WIDTH
            // --------------------------------------------------------------

            double dialogWidth;

            if (isLandscape) {
              dialogWidth = width * 0.52;

              if (dialogWidth > 620) {
                dialogWidth = 620;
              }
            } else if (isTablet) {
              dialogWidth = width * 0.68;

              if (dialogWidth > 620) {
                dialogWidth = 620;
              }
            } else {
              dialogWidth = width * 0.88;
            }

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: SizedBox(
                  width: dialogWidth,
                  child: _CompleteCard(
                    data: data,
                    isLandscape: isLandscape,
                    isTablet: isTablet,
                    onNextLevel: onNextLevel,
                    onRetry: onRetry,
                    onMenu: onMenu,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// COMPLETE CARD
// ============================================================================

class _CompleteCard extends StatelessWidget {
  final MatchingLevelCompleteData data;

  final bool isLandscape;
  final bool isTablet;

  final VoidCallback onNextLevel;
  final VoidCallback onRetry;
  final VoidCallback? onMenu;

  const _CompleteCard({
    required this.data,
    required this.isLandscape,
    required this.isTablet,
    required this.onNextLevel,
    required this.onRetry,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final characterHeight = isLandscape
        ? 105.0
        : isTablet
            ? 150.0
            : 125.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // ==================================================================
        // MAIN PANEL
        // ==================================================================

        Container(
          margin: EdgeInsets.only(
            top: characterHeight * 0.55,
          ),
          padding: EdgeInsets.fromLTRB(
            isTablet ? 32 : 22,
            characterHeight * 0.55,
            isTablet ? 32 : 22,
            isTablet ? 28 : 22,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF3),
            borderRadius: BorderRadius.circular(
              isTablet ? 36 : 30,
            ),
            border: Border.all(
              color: const Color(0xFFFFC844),
              width: 3,
            ),
            boxShadow: [
              // Sarı alt derinlik.
              BoxShadow(
                color: const Color(0xFFE8A900),
                offset: Offset(
                  0,
                  isTablet ? 9 : 7,
                ),
                blurRadius: 0,
              ),

              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                offset: const Offset(0, 14),
                blurRadius: 28,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ============================================================
              // TITLE
              // ============================================================

              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Level ${data.level} Done!',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF5E24C7),
                    fontSize: isTablet ? 38 : 30,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),

              SizedBox(
                height: isTablet ? 12 : 9,
              ),

              // ============================================================
              // SUBTITLE
              // ============================================================

              Text(
                'Great job!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF34217F),
                  fontSize: isTablet ? 20 : 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(
                height: isTablet ? 20 : 16,
              ),

              // ============================================================
              // STARS
              // ============================================================

              _Stars(
                count: data.stars,
                large: isTablet,
              ),

              SizedBox(
                height: isTablet ? 26 : 20,
              ),

              // ============================================================
              // NEXT LEVEL
              // ============================================================

              _NextLevelButton(
                nextLevel: data.level + 1,
                onPressed: onNextLevel,
                large: isTablet,
              ),

              SizedBox(
                height: isTablet ? 16 : 12,
              ),

              // ============================================================
              // SECONDARY BUTTONS
              // ============================================================

              Row(
                children: [
                  Expanded(
                    child: _SecondaryButton(
                      icon: Icons.refresh_rounded,
                      text: 'Retry',
                      onPressed: onRetry,
                      large: isTablet,
                    ),
                  ),
                  if (onMenu != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SecondaryButton(
                        icon: Icons.home_rounded,
                        text: 'Menu',
                        onPressed: onMenu!,
                        large: isTablet,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // ==================================================================
        // CHARACTER
        // ==================================================================

        Positioned(
          top: 0,
          child: _Character(
            assetPath: data.characterAsset,
            height: characterHeight,
          ),
        ),

        // ==================================================================
        // DECORATIVE STARS
        // ==================================================================

        Positioned(
          top: characterHeight * 0.30,
          left: 18,
          child: const _DecorationStar(
            size: 27,
            color: Color(0xFFFFC62F),
          ),
        ),

        Positioned(
          top: characterHeight * 0.50,
          right: 18,
          child: const _DecorationStar(
            size: 22,
            color: Color(0xFFFF70AF),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// DYNAMIC CHARACTER
// ============================================================================

class _Character extends StatelessWidget {
  final String assetPath;
  final double height;

  const _Character({
    required this.assetPath,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height * 1.35,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,

        // Asset henüz eklenmemişse UI tamamen bozulmasın.
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const Center(
            child: Text(
              '🎉',
              style: TextStyle(
                fontSize: 70,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// STARS
// ============================================================================

class _Stars extends StatelessWidget {
  final int count;
  final bool large;

  const _Stars({
    required this.count,
    required this.large,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) {
          final active = index < count;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: large ? 7 : 5,
            ),
            child: Icon(
              Icons.star_rounded,
              size: large ? 58 : 46,
              color: active ? const Color(0xFFFFC72E) : const Color(0xFFE6DFCF),
              shadows: active
                  ? [
                      Shadow(
                        color: const Color(0xFFE09500).withValues(alpha: 0.40),
                        offset: const Offset(0, 4),
                        blurRadius: 3,
                      ),
                    ]
                  : null,
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// NEXT LEVEL BUTTON
// ============================================================================

class _NextLevelButton extends StatelessWidget {
  final int nextLevel;
  final VoidCallback onPressed;
  final bool large;

  const _NextLevelButton({
    required this.nextLevel,
    required this.onPressed,
    required this.large,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: large ? 70 : 60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFE45C),
                  Color(0xFFFFC51F),
                ],
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFFFFF2A5),
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFD99B00),
                  offset: Offset(0, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rocket_launch_rounded,
                    color: const Color(0xFF7C3500),
                    size: large ? 29 : 25,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Level $nextLevel',
                        maxLines: 1,
                        style: TextStyle(
                          color: const Color(0xFF633000),
                          fontSize: large ? 23 : 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: const Color(0xFF7C3500),
                    size: large ? 28 : 24,
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

// ============================================================================
// SECONDARY BUTTON
// ============================================================================

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final bool large;

  const _SecondaryButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    required this.large,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: large ? 58 : 50,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFFF),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFFD8C5FF),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF6628C8),
                    size: large ? 25 : 21,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        text,
                        maxLines: 1,
                        style: TextStyle(
                          color: const Color(0xFF6628C8),
                          fontSize: large ? 18 : 15,
                          fontWeight: FontWeight.w900,
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

// ============================================================================
// DECORATIVE STAR
// ============================================================================

class _DecorationStar extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorationStar({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Icon(
        Icons.star_rounded,
        size: size,
        color: color,
      ),
    );
  }
}
