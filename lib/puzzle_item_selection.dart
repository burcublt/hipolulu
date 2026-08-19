import 'package:flutter/material.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'package:hippolulu/l10n/game_l10n.dart';
import 'main.dart';
import 'asset_service.dart';
import 'puzzle_arena.dart';

// ─────────────────────────────────────────────
//  PUZZLE ITEM SELECTION SCREEN
// ─────────────────────────────────────────────
class PuzzleItemSelection extends StatefulWidget {
  final String themeId;
  final String themeTitle;
  final VoidCallback onBack;

  const PuzzleItemSelection({
    super.key,
    required this.themeId,
    required this.themeTitle,
    required this.onBack,
  });

  @override
  State<PuzzleItemSelection> createState() => _PuzzleItemSelectionState();
}

class _PuzzleItemSelectionState extends State<PuzzleItemSelection> {
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() async {
    await AssetService().load();
    final images = AssetService().getImagesForTheme(widget.themeId);
    if (mounted) {
      setState(() {
        _imagePaths = images;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    child: _BackButton(onTap: widget.onBack),
                  ),
                ),

                // ── TITLE ──
                Padding(
                  padding: EdgeInsets.fromLTRB(20, isLandscape ? 8 : 16, 20, 8),
                  child: _TitleSection(
                    themeTitle: widget.themeTitle,
                    isLandscape: isLandscape,
                  ),
                ),

                // ── ITEMS GRID ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  child: _imagePaths.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Text(
                              AppLocalizations.of(context)!.noPuzzlesFound,
                              style: const TextStyle(
                                fontFamily: 'Fredoka Bold',
                                fontSize: 18,
                                color: Color(0xFF7854B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = constraints.maxWidth > 700
                                ? 4
                                : (constraints.maxWidth > 480 ? 3 : 2);
                            double spacing = 14;
                            double itemWidth = (constraints.maxWidth -
                                    (spacing * (crossAxisCount - 1))) /
                                crossAxisCount;
                            double itemHeight = itemWidth * 1.15;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: List.generate(_imagePaths.length, (i) {
                                final path = _imagePaths[i];
                                return SizedBox(
                                  width: itemWidth,
                                  height: itemHeight,
                                  child: _PuzzleItemCard(
                                    imagePath: path,
                                    index: i,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (puzzleCtx) => PuzzleArena(
                                            imagePath: path,
                                            onBack: () =>
                                                Navigator.of(puzzleCtx).pop(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
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
              Text(AppLocalizations.of(context)!.back,
                  style: const TextStyle(
                    fontFamily: 'Fredoka Bold',
                    fontSize: 19,
                    color: Color(0xFF5C28A0),
                  )),
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
  final String themeTitle;
  final bool isLandscape;

  const _TitleSection({
    required this.themeTitle,
    this.isLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: isLandscape ? 0 : 4),
        Text(
          themeTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Fredoka Bold',
            fontSize: isLandscape ? 26 : 34,
            height: 1,
            color: const Color(0xFF5C28A0),
            shadows: const [
              Shadow(color: Color(0xFFD0A8F0), offset: Offset(0, 4)),
            ],
          ),
        ),
        SizedBox(height: isLandscape ? 2 : 4),
        Text(
          AppLocalizations.of(context)!.chooseYourPuzzle,
          style: const TextStyle(
            fontFamily: 'Fredoka Bold',
            fontSize: 15,
            color: Color(0xFF7854B8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  PUZZLE ITEM CARD (LARGE PREVIEW DESIGN)
// ─────────────────────────────────────────────
class _PuzzleItemCard extends StatefulWidget {
  final String imagePath;
  final int index;
  final VoidCallback onTap;

  const _PuzzleItemCard({
    required this.imagePath,
    required this.index,
    required this.onTap,
  });

  @override
  State<_PuzzleItemCard> createState() => _PuzzleItemCardState();
}

class _PuzzleItemCardState extends State<_PuzzleItemCard> {
  double _scale = 1.0;
  double _pressY = 0;

  @override
  Widget build(BuildContext context) {
    const gradient = [Color(0xFF90D0FF), Color(0xFF3A9EE0)];
    const shadow = Color(0xFF1A60B0);
    final border = const Color(0xFF64BEFF).withValues(alpha: 0.6);
    final name = AppLocalizations.of(context)!.itemTitle(widget.imagePath);

    return GestureDetector(
      onTapDown: (_) => setState(() {
        _scale = 0.95;
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
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: border, width: 3),
              boxShadow: [
                const BoxShadow(color: shadow, offset: Offset(0, 7)),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  offset: const Offset(0, 10),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Large Image Preview Container
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Hero(
                          tag: widget.imagePath,
                          child: Image.asset(
                            widget.imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Name & Play Icon
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Fredoka One',
                            fontSize: 17,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Color(0x2E000000),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
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
