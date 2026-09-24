import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

// ============================================================================
// ASSETS
// ============================================================================

class _MatchingGameAssets {
  const _MatchingGameAssets._();

  static const String backgroundPortrait =
      'assets/matching/background/matching_game_background_portrait.webp';

  static const String backgroundLandscape =
      'assets/matching/background/matching_game_background_landscape.webp';

  static const String parrot = 'assets/matching/animals/parrot.webp';

  static const String fox = 'assets/matching/animals/fox.webp';

  static const String cat = 'assets/matching/animals/cat.webp';

  static const String cow = 'assets/matching/animals/cow.webp';

  static const String frog = 'assets/matching/animals/frog.webp';
}

// ============================================================================
// CARD MODEL
// ============================================================================

class MatchingCardData {
  final String id;
  final String imagePath;

  bool isFaceUp;
  bool isMatched;

  MatchingCardData({
    required this.id,
    required this.imagePath,
    this.isFaceUp = true,
    this.isMatched = false,
  });
}

// ============================================================================
// SCREEN
// ============================================================================

class MatchingGameScreen extends StatefulWidget {
  final String themeId;

  const MatchingGameScreen({
    super.key,
    this.themeId = 'animals',
  });

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  // ==========================================================================
  // GAME SETTINGS
  // ==========================================================================

  static const int _memorizeSeconds = 8;

  int _secondsLeft = _memorizeSeconds;

  int _matchedPairs = 0;

  int _level = 1;

  bool _memorizing = true;

  bool _checkingPair = false;

  Timer? _timer;

  MatchingCardData? _firstSelected;
  MatchingCardData? _secondSelected;

