import 'catalog_service.dart';
import 'package:flutter/services.dart';
import 'unlock_screen.dart';
import 'package:flutter/material.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'matching_game.dart';

// ============================================================================
// ASSET PATHS
// ============================================================================

class _MatchingAssets {
  const _MatchingAssets._();

  static const String backgroundPortrait =
      'assets/matching/background/matching_background_portrait.webp';

  static const String backgroundLandscape =
      'assets/matching/background/matching_background_landscape.webp';

  static const String headerIcon =
      'assets/matching/ui/matching_header_icon.webp';
}

// ============================================================================
// DATA MODEL
// ============================================================================

Color matchingThemeColor(String id) =>
    const <String, Color>{
      'animals': Color(0xFFFFE9A9),
      'fruits': Color(0xFFFFD8E8),
      'vegetables': Color(0xFFD9F7D4),
      'vehicles': Color(0xFFD6EDFF),
      'dinosaurs': Color(0xFFE6F5B8),
      'space': Color(0xFFE8D8FF),
      'underwater': Color(0xFFD4F5FF),
      'farm': Color(0xFFFFE8C9),
      'insects': Color(0xFFDEF7D4),
      'fairytales': Color(0xFFFFDFEA),
      'jobs': Color(0xFFD7F0FF),
      'nature': Color(0xFFFFEDC5),
      'foods': Color(0xFFFFE8C9),
    }[id] ??
    const Color(0xFFFFEDC5);

class MatchingThemeData {
  final bool locked;
  final String id;
  final String title;
  final String imagePath;
  final Color color;

  const MatchingThemeData({
    this.locked = false,
    required this.id,
    required this.title,
    required this.imagePath,
    required this.color,
  });
}

// ============================================================================
// SCREEN
// ============================================================================

class MatchingThemeSelectionScreen extends StatelessWidget {
  const MatchingThemeSelectionScreen({
    super.key,
  });

