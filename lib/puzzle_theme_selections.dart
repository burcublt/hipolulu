import 'package:flutter/material.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'puzzle_item_selection.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({
    super.key,
  });

  static const Color purple = Color(0xFF5426B8);
  static const Color darkPurple = Color(0xFF35147F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _ThemeSelectionLayout(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            );
          },
        ),
      ),
    );
  }
}

class _ThemeSelectionLayout extends StatelessWidget {
  final double width;
  final double height;

  const _ThemeSelectionLayout({
    required this.width,
    required this.height,
  });

  bool get isLandscape => width > height;

  bool get isTablet {
    final shortestSide = width < height ? width : height;
    return shortestSide >= 600;
  }

  int get columnCount {
    // Landscape:
    // Phone + Tablet = 4 columns
    if (isLandscape) {
      return 4;
    }

    // Portrait:
    // Phone + Tablet = 2 columns
    return 2;
  }

  double get horizontalPadding {
    if (isLandscape) {
      return isTablet ? 28 : 18;
    }

    return isTablet ? 32 : 16;
  }

  double get topPadding {
    if (isLandscape) {
      return isTablet ? 24 : 14;
    }

    return isTablet ? 28 : 16;
  }

  double get maxContentWidth {
    if (isLandscape) {
      return 1500;
    }

    return 900;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ----------------------------------------------------------
        // BACKGROUND
        // ----------------------------------------------------------

        Positioned.fill(
          child: Image.asset(
            // Portre  → background_theme.webp          (2:3)
            // Yatay   → background_theme_landscape.webp (16:9)
            isLandscape
                ? '${kThemeImagePath}background_theme_landscape.webp'
                : '${kThemeImagePath}background_theme.webp',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),

        // ----------------------------------------------------------
        // SOFT OVERLAY
        // ----------------------------------------------------------

        Positioned.fill(
          child: Container(
            color: Colors.white.withValues(alpha: 0.04),
          ),
        ),

        // ----------------------------------------------------------
        // CONTENT
        // ----------------------------------------------------------

        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxContentWidth,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: topPadding,
              ),
              child: Column(
                children: [
                  _buildHeader(context),
                  SizedBox(
                    height: isLandscape
                        ? (isTablet ? 20 : 12)
                        : (isTablet ? 24 : 14),
                  ),
                  Expanded(
                    child: _ThemeGrid(
                      columns: columnCount,
                      isLandscape: isLandscape,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final bool compact = !isTablet && isLandscape;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------------
          // TOP ROW: BACK BUTTON
          // --------------------------------------------------------
          Align(
            alignment: Alignment.centerLeft,
            child: _BackButton(
              compact: compact,
              isTablet: isTablet,
            ),
          ),

          SizedBox(height: isLandscape ? 4 : 10),

          // --------------------------------------------------------
          // TITLE SECTION
          // --------------------------------------------------------
          Align(
            alignment: Alignment.center,
            child: _HeaderTitle(
              compact: compact,
              isTablet: isTablet,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// HEADER TITLE
// ================================================================

class _HeaderTitle extends StatelessWidget {
  final bool compact;
  final bool isTablet;

  const _HeaderTitle({
    required this.compact,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final double titleSize = compact
        ? 20
        : isTablet
            ? 30
            : 24;

    final double subtitleSize = compact
        ? 12
        : isTablet
            ? 16
            : 13;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 22,
        vertical: isTablet ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(
          isTablet ? 28 : 22,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.chooseTheme,
            style: TextStyle(
              color: const Color(0xFF5426B8),
              fontSize: titleSize,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.pickYourAdventure,
            style: TextStyle(
              color: const Color(0xFF7040B8),
              fontSize: subtitleSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// BACK BUTTON
// ================================================================

class _BackButton extends StatefulWidget {
  final bool compact;
  final bool isTablet;

  const _BackButton({
    required this.compact,
    required this.isTablet,
  });

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final double iconSize = widget.compact
        ? 20
        : widget.isTablet
            ? 26
            : 24;

    final double fontSize = widget.compact
        ? 15
        : widget.isTablet
            ? 21
            : 19;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.88),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        Navigator.of(context).pop();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            widget.compact ? 10 : 14,
            widget.compact ? 6 : 10,
            widget.compact ? 14 : 20,
            widget.compact ? 6 : 10,
          ),
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
              Icon(
                Icons.chevron_left_rounded,
                size: iconSize,
                color: const Color(0xFF5C28A0),
              ),
              const SizedBox(width: 2),
              Text(
                AppLocalizations.of(context)!.back,
                style: TextStyle(
                  fontFamily: 'Baloo2 ExtraBold',
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  color: const Color(0xFF5C28A0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// THEME GRID
// ================================================================

class _ThemeGrid extends StatelessWidget {
  final int columns;
  final bool isLandscape;
  final bool isTablet;

  const _ThemeGrid({
    required this.columns,
    required this.isLandscape,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: isTablet ? 20 : 12,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing:
            isLandscape ? (isTablet ? 18 : 12) : (isTablet ? 18 : 12),
        mainAxisSpacing:
            isLandscape ? (isTablet ? 18 : 12) : (isTablet ? 18 : 12),
        childAspectRatio: _cardAspectRatio(),
      ),
      itemCount: puzzleThemeItems.length,
      itemBuilder: (context, index) {
        return ThemeCard(
          item: puzzleThemeItems[index],
          isTablet: isTablet,
          isLandscape: isLandscape,
        );
      },
    );
  }

  double _cardAspectRatio() {
    // Landscape mockup:
    // wide horizontal cards.
    if (isLandscape) {
      return isTablet ? 1.48 : 1.40;
    }

    // Portrait mockup:
    // cards are slightly taller.
    return isTablet ? 1.38 : 1.34;
  }
}

// ================================================================
// THEME CARD
// ================================================================

class ThemeCard extends StatelessWidget {
  final ThemeItem item;
  final bool isTablet;
  final bool isLandscape;

  const ThemeCard({
    super.key,
    required this.item,
    required this.isTablet,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          isTablet ? 28 : 20,
        ),
        onTap: item.locked
            ? null
            : () {
                final l10n = AppLocalizations.of(context)!;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (selectionCtx) => PuzzleItemSelection(
                      themeId: item.id,
                      themeTitle: item.titleGetter(l10n),
                      onBack: () => Navigator.of(selectionCtx).pop(),
                    ),
                  ),
                );
              },
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF4),
            borderRadius: BorderRadius.circular(
              isTablet ? 28 : 20,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.95),
              width: isTablet ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF422078).withValues(alpha: 0.20),
                blurRadius: isTablet ? 12 : 8,
                offset: Offset(
                  0,
                  isTablet ? 6 : 4,
                ),
              ),
            ],
          ),
          child: Column(
            children: [
              // --------------------------------------------------
              // IMAGE
              // --------------------------------------------------

              Expanded(
                flex: 64,
                child: _ThemeImage(
                  asset: item.asset,
                  isTablet: isTablet,
                ),
              ),

              // --------------------------------------------------
              // TEXT AREA
              // --------------------------------------------------

              Expanded(
                flex: 36,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 14 : 9,
                    vertical: isTablet ? 8 : 5,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ThemeTexts(
                          item: item,
                          isTablet: isTablet,
                        ),
                      ),

                      // ------------------------------------------------
                      // DURUM ROZETİ
                      // kilitli  -> mor kilit
                      // premium  -> PREMIUM etiketi + kilit
                      // açık     -> yeşil tik
                      // ------------------------------------------------

                      _StatusBadge(
                        item: item,
                        isTablet: isTablet,
                      ),
                    ],
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

// ================================================================
// THEME IMAGE
// ================================================================

class _ThemeImage extends StatelessWidget {
  final String asset;
  final bool isTablet;

  const _ThemeImage({
    required this.asset,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 7 : 5,
        isTablet ? 7 : 5,
        isTablet ? 7 : 5,
        0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          isTablet ? 20 : 14,
        ),
        child: Image.asset(
          asset,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

// ================================================================
// TEXTS
// ================================================================

class _ThemeTexts extends StatelessWidget {
  final ThemeItem item;
  final bool isTablet;

  const _ThemeTexts({
    required this.item,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.titleGetter(l10n),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF30118B),
            fontSize: isTablet ? 18 : 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          l10n.puzzlesCount(item.puzzleCount),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF6847A8),
            fontSize: isTablet ? 13 : 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// STATUS BADGE
// ================================================================

class _StatusBadge extends StatelessWidget {
  final ThemeItem item;
  final bool isTablet;

  const _StatusBadge({
    required this.item,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    /*
    // Premium tema: PREMIUM etiketi + kilit
    if (item.locked && item.isPremium) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PremiumLabel(isTablet: isTablet),
          SizedBox(width: isTablet ? 6 : 4),
          _LockIcon(isTablet: isTablet),
        ],
      );
    }
    */

    // Kilitli tema: sadece kilit
    if (item.locked) {
      return _LockIcon(isTablet: isTablet);
    }

    /*
    // Tamamlanmış tema: yeşil tik
    if (item.completed) {
      return _CheckIcon(isTablet: isTablet);
    }
    */

    // Açık ama tamamlanmamış: rozet yok
    return const SizedBox.shrink();
  }
}

// ================================================================
// CHECK ICON
// ================================================================

class _CheckIcon extends StatelessWidget {
  final bool isTablet;

  const _CheckIcon({
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final double size = isTablet ? 42 : 32;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF3FBF55),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: isTablet ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A8C3C).withValues(alpha: 0.30),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: size * 0.52,
      ),
    );
  }
}

// ================================================================
// PREMIUM LABEL
// ================================================================

class _PremiumLabel extends StatelessWidget {
  final bool isTablet;

  const _PremiumLabel({
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 8,
        vertical: isTablet ? 6 : 4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7B3FE4),
            Color(0xFF5B25C8),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3E168E).withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.diamond_rounded,
            color: const Color(0xFFFF7FD8),
            size: isTablet ? 15 : 11,
          ),
          SizedBox(width: isTablet ? 5 : 3),
          Text(
            'PREMIUM',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 11 : 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// LOCK ICON
// ================================================================

class _LockIcon extends StatelessWidget {
  final bool isTablet;

  const _LockIcon({
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final double size = isTablet ? 42 : 32;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF5B25C8),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: isTablet ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3E168E).withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.lock_rounded,
        color: Colors.white,
        size: size * 0.48,
      ),
    );
  }
}

// ================================================================
// DATA MODEL
// ================================================================

class ThemeItem {
  final String id;
  final String Function(AppLocalizations l10n) titleGetter;
  final int puzzleCount;
  final String asset;
  final bool locked;

  /// Tema tamamlandıysa sağ altta yeşil tik gösterilir.
  final bool completed;

  /// Premium (satın alınabilir) temalarda kilit ikonunun üstünde
  /// elmas ikonlu "PREMIUM" rozeti gösterilir.
  final bool isPremium;

  const ThemeItem({
    required this.id,
    required this.titleGetter,
    required this.puzzleCount,
    required this.asset,
    required this.locked,
    this.completed = false,
    this.isPremium = false,
  });
}

// ================================================================
// THEME DATA
// ================================================================

/// Tüm tema görsellerinin bulunduğu klasör.
/// Yeni bir tema eklerken sadece dosya adını yazman yeterli.
const String kThemeImagePath = 'assets/images/puzzle_theme/';

List<ThemeItem> puzzleThemeItems = [
  ThemeItem(
    id: 'animals',
    titleGetter: (l10n) => l10n.themeAnimals,
    puzzleCount: 12,
    asset: '${kThemeImagePath}animal_theme.webp',
    locked: false,
    completed: true,
  ),
  ThemeItem(
    id: 'vehicles',
    titleGetter: (l10n) => l10n.themeVehicles,
    puzzleCount: 12,
    asset: '${kThemeImagePath}vehicle_theme.webp',
    locked: false,
    completed: true,
  ),
  ThemeItem(
    id: 'fruits',
    titleGetter: (l10n) => l10n.themeFruits,
    puzzleCount: 10,
    asset: '${kThemeImagePath}fruit_theme.webp',
    locked: false,
    completed: true,
  ),
  ThemeItem(
    id: 'space',
    titleGetter: (l10n) => l10n.themeSpace,
    puzzleCount: 10,
    asset: '${kThemeImagePath}space_theme.webp',
    locked: true,
  ),
  ThemeItem(
    id: 'dinosaur',
    titleGetter: (l10n) => l10n.themeDinosaur,
    puzzleCount: 10,
    asset: '${kThemeImagePath}dinosaurs_theme.webp',
    locked: true,
    isPremium: true,
  ),
  ThemeItem(
    id: 'underwater',
    titleGetter: (l10n) => l10n.themeUnderwater,
    puzzleCount: 10,
    asset: '${kThemeImagePath}underwater_theme.webp',
    locked: true,
  ),
];
