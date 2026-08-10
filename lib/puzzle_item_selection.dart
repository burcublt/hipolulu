import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
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
    _imagePaths = AssetService().getImagesForTheme(widget.themeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SceneBackground(
        child: SafeArea(
          child: Column(
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: _TitleSection(themeTitle: widget.themeTitle),
              ),

              // ── GRID ──
              Expanded(
                child: _imagePaths.isEmpty
                    ? const Center(
                        child: Text(
                          'No puzzles found here!',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 18,
                            color: Color(0xFF7854B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: _imagePaths.length,
                        itemBuilder: (ctx, i) => _PuzzleItemCard(
                          imagePath: _imagePaths[i],
                          index: i,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (puzzleCtx) => PuzzleArena(
                                  imagePath: _imagePaths[i],
                                  onBack: () => Navigator.of(puzzleCtx).pop(),
                                ),
                              ),
                            );
                          },
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
  const _TitleSection({required this.themeTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          themeTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Fredoka Bold',
            fontSize: 34,
            height: 1,
            color: Color(0xFF5C28A0),
            shadows: [Shadow(color: Color(0xFFD0A8F0), offset: Offset(0, 4))],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Choose your puzzle',
          style: TextStyle(
            fontFamily: 'Fredoka',
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
//  PUZZLE ITEM CARD
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

class _PuzzleItemCardState extends State<_PuzzleItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ribbonCtrl;
  double _scale = 1.0;
  double _pressY = 0;

  @override
  void initState() {
    super.initState();
    _ribbonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ribbonCtrl.dispose();
    super.dispose();
  }

  String _formatName(String path) {
    final filename = path.split('/').last.split('.').first;
    final words = filename.split('_').map((w) {
      if (w.isEmpty) return '';
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).toList();
    return words.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const [Color(0xFF90D0FF), Color(0xFF3A9EE0)];
    final shadow = const Color(0xFF1A60B0);
    final border = const Color(0xFF64BEFF).withValues(alpha: 0.6);
    final name = _formatName(widget.imagePath);

    return GestureDetector(
      onTapDown: (_) => setState(() {
        _scale = 0.94;
        _pressY = 3;
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(0, _pressY, 0),
          child: Stack(
            children: [
              // Main Card
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: border, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: shadow,
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
                child: Column(
                  children: [
                    // Illustration Area
                    Expanded(
                      flex: 5,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: 24,
                            left: 16,
                            right: 16,
                            bottom: 0,
                            child: Hero(
                              tag: widget.imagePath,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      offset: const Offset(0, 4),
                                      blurRadius: 10,
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: AssetImage(widget.imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Name Tag
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Fredoka One',
                            fontSize: 18,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Color(0x2E000000),
                                offset: Offset(0, 2),
                                blurRadius: 6,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
//  SCENE BACKGROUND (Copied from animal_selection.dart if needed)
// ─────────────────────────────────────────────
class SceneBackground extends StatelessWidget {
  final Widget child;
  const SceneBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4F8),
      ),
      child: Stack(
        children: [
          // Basic background decor
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4E6F1).withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFDEBD0).withValues(alpha: 0.5),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