  // ==========================================================================
  // THEME DATA
  // ==========================================================================

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return CatalogLoader(
        path: 'games/matching/themes',
        builder: (context, data) {
          final themes = data
              .map((t) => MatchingThemeData(
                  id: t['id'],
                  title: t['title'],
                  imagePath: t['cover_url'] ?? '',
                  color: matchingThemeColor(t['id']),
                  locked: t['locked']))
              .toList();
          return Scaffold(
            backgroundColor: const Color(0xFFEAF7FF),
            body: Stack(
              children: [
                // ==================================================================
                // BACKGROUND
                // ==================================================================

                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isLandscape =
                          constraints.maxWidth > constraints.maxHeight;

                      return Image.asset(
                        isLandscape
                            ? _MatchingAssets.backgroundLandscape
                            : _MatchingAssets.backgroundPortrait,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      );
                    },
                  ),
                ),

                // Background'un kartlarla fazla karışmasını engelleyen
                // çok hafif beyaz overlay.
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),

                // ==================================================================
                // PAGE
                // ==================================================================

                SafeArea(
                  child: LayoutBuilder(
                    builder: (
                      BuildContext context,
                      BoxConstraints constraints,
                    ) {
                      final double width = constraints.maxWidth;
                      final double height = constraints.maxHeight;

                      final bool isLandscape = width > height;

                      final int columnCount = _getColumnCount(
                        width,
                        isLandscape,
                      );

                      final double spacing = _getGridSpacing(width);

                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // ========================================================
                          // HEADER AREA
                          // ========================================================

                          SliverToBoxAdapter(
                            child: _TopSection(
                              width: width,
                              isLandscape: isLandscape,
                            ),
                          ),

                          // ========================================================
                          // THEMES GRID
                          // ========================================================

                          SliverPadding(
                            padding: _getGridPadding(
                              width,
                              isLandscape,
                            ),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columnCount,
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: spacing,

                                // 1.0'a yakın olduğu için kartlar
                                // kare / oyuncak kutusu görünümünde.
                                childAspectRatio: 0.98,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (
                                  BuildContext context,
                                  int index,
                                ) {
                                  final MatchingThemeData theme = themes[index];

                                  return _MatchingThemeCard(
                                    theme: theme,
                                    onTap: () {
                                      _onThemeSelected(
                                        context,
                                        theme,
                                      );
                                    },
                                  );
                                },
                                childCount: themes.length,
                              ),
                            ),
                          ),

                          // Bottom safe space
                          const SliverToBoxAdapter(
                            child: SizedBox(
                              height: 32,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  // ==========================================================================
  // RESPONSIVE COLUMN COUNT
  // ==========================================================================

  static int _getColumnCount(
    double width,
    bool isLandscape,
  ) {
    // Phone portrait
    if (width < 600) {
      return 2;
    }

    // Large phone / small tablet
    if (width < 900) {
      return isLandscape ? 4 : 3;
    }

    // Tablet
    if (width < 1300) {
      return isLandscape ? 5 : 3;
    }

    // Very large tablet / desktop preview
    return isLandscape ? 6 : 4;
  }

  // ==========================================================================
  // GRID SPACING
  // ==========================================================================

  static double _getGridSpacing(
    double width,
  ) {
    if (width < 600) {
      return 12;
    }

    if (width < 1000) {
      return 16;
    }

    return 20;
  }

  // ==========================================================================
  // GRID PADDING
  // ==========================================================================

  static EdgeInsets _getGridPadding(
    double width,
    bool isLandscape,
  ) {
    double horizontal;

    if (width < 600) {
      horizontal = 18;
    } else if (width < 1000) {
      horizontal = 30;
    } else {
      horizontal = 46;
    }

    return EdgeInsets.fromLTRB(
      horizontal,
      isLandscape ? 16 : 22,
      horizontal,
      24,
    );
  }

  // ==========================================================================
  // THEME SELECT
  // ==========================================================================

  static void _onThemeSelected(
    BuildContext context,
    MatchingThemeData theme,
  ) {
    if (theme.locked) {
      showUnlockScreen(context, returnOrientations: DeviceOrientation.values);
      return;
    }
    debugPrint(
      'Matching theme selected: ${theme.id}',
    );

    MatchingTheme mappedTheme;
    switch (theme.id) {
      case 'animals':
        mappedTheme = MatchingTheme.animals;
        break;
      case 'fruits':
        mappedTheme = MatchingTheme.fruits;
        break;
      case 'vegetables':
        mappedTheme = MatchingTheme.vegetables;
        break;
      case 'foods':
        mappedTheme = MatchingTheme.foods;
        break;
      case 'vehicles':
        mappedTheme = MatchingTheme.vehicles;
        break;
      default:
        mappedTheme = MatchingTheme.objects;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MatchingGame(
          theme: mappedTheme,
          themeId: theme.id,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

// ============================================================================
// TOP SECTION
// ============================================================================

class _TopSection extends StatelessWidget {
  final double width;
  final bool isLandscape;

  const _TopSection({
    required this.width,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPhone = width < 600;

    final double horizontalPadding = isPhone ? 16 : 28;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        isPhone ? 8 : 14,
        horizontalPadding,
        0,
      ),
      child: Column(
        children: [
          // ==================================================================
          // BACK
          // ==================================================================

          Align(
            alignment: Alignment.centerLeft,
            child: _MatchingBackButton(
              compact: isLandscape,
            ),
          ),

          SizedBox(
            height: isLandscape ? 8 : 14,
          ),

          // ==================================================================
          // HEADER
          // ==================================================================

          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLandscape ? 620 : 680,
              ),
              child: _MatchingHeader(
                compact: isLandscape,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BACK BUTTON
// ============================================================================

class _MatchingBackButton extends StatelessWidget {
  final bool compact;

  const _MatchingBackButton({
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.maybePop(context);
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 18,
            vertical: compact ? 8 : 11,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: const Color(0xFF6126C8),
                size: compact ? 16 : 18,
              ),
              const SizedBox(
                width: 6,
              ),
              Text(
                AppLocalizations.of(context)!.back,
                style: TextStyle(
                  color: const Color(0xFF6126C8),
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 15 : 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================

class _MatchingHeader extends StatelessWidget {
  final bool compact;

  const _MatchingHeader({
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 22,
        vertical: compact ? 11 : 15,
      ),
      decoration: BoxDecoration(
        // Cream / white background
        color: const Color(0xFFFFFCF6).withValues(alpha: 0.97),

        borderRadius: BorderRadius.circular(
          compact ? 24 : 30,
        ),

        border: Border.all(
          color: const Color(0xFFFFC94C),
          width: 2.5,
        ),

        boxShadow: [
          // Yellow bottom depth
          BoxShadow(
            color: const Color(0xFFFFB52A).withValues(alpha: 0.35),
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),

          // Soft normal shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          // ==================================================================
          // HEADER ICON
          // ==================================================================

          Image.asset(
            _MatchingAssets.headerIcon,
            width: compact ? 58 : 78,
            height: compact ? 58 : 78,
            fit: BoxFit.contain,
          ),

          SizedBox(
            width: compact ? 10 : 16,
          ),

          // ==================================================================
          // HEADER TEXTS
          // ==================================================================

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ------------------------------------------------------------
                // TITLE
                // ------------------------------------------------------------

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context)!.matchingGameTitle,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 25 : 34,
                      fontWeight: FontWeight.w900,
                      color: const Color(
                        0xFF5720C9,
                      ),
                      height: 1,
                    ),
                  ),
                ),

                SizedBox(
                  height: compact ? 4 : 6,
                ),

                // ------------------------------------------------------------
                // SUBTITLE
                // ------------------------------------------------------------

                Text(
                  AppLocalizations.of(context)!.pickCategoryToMatch,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compact ? 13 : 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(
                      0xFF332080,
                    ),
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MATCHING THEME CARD
// ============================================================================

class _MatchingThemeCard extends StatelessWidget {
  final MatchingThemeData theme;
  final VoidCallback onTap;

  const _MatchingThemeCard({
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final double cardWidth = constraints.maxWidth;

        final double radius = _getRadius(cardWidth);

        final double titleFontSize = _getTitleFontSize(
          cardWidth,
        );

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              radius,
            ),
            child: Ink(
              decoration: BoxDecoration(
                color: theme.color,
                borderRadius: BorderRadius.circular(
                  radius,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.95),
                  width: cardWidth < 180 ? 2 : 2.5,
                ),
                boxShadow: [
                  // ----------------------------------------------------------
                  // COLORED BOTTOM DEPTH
                  // ----------------------------------------------------------

                  BoxShadow(
                    color: _darken(
                      theme.color,
                    ).withValues(alpha: 0.52),
                    offset: Offset(
                      0,
                      cardWidth < 180 ? 5 : 7,
                    ),
                    blurRadius: 0,
                  ),

                  // ----------------------------------------------------------
                  // NORMAL SHADOW
                  // ----------------------------------------------------------

                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    offset: const Offset(
                      0,
                      8,
                    ),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  cardWidth < 180 ? 9 : 13,
                ),
                child: Column(
                  children: [
                    // ========================================================
                    // IMAGE
                    // ========================================================

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          3,
                          2,
                          3,
                          4,
                        ),
                        child: theme.imagePath.isEmpty
                            ? Icon(Icons.restaurant_rounded,
                                size: cardWidth * 0.45,
                                color: const Color(0xFFDE9449))
                            : Image(
                                image: catalogImageProvider(theme.imagePath),
                                width: double.infinity,
                                fit: BoxFit.contain,

                                // Asset bulunamazsa uygulama crash olmasın.
                                errorBuilder: (
                                  BuildContext context,
                                  Object error,
                                  StackTrace? stackTrace,
                                ) {
                                  return Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      color: const Color(
                                        0xFF5720C9,
                                      ).withValues(
                                        alpha: 0.35,
                                      ),
                                      size: cardWidth * 0.30,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),

                    SizedBox(
                      height: cardWidth < 180 ? 4 : 6,
                    ),

                    // ========================================================
                    // TITLE
                    // ========================================================

                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: cardWidth < 180 ? 38 : 46,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFFFFCF4,
                        ).withValues(
                          alpha: 0.95,
                        ),
                        borderRadius: BorderRadius.circular(
                          999,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          if (theme.locked) ...[
                            const Icon(Icons.lock_rounded,
                                size: 18, color: Color(0xFF5720C9)),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            theme.title,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w900,
                              color: const Color(
                                0xFF271074,
                              ),
                              height: 1,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // CARD RADIUS
  // ==========================================================================

  double _getRadius(
    double width,
  ) {
    if (width < 150) {
      return 18;
    }

    if (width < 220) {
      return 22;
    }

    return 26;
  }

  // ==========================================================================
  // TITLE SIZE
  // ==========================================================================

  double _getTitleFontSize(
    double width,
  ) {
    if (width < 140) {
      return 14;
    }

    if (width < 180) {
      return 16;
    }

    if (width < 230) {
      return 18;
    }

    return 21;
  }

  // ==========================================================================
  // DARKEN
  // ==========================================================================

  Color _darken(
    Color color,
  ) {
    final HSLColor hsl = HSLColor.fromColor(color);

    final double lightness = (hsl.lightness - 0.18).clamp(
      0.0,
      1.0,
    );

    return hsl
        .withLightness(
          lightness,
        )
        .toColor();
  }
}