  late List<MatchingCardData> _cards;

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _createCards();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMemorizeTimer();
    });
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ==========================================================================
  // CREATE CARDS
  // ==========================================================================

  void _createCards() {
    final items = <Map<String, String>>[
      {
        'id': 'parrot',
        'image': _MatchingGameAssets.parrot,
      },
      {
        'id': 'fox',
        'image': _MatchingGameAssets.fox,
      },
      {
        'id': 'cat',
        'image': _MatchingGameAssets.cat,
      },
      {
        'id': 'cow',
        'image': _MatchingGameAssets.cow,
      },
      {
        'id': 'frog',
        'image': _MatchingGameAssets.frog,
      },
    ];

    _cards = [];

    for (final item in items) {
      // Her item'dan 2 tane oluşturuyoruz.
      for (int i = 0; i < 2; i++) {
        _cards.add(
          MatchingCardData(
            id: item['id']!,
            imagePath: item['image']!,
            isFaceUp: true,
          ),
        );
      }
    }

    _cards.shuffle(Random());
  }

  // ==========================================================================
  // MEMORIZE TIMER
  // ==========================================================================

  void _startMemorizeTimer() {
    _timer?.cancel();

    _secondsLeft = _memorizeSeconds;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        if (_secondsLeft > 1) {
          setState(() {
            _secondsLeft--;
          });
        } else {
          timer.cancel();

          setState(() {
            _secondsLeft = 0;
            _memorizing = false;

            for (final card in _cards) {
              card.isFaceUp = false;
            }
          });
        }
      },
    );
  }

  // ==========================================================================
  // CARD TAP
  // ==========================================================================

  void _onCardTap(
    MatchingCardData card,
  ) {
    if (_memorizing) return;
    if (_checkingPair) return;
    if (card.isMatched) return;
    if (card.isFaceUp) return;

    setState(() {
      card.isFaceUp = true;
    });

    if (_firstSelected == null) {
      _firstSelected = card;
      return;
    }

    _secondSelected = card;

    _checkPair();
  }

  // ==========================================================================
  // CHECK PAIR
  // ==========================================================================

  Future<void> _checkPair() async {
    if (_firstSelected == null || _secondSelected == null) {
      return;
    }

    _checkingPair = true;

    final first = _firstSelected!;
    final second = _secondSelected!;

    if (first.id == second.id) {
      await Future.delayed(
        const Duration(milliseconds: 350),
      );

      if (!mounted) return;

      setState(() {
        first.isMatched = true;
        second.isMatched = true;

        _matchedPairs++;

        _firstSelected = null;
        _secondSelected = null;

        _checkingPair = false;
      });

      if (_matchedPairs == _cards.length ~/ 2) {
        _onLevelCompleted();
      }
    } else {
      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      if (!mounted) return;

      setState(() {
        first.isFaceUp = false;
        second.isFaceUp = false;

        _firstSelected = null;
        _secondSelected = null;

        _checkingPair = false;
      });
    }
  }

  // ==========================================================================
  // LEVEL COMPLETE
  // ==========================================================================

  void _onLevelCompleted() {
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return _WinDialog(
              onReplay: () {
                Navigator.pop(context);
                _restartGame();
              },
              onContinue: () {
                Navigator.pop(context);

                setState(() {
                  _level++;
                });

                _restartGame();
              },
            );
          },
        );
      },
    );
  }

  // ==========================================================================
  // RESTART
  // ==========================================================================

  void _restartGame() {
    _timer?.cancel();

    setState(() {
      _matchedPairs = 0;
      _secondsLeft = _memorizeSeconds;
      _memorizing = true;
      _checkingPair = false;

      _firstSelected = null;
      _secondSelected = null;

      _createCards();
    });

    _startMemorizeTimer();
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (
          BuildContext context,
          BoxConstraints constraints,
        ) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final bool isLandscape = width > height;

          return Stack(
            children: [
              // ==============================================================
              // BACKGROUND
              // ==============================================================

              Positioned.fill(
                child: Image.asset(
                  isLandscape
                      ? _MatchingGameAssets.backgroundLandscape
                      : _MatchingGameAssets.backgroundPortrait,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),

              // Background readability overlay.
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.white.withValues(
                      alpha: 0.03,
                    ),
                  ),
                ),
              ),

              // ==============================================================
              // CONTENT
              // ==============================================================

              SafeArea(
                child: isLandscape
                    ? _buildLandscape(
                        width,
                        height,
                      )
                    : _buildPortrait(
                        width,
                        height,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================================
  // PORTRAIT
  // ==========================================================================

  Widget _buildPortrait(
    double width,
    double height,
  ) {
    final bool isTablet = width >= 600;

    final double horizontalPadding = isTablet ? 36 : 16;

    return Column(
      children: [
        // --------------------------------------------------------------------
        // TOP BAR
        // --------------------------------------------------------------------

        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            8,
            horizontalPadding,
            0,
          ),
          child: _TopBar(
            level: _level,
            matchedPairs: _matchedPairs,
            totalPairs: _cards.length ~/ 2,
          ),
        ),

        SizedBox(
          height: isTablet ? 18 : 12,
        ),

        // --------------------------------------------------------------------
        // STATUS
        // --------------------------------------------------------------------

        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
          ),
          child: _GameStatusPanel(
            memorizing: _memorizing,
            secondsLeft: _secondsLeft,
            totalSeconds: _memorizeSeconds,
            compact: false,
          ),
        ),

        SizedBox(
          height: isTablet ? 24 : 16,
        ),

        // --------------------------------------------------------------------
        // CARDS
        // --------------------------------------------------------------------

        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              8,
            ),
            child: _GameGrid(
              cards: _cards,
              onCardTap: _onCardTap,
              isLandscape: false,
              isTablet: isTablet,
            ),
          ),
        ),

        // --------------------------------------------------------------------
        // HINT
        // --------------------------------------------------------------------

        _BottomHint(
          memorizing: _memorizing,
        ),

        SizedBox(
          height: isTablet ? 18 : 10,
        ),
      ],
    );
  }

  // ==========================================================================
  // LANDSCAPE
  // ==========================================================================

  Widget _buildLandscape(
    double width,
    double height,
  ) {
    final double horizontalPadding = width >= 1000 ? 32 : 18;

    return Column(
      children: [
        // Landscape'de her şeyi tek satıra yaklaştırıyoruz.
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            8,
            horizontalPadding,
            0,
          ),
          child: Row(
            children: [
              const _BackButton(),
              const SizedBox(width: 16),
              Expanded(
                child: _GameStatusPanel(
                  memorizing: _memorizing,
                  secondsLeft: _secondsLeft,
                  totalSeconds: _memorizeSeconds,
                  compact: true,
                ),
              ),
              const SizedBox(width: 16),
              _LevelBadge(
                level: _level,
              ),
              const SizedBox(width: 8),
              _PairsBadge(
                current: _matchedPairs,
                total: _cards.length ~/ 2,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
            ),
            child: _GameGrid(
              cards: _cards,
              onCardTap: _onCardTap,
              isLandscape: true,
              isTablet: width >= 900,
            ),
          ),
        ),

        _BottomHint(
          memorizing: _memorizing,
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ============================================================================
// TOP BAR
// ============================================================================

class _TopBar extends StatelessWidget {
  final int level;
  final int matchedPairs;
  final int totalPairs;

  const _TopBar({
    required this.level,
    required this.matchedPairs,
    required this.totalPairs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _BackButton(),
        const Spacer(),
        _LevelBadge(
          level: level,
        ),
        const SizedBox(width: 8),
        _PairsBadge(
          current: matchedPairs,
          total: totalPairs,
        ),
      ],
    );
  }
}

// ============================================================================
// BACK
// ============================================================================

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return _WhitePill(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          Navigator.maybePop(context);
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF6127C9),
                size: 17,
              ),
              SizedBox(width: 5),
              Text(
                'Back',
                style: TextStyle(
                  color: Color(0xFF6127C9),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
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
// LEVEL
// ============================================================================

class _LevelBadge extends StatelessWidget {
  final int level;

  const _LevelBadge({
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return _WhitePill(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_rounded,
              color: Color(0xFFFFC72C),
              size: 27,
            ),
            const SizedBox(width: 5),
            Text(
              'Level $level',
              style: const TextStyle(
                color: Color(0xFF6630C5),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PAIRS
// ============================================================================

class _PairsBadge extends StatelessWidget {
  final int current;
  final int total;

  const _PairsBadge({
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return _WhitePill(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFFF4F9A),
              size: 25,
            ),
            const SizedBox(width: 5),
            Text(
              '$current/$total',
              style: const TextStyle(
                color: Color(0xFF291375),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// WHITE PILL
// ============================================================================

class _WhitePill extends StatelessWidget {
  final Widget child;

  const _WhitePill({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.94,
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.10,
            ),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============================================================================
// STATUS PANEL
// ============================================================================

class _GameStatusPanel extends StatelessWidget {
  final bool memorizing;
  final int secondsLeft;
  final int totalSeconds;
  final bool compact;

  const _GameStatusPanel({
    required this.memorizing,
    required this.secondsLeft,
    required this.totalSeconds,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 760,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 20,
        vertical: compact ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF0).withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(
          compact ? 22 : 28,
        ),
        border: Border.all(
          color: const Color(0xFFFFC63D),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDFA300).withValues(alpha: 0.65),
            offset: const Offset(0, 6),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.10,
            ),
            offset: const Offset(0, 9),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        children: [
          // ------------------------------------------------------
          // ICON
          // ------------------------------------------------------

          Text(
            memorizing ? '👀' : '✨',
            style: TextStyle(
              fontSize: compact ? 32 : 40,
            ),
          ),

          const SizedBox(width: 10),

          // ------------------------------------------------------
          // TEXT
          // ------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    memorizing ? 'Remember the cards!' : 'Find the pairs!',
                    maxLines: 1,
                    style: TextStyle(
                      color: const Color(
                        0xFF6127C9,
                      ),
                      fontSize: compact ? 20 : 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  memorizing
                      ? "They'll flip over in a few seconds..."
                      : 'Tap two cards to find a match!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(
                      0xFF30207D,
                    ),
                    fontSize: compact ? 11 : 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          if (memorizing) ...[
            const SizedBox(width: 12),
            _CountdownCircle(
              secondsLeft: secondsLeft,
              totalSeconds: totalSeconds,
              compact: compact,
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// COUNTDOWN
// ============================================================================

class _CountdownCircle extends StatelessWidget {
  final int secondsLeft;
  final int totalSeconds;
  final bool compact;

  const _CountdownCircle({
    required this.secondsLeft,
    required this.totalSeconds,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 54 : 68;

    final double progress = totalSeconds == 0 ? 0 : secondsLeft / totalSeconds;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: compact ? 6 : 7,
              backgroundColor: const Color(
                0xFFFFE597,
              ),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2DAA57),
              ),
            ),
          ),
          Text(
            '$secondsLeft',
            style: TextStyle(
              color: const Color(
                0xFF18964C,
              ),
              fontSize: compact ? 21 : 27,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// GAME GRID
// ============================================================================

class _GameGrid extends StatelessWidget {
  final List<MatchingCardData> cards;

  final void Function(
    MatchingCardData card,
  ) onCardTap;

  final bool isLandscape;
  final bool isTablet;

  const _GameGrid({
    required this.cards,
    required this.onCardTap,
    required this.isLandscape,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final int columns = _calculateColumns(
          constraints,
        );

        final double spacing = isTablet ? 14 : 10;

        final int rows = (cards.length / columns).ceil();

        final double availableWidth =
            constraints.maxWidth - ((columns - 1) * spacing);

        final double availableHeight =
            constraints.maxHeight - ((rows - 1) * spacing);

        final double cardWidth = availableWidth / columns;

        final double cardHeight = availableHeight / rows;

        // Kartların fazla uzamasını engelliyoruz.
        final double ratio = (cardWidth / cardHeight).clamp(
          0.72,
          1.05,
        );

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 950,
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: ratio,
              ),
              itemBuilder: (context, index) {
                final card = cards[index];

                return _MemoryCard(
                  card: card,
                  onTap: () => onCardTap(card),
                );
              },
            ),
          ),
        );
      },
    );
  }

  int _calculateColumns(
    BoxConstraints constraints,
  ) {
    // 10 kart için:
    //
    // Phone portrait  -> 3
    // Tablet portrait -> 5
    // Landscape       -> 5

    if (isLandscape) {
      return 5;
    }

    if (isTablet) {
      return 5;
    }

    return 3;
  }
}

// ============================================================================
// MEMORY CARD
// ============================================================================

class _MemoryCard extends StatelessWidget {
  final MatchingCardData card;
  final VoidCallback onTap;

  const _MemoryCard({
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(
          milliseconds: 220,
        ),
        scale: card.isMatched ? 0.96 : 1,
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 280,
          ),
          curve: Curves.easeOutBack,
          decoration: BoxDecoration(
            gradient: card.isFaceUp
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(
                        0xFFFFFCED,
                      ),
                      Color(
                        0xFFFFF7DC,
                      ),
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(
                        0xFFE8B5FF,
                      ),
                      Color(
                        0xFFC36EF2,
                      ),
                    ],
                  ),
            borderRadius: BorderRadius.circular(
              22,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.95),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: card.isFaceUp
                    ? const Color(
                        0xFFE0C47C,
                      ).withValues(
                        alpha: 0.50,
                      )
                    : const Color(
                        0xFF8F42C7,
                      ).withValues(
                        alpha: 0.60,
                      ),
                offset: const Offset(
                  0,
                  6,
                ),
                blurRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.10,
                ),
                offset: const Offset(
                  0,
                  8,
                ),
                blurRadius: 12,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              20,
            ),
            child: card.isFaceUp ? _buildFront() : _buildBack(),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // FRONT
  // ==========================================================================

  Widget _buildFront() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            card.imagePath,
            fit: BoxFit.contain,
          ),
          if (card.isMatched)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 27,
                height: 27,
                decoration: const BoxDecoration(
                  color: Color(
                    0xFF49C66A,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BACK
  // ==========================================================================

  Widget _buildBack() {
    return const Stack(
      children: [
        // Small decorative stars
        Positioned(
          left: 14,
          top: 14,
          child: Icon(
            Icons.star_rounded,
            color: Color(0x66FFFFFF),
            size: 18,
          ),
        ),

        Positioned(
          right: 13,
          bottom: 13,
          child: Icon(
            Icons.pets_rounded,
            color: Color(0x66FFFFFF),
            size: 20,
          ),
        ),

        Center(
          child: Icon(
            Icons.pets_rounded,
            color: Color(0x99FFFFFF),
            size: 55,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// BOTTOM HINT
// ============================================================================

class _BottomHint extends StatelessWidget {
  final bool memorizing;

  const _BottomHint({
    required this.memorizing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.94,
        ),
        borderRadius: BorderRadius.circular(
          999,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
            ),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '💡',
            style: TextStyle(
              fontSize: 21,
            ),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              memorizing
                  ? 'Memorize the cards!'
                  : 'Try to find all the matching pairs!',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(
                  0xFF342080,
                ),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TEMPORARY WIN DIALOG
// ============================================================================

class _WinDialog extends StatelessWidget {
  final VoidCallback onReplay;
  final VoidCallback onContinue;

  const _WinDialog({
    required this.onReplay,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(
            0xFFFFFCED,
          ),
          borderRadius: BorderRadius.circular(
            30,
          ),
          border: Border.all(
            color: const Color(
              0xFFFFC43D,
            ),
            width: 3,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉',
              style: TextStyle(
                fontSize: 58,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'Great job!',
              style: TextStyle(
                color: Color(
                  0xFF6127C9,
                ),
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReplay,
                    child: const Text(
                      'Replay',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: onContinue,
                    child: const Text(
                      'Continue',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
