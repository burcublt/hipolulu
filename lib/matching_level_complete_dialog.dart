import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hippolulu/l10n/app_localizations.dart';

Future<void> showMatchingLevelCompleteDialog({
  required BuildContext context,
  required int level,
  required String characterAsset,
  required bool hasNextLevel,
  required VoidCallback onNextLevel,
  required VoidCallback onRetry,
  required VoidCallback onMenu,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Level Complete',
    barrierColor: Colors.black.withValues(alpha: 0.50),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (_, __, ___) => MatchingLevelCompleteDialog(
      level: level,
      characterAsset: characterAsset,
      hasNextLevel: hasNextLevel,
      onNextLevel: onNextLevel,
      onRetry: onRetry,
      onMenu: onMenu,
    ),
    transitionBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class MatchingLevelCompleteDialog extends StatelessWidget {
  final int level;
  final String characterAsset;
  final bool hasNextLevel;
  final VoidCallback onNextLevel;
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  const MatchingLevelCompleteDialog({
    super.key,
    required this.level,
    required this.characterAsset,
    required this.hasNextLevel,
    required this.onNextLevel,
    required this.onRetry,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final isLandscape = w > h;
            final isTablet = math.min(w, h) >= 600;

            if (isLandscape) {
              return _buildLandscape(context, constraints);
            }

            final panelWidth = isLandscape
                ? (w * 0.48).clamp(420.0, 620.0)
                : isTablet
                    ? (w * 0.68).clamp(470.0, 640.0)
                    : (w * 0.88).clamp(310.0, 430.0);

            final characterSize = isLandscape
                ? 128.0
                : isTablet
                    ? 175.0
                    : 145.0;

            final overlap = characterSize * 0.54;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: isLandscape ? 14 : 22,
                ),
                child: SizedBox(
                  width: panelWidth,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // Main cream panel. Character overlaps this panel from above.
                      Container(
                        margin: EdgeInsets.only(top: overlap),
                        padding: EdgeInsets.fromLTRB(
                          isTablet ? 30 : 22,
                          characterSize * 0.48,
                          isTablet ? 30 : 22,
                          isTablet ? 28 : 22,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFCF3),
                          borderRadius:
                              BorderRadius.circular(isTablet ? 38 : 30),
                          border: Border.all(
                            color: const Color(0xFFFFC43D),
                            width: 3.2,
                          ),
                          boxShadow: [
                            const BoxShadow(
                              color: Color(0xFFD89A00),
                              offset: Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              offset: const Offset(0, 14),
                              blurRadius: 28,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                l10n.levelDone(l10n.levelLabel(level)),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Baloo2 ExtraBold',
                                  color: const Color(0xFF6425D0),
                                  fontSize: isTablet ? 40 : 31,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            SizedBox(height: isTablet ? 20 : 16),
                            const _ThreeStars(),
                            SizedBox(height: isTablet ? 26 : 22),
                            if (hasNextLevel)
                              _PrimaryButton(
                                // Important: no pair/card count here.
                                label: l10n.levelLabel(level + 1),
                                isTablet: isTablet,
                                onTap: onNextLevel,
                              )
                            else
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  l10n.beatAllLevels,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Baloo2 ExtraBold',
                                    color: const Color(0xFF6425D0),
                                    fontSize: isTablet ? 22 : 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            SizedBox(height: isTablet ? 18 : 15),
                            Row(
                              children: [
                                Expanded(
                                  child: _SecondaryButton(
                                    icon: Icons.refresh_rounded,
                                    label: l10n.retry,
                                    isTablet: isTablet,
                                    onTap: onRetry,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SecondaryButton(
                                    icon: Icons.home_rounded,
                                    label: l10n.menu,
                                    isTablet: isTablet,
                                    onTap: onMenu,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Celebration rays behind the dynamic character.
                      Positioned(
                        top: 0,
                        child: SizedBox(
                          width: characterSize * 1.75,
                          height: characterSize * 1.18,
                          child: CustomPaint(
                            painter: _CelebrationRaysPainter(),
                          ),
                        ),
                      ),

                      // Dynamic character for each level.
                      Positioned(
                        top: 0,
                        child: SizedBox(
                          width: characterSize * 1.18,
                          height: characterSize,
                          child: Image.asset(
                            characterAsset,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Small decorative stars around the character.
                      Positioned(
                        top: characterSize * 0.18,
                        left: panelWidth * 0.08,
                        child: const _DecorStar(
                          size: 29,
                          color: Color(0xFFFFC72E),
                          rotation: -0.18,
                        ),
                      ),
                      Positioned(
                        top: characterSize * 0.36,
                        right: panelWidth * 0.08,
                        child: const _DecorStar(
                          size: 27,
                          color: Color(0xFFFF66AE),
                          rotation: 0.18,
                        ),
                      ),
                      Positioned(
                        top: characterSize * 0.04,
                        right: panelWidth * 0.19,
                        child: const _DecorStar(
                          size: 18,
                          color: Color(0xFF67D7FF),
                          rotation: 0.10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLandscape(BuildContext context, BoxConstraints constraints) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            width: math.min(700.0, constraints.maxWidth - 32),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF3),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFFFC43D), width: 3.2),
              boxShadow: const [
                BoxShadow(color: Color(0xFFD89A00), offset: Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 160,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(characterAsset,
                          height: 140, fit: BoxFit.contain),
                      const FittedBox(child: _ThreeStars()),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n.levelDone(l10n.levelLabel(level)),
                          maxLines: 1,
                          style: const TextStyle(
                            fontFamily: 'Baloo2 ExtraBold',
                            color: Color(0xFF6425D0),
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (hasNextLevel)
                        _PrimaryButton(
                          label: l10n.levelLabel(level + 1),
                          isTablet: false,
                          onTap: onNextLevel,
                        )
                      else
                        Text(
                          l10n.beatAllLevels,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF6425D0),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                              child: _SecondaryButton(
                            icon: Icons.refresh_rounded,
                            label: l10n.retry,
                            isTablet: false,
                            onTap: onRetry,
                          )),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _SecondaryButton(
                            icon: Icons.home_rounded,
                            label: l10n.menu,
                            isTablet: false,
                            onTap: onMenu,
                          )),
                        ],
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

class _ThreeStars extends StatelessWidget {
  const _ThreeStars();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: const Offset(0, 4),
                child: const Icon(
                  Icons.star_rounded,
                  size: 50,
                  color: Color(0xFFE39A00),
                ),
              ),
              const Icon(
                Icons.star_rounded,
                size: 50,
                color: Color(0xFFFFC928),
              ),
              Positioned(
                top: 8,
                left: 13,
                child: Container(
                  width: 9,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _DecorStar extends StatelessWidget {
  final double size;
  final Color color;
  final double rotation;

  const _DecorStar({
    required this.size,
    required this.color,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Icon(
        Icons.star_rounded,
        size: size,
        color: color,
        shadows: const [
          Shadow(
            color: Color(0x33000000),
            offset: Offset(0, 3),
            blurRadius: 3,
          ),
        ],
      ),
    );
  }
}

class _CelebrationRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.55);
    final innerRadius = size.shortestSide * 0.22;
    final outerRadius = size.shortestSide * 0.52;
    final paint = Paint()
      ..color = const Color(0xFFFFD94D).withValues(alpha: 0.48);

    const rayCount = 12;
    for (int i = 0; i < rayCount; i++) {
      final a = (math.pi * 2 / rayCount) * i - math.pi / 2;
      const half = math.pi / 34;
      final path = Path()
        ..moveTo(
          center.dx + math.cos(a - half) * innerRadius,
          center.dy + math.sin(a - half) * innerRadius,
        )
        ..lineTo(
          center.dx + math.cos(a) * outerRadius,
          center.dy + math.sin(a) * outerRadius,
        )
        ..lineTo(
          center.dx + math.cos(a + half) * innerRadius,
          center.dy + math.sin(a + half) * innerRadius,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isTablet;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Reserve space for the raised base before the secondary action row.
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFD99A00),
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: isTablet ? 70 : 61,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(999),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFE766), Color(0xFFFFC51E)],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFFFF2A4),
                    width: 3,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rocket_launch_rounded,
                        color: const Color(0xFF713600),
                        size: isTablet ? 29 : 25,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: 'Baloo2 ExtraBold',
                              color: const Color(0xFF633000),
                              fontSize: isTablet ? 23 : 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: const Color(0xFF713600),
                        size: isTablet ? 28 : 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isTablet;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isTablet ? 59 : 51,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F1FF),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFFD9C6FF),
                width: 2.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF6628C8),
                  size: isTablet ? 25 : 21,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Baloo2 ExtraBold',
                        color: const Color(0xFF6628C8),
                        fontSize: isTablet ? 18 : 15,
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
    );
  }
}
