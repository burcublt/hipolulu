import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'asset_service.dart';
import 'matching_level_complete_dialog.dart';
import 'matching_card_grid.dart';

// ─────────────────────────────────────────────
//  MATCHING THEME TYPE
// ─────────────────────────────────────────────
enum MatchingTheme {
  animals,
  vehicles,
  objects,
  fruitsAndVegetables,
  fruits,
  vegetables,
  foods,
}

// ── Yanlış eşleşme motivasyon mesajları ──
class _WrongMsg {
  final String emoji;
  final String Function(AppLocalizations l10n) getText;
  const _WrongMsg(this.emoji, this.getText);
}

final List<_WrongMsg> kWrongMessages = [
  _WrongMsg('🙈', (l10n) => l10n.wrongTryAgain),
  _WrongMsg('🌟', (l10n) => l10n.wrongSoClose),
  _WrongMsg('💪', (l10n) => l10n.wrongYouCanDoIt),
  _WrongMsg('🤔', (l10n) => l10n.wrongNotQuite),
  _WrongMsg('😄', (l10n) => l10n.wrongAlmost),
];

// ─────────────────────────────────────────────
//  CONTENT DATA
// ─────────────────────────────────────────────
const Map<MatchingTheme, List<String>> kThemeEmojis = {
  MatchingTheme.objects: [
    '🍎',
    '⭐',
    '🎈',
    '⚽',
    '🎸',
    '🌸',
    '🍦',
    '🎀',
    '🌈',
    '🎁'
  ],
};

class _ThemeColors {
  final Color card, cardShadow, matched;
  final List<Color> cardBack;
  const _ThemeColors(
      {required this.card,
      required this.cardShadow,
      required this.matched,
      required this.cardBack});
}

const Map<MatchingTheme, _ThemeColors> kThemeColors = {
  MatchingTheme.animals: _ThemeColors(
      card: Color(0xFFFFF7E0),
      cardShadow: Color(0xFFC05000),
      matched: Color(0xFFA8D85C),
      cardBack: [Color(0xFFFF9940), Color(0xFFFFCE7A)]),
  MatchingTheme.fruits: _ThemeColors(
      card: Color(0xFFFFF7E0),
      cardShadow: Color(0xFFC05000),
      matched: Color(0xFFA8D85C),
      cardBack: [Color(0xFFFF9940), Color(0xFFFFCE7A)]),
  MatchingTheme.vegetables: _ThemeColors(
      card: Color(0xFFFFF7E0),
      cardShadow: Color(0xFFC05000),
      matched: Color(0xFFA8D85C),
      cardBack: [Color(0xFFFF9940), Color(0xFFFFCE7A)]),
  MatchingTheme.fruitsAndVegetables: _ThemeColors(
      card: Color(0xFFFFF7E0),
      cardShadow: Color(0xFFC05000),
      matched: Color(0xFFA8D85C),
      cardBack: [Color(0xFFFF9940), Color(0xFFFFCE7A)]),
  MatchingTheme.vehicles: _ThemeColors(
      card: Color(0xFFE8F5FF),
      cardShadow: Color(0xFF1A60B0),
      matched: Color(0xFFA8D85C),
      cardBack: [Color(0xFF3A9EE0), Color(0xFF90D0FF)]),
  MatchingTheme.foods: _ThemeColors(
      card: Color(0xFFE8F5FF),
      cardShadow: Color(0xFF1A60B0),
      matched: Color(0xFFA8D85C),
      cardBack: [Color(0xFF3A9EE0), Color(0xFF90D0FF)]),
  MatchingTheme.objects: _ThemeColors(
      card: Color(0xFFF5EEFF),
      cardShadow: Color(0xFF6040B8),
      matched: Color(0xFFA8D85C),
      cardBack: [Color(0xFF9E78D8), Color(0xFFD4B8F8)]),
};

// ─────────────────────────────────────────────
//  LEVEL DEFINITIONS
// ─────────────────────────────────────────────
class MatchingLevel {
  final int level;
  final int pairCount;
  final int previewSeconds;
  final String completeCharacter;

  const MatchingLevel({
    required this.level,
    required this.pairCount,
    required this.previewSeconds,
    required this.completeCharacter,
  });
}

const List<MatchingLevel> kLevels = [
  MatchingLevel(
    level: 1,
    pairCount: 5,
    previewSeconds: 10,
    completeCharacter: 'assets/matching/level_complete/lion.webp',
  ),
  MatchingLevel(
    level: 2,
    pairCount: 6,
    previewSeconds: 12,
    completeCharacter: 'assets/matching/level_complete/cat.webp',
  ),
  MatchingLevel(
    level: 3,
    pairCount: 8,
    previewSeconds: 14,
    completeCharacter: 'assets/matching/level_complete/rocket.webp',
  ),
  MatchingLevel(
    level: 4,
    pairCount: 10,
    previewSeconds: 16,
    completeCharacter: 'assets/matching/level_complete/cup.webp',
  ),
  MatchingLevel(
    level: 5,
    pairCount: 12,
    previewSeconds: 18,
    completeCharacter: 'assets/matching/level_complete/star.webp',
  ),
  MatchingLevel(
    level: 6,
    pairCount: 14,
    previewSeconds: 20,
    completeCharacter: 'assets/matching/level_complete/dinosaurs.webp',
  ),
];

// ─────────────────────────────────────────────
//  CARD STATE
// ─────────────────────────────────────────────
class CardState {
  final String id, pairId, emoji;
  const CardState(
      {required this.id, required this.pairId, required this.emoji});
}

class _MatchingGameAssets {
  const _MatchingGameAssets._();

  static const String backgroundPortrait =
      'assets/matching/background/matching_background_portrait.webp';

  static const String backgroundLandscape =
      'assets/matching/background/matching_background_landscape.webp';

  static const String frog = 'assets/matching/animals/frog.webp';
}

// ============================================================================
// CARD MODEL
// ============================================================================

enum Phase { preview, playing, won }

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────
List<CardState> buildCards(MatchingTheme theme, int pairs) {
  List<String> pool;
  if (theme == MatchingTheme.objects) {
    pool = List.from(kThemeEmojis[MatchingTheme.objects]!);
  } else {
    final images = AssetService().getMatchingImages(theme.name);
    if (images.isNotEmpty) {
      pool = List.from(images);
    } else {
      pool = List.from(kThemeEmojis[theme] ?? []);
    }
  }

  pool.shuffle(Random());
  final selected = pool.take(pairs).toList();
  final cards = <CardState>[];
  for (int i = 0; i < selected.length; i++) {
    cards.add(CardState(id: '$i-a', pairId: '$i', emoji: selected[i]));
    cards.add(CardState(id: '$i-b', pairId: '$i', emoji: selected[i]));
  }
  cards.shuffle(Random());
  return cards;
}

int calcStars(int moves, int pairs) {
  final ratio = moves / pairs;
  if (ratio <= 1.4) return 3;
  if (ratio <= 2.0) return 2;
  return 1;
}

// ─────────────────────────────────────────────
//  MATCHING GAME
// ─────────────────────────────────────────────
class MatchingGame extends StatefulWidget {
  final MatchingTheme theme;
  final VoidCallback onBack;

  const MatchingGame({super.key, required this.theme, required this.onBack});

  @override
  State<MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame>
    with TickerProviderStateMixin {
  int _levelIdx = 0;
  List<CardState> _cards = [];
  Phase _phase = Phase.preview;
  int _countdown = 0;
  final List<String> _selected = [];
  final Set<String> _matched = {};
  bool _disabled = false;
  bool _showWrongToast = false;
  int _lives = 5;
  bool _showWin = false;
  Timer? _checkTimer;
  Timer? _countdownTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startLevel(0);
    _initGame();
  }

  void _initGame() async {
    await AssetService().load();
    if (mounted) {
      setState(() {
        _cards = buildCards(widget.theme,
            kLevels[_levelIdx.clamp(0, kLevels.length - 1)].pairCount);
      });
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _countdownTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  MatchingLevel get _level => kLevels[_levelIdx.clamp(0, kLevels.length - 1)];

  void _startLevel(int idx) {
    _checkTimer?.cancel();
    _countdownTimer?.cancel();
    setState(() {
      _levelIdx = idx;
      _cards = buildCards(
          widget.theme, kLevels[idx.clamp(0, kLevels.length - 1)].pairCount);
      _phase = Phase.preview;
      _countdown = kLevels[idx.clamp(0, kLevels.length - 1)].previewSeconds;
      _selected.clear();
      _matched.clear();
      _disabled = false;
      _lives = 5;
      _showWin = false;
      _showWrongToast = false;
    });
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          t.cancel();
          _phase = Phase.playing;
        }
      });
    });
  }

  void _handleCardTap(String id) {
    if (_disabled || _phase != Phase.playing) return;
    if (_selected.contains(id) || _selected.length >= 2) return;

    setState(() => _selected.add(id));

    if (_selected.length == 2) {
      setState(() {
        _disabled = true;
      });
      final a = _cards.firstWhere((c) => c.id == _selected[0]);
      final b = _cards.firstWhere((c) => c.id == _selected[1]);

      if (a.pairId == b.pairId) {
        setState(() => _matched.add(a.pairId));

        // Dinamik ses çalma
        final langCode = Localizations.localeOf(context).languageCode;
        final themeFolder = widget.theme.name;
        final itemName = a.emoji.split('/').last.split('.').first;
        final soundPath = 'voices/$themeFolder/$langCode/$itemName.mp3';

        _audioPlayer.play(AssetSource(soundPath)).catchError((e) {
          debugPrint('Audio file not found: $soundPath');
        });

        if (_matched.length == _level.pairCount) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) _showLevelCompleteDialog();
          });
        }
        _checkTimer = Timer(const Duration(milliseconds: 500), () {
          if (mounted)
            setState(() {
              _selected.clear();
              _disabled = false;
              _showWrongToast = false;
            });
        });
      } else {
        setState(() {
          _showWrongToast = true;
          _lives--;
        });
        if (_lives <= 0) {
          Future.delayed(const Duration(milliseconds: 900), () {
            if (mounted) {
              _startLevel(_levelIdx); // restart on game over
            }
          });
        }
        _checkTimer = Timer(const Duration(milliseconds: 900), () {
          if (mounted)
            setState(() {
              _selected.clear();
              _disabled = false;
              _showWrongToast = false;
            });
        });
      }
    }
  }

  Future<void> _showLevelCompleteDialog() async {
    if (_showWin || !mounted) return;

    setState(() {
      _showWin = true;
      _phase = Phase.won;
      _disabled = true;
    });

    final bool hasNextLevel = _levelIdx < kLevels.length - 1;

    await showMatchingLevelCompleteDialog(
      context: context,
      level: _level.level,
      characterAsset: _level.completeCharacter,
      hasNextLevel: hasNextLevel,
      onNextLevel: () {
        Navigator.of(context, rootNavigator: true).pop();
        if (hasNextLevel && mounted) {
          _startLevel(_levelIdx + 1);
        }
      },
      onRetry: () {
        Navigator.of(context, rootNavigator: true).pop();
        if (mounted) {
          _startLevel(_levelIdx);
        }
      },
      onMenu: () {
        Navigator.of(context, rootNavigator: true).pop();
        widget.onBack();
      },
    );

    if (mounted && _showWin) {
      setState(() => _showWin = false);
    }
  }

  bool _isFaceUp(CardState card) =>
      _phase == Phase.preview ||
      _matched.contains(card.pairId) ||
      _selected.contains(card.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
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
        ],
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
            level: _level.level,
            matchedPairs: _matched.length,
            lives: _lives,
            totalPairs: _level.pairCount,
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
            memorizing: (_phase == Phase.preview),
            secondsLeft: _countdown,
            totalSeconds: _level.previewSeconds,
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
              onCardTap: (card) => _handleCardTap(card.id),
              isFaceUp: _isFaceUp,
              isMatched: (card) => _matched.contains(card.pairId),
              isLandscape: false,
              isTablet: isTablet,
            ),
          ),
        ),

        // --------------------------------------------------------------------
        // HINT
        // --------------------------------------------------------------------

        _BottomHint(
          memorizing: (_phase == Phase.preview),
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
                  memorizing: (_phase == Phase.preview),
                  secondsLeft: _countdown,
                  totalSeconds: _level.previewSeconds,
                  compact: true,
                ),
              ),
              const SizedBox(width: 16),
              _LevelBadge(
                level: _level.level,
              ),
              const SizedBox(width: 8),
              _PairsBadge(
                current: _matched.length,
                total: _level.pairCount,
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
              onCardTap: (card) => _handleCardTap(card.id),
              isFaceUp: _isFaceUp,
              isMatched: (card) => _matched.contains(card.pairId),
              isLandscape: true,
              isTablet: height >= 600,
            ),
          ),
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
  final int lives;
  final int totalPairs;

  const _TopBar({
    required this.level,
    required this.matchedPairs,
    required this.lives,
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
          current: lives,
          total: 5,
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
  final List<CardState> cards;

  final void Function(CardState card) onCardTap;
  final bool Function(CardState card) isFaceUp;
  final bool Function(CardState card) isMatched;

  final bool isLandscape;
  final bool isTablet;

  const _GameGrid({
    super.key,
    required this.cards,
    required this.onCardTap,
    required this.isFaceUp,
    required this.isMatched,
    required this.isLandscape,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return MatchingCardGrid(
      itemCount: cards.length,
      isTablet: isTablet,
      itemBuilder: (context, index) {
        final card = cards[index];
        return _MemoryCard(
          card: card,
          faceUp: isFaceUp(card),
          matched: isMatched(card),
          onTap: () => onCardTap(card),
        );
      },
    );
  }
}

// ============================================================================
// MEMORY CARD
// ============================================================================

class _MemoryCard extends StatelessWidget {
  final CardState card;
  final bool faceUp;
  final bool matched;
  final VoidCallback onTap;

  const _MemoryCard({
    super.key,
    required this.card,
    required this.faceUp,
    required this.matched,
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
        scale: matched ? 0.96 : 1,
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 280,
          ),
          curve: Curves.easeOutBack,
          decoration: BoxDecoration(
            gradient: faceUp
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
                color: faceUp
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
            child: faceUp ? _buildFront() : _buildBack(),
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
          card.emoji.endsWith('.webp') || card.emoji.endsWith('.png')
              ? Image.asset(
                  card.emoji.startsWith('assets/')
                      ? card.emoji
                      : (card.emoji.startsWith('matching/')
                          ? 'assets/images/${card.emoji}'
                          : 'assets/images/matching/${card.emoji}'),
                  fit: BoxFit.contain,
                )
              : Text(card.emoji, style: const TextStyle(fontSize: 40)),
          if (matched)
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
// WRONG TOAST
// ============================================================================

class _WrongToast extends StatefulWidget {
  final bool show;
  const _WrongToast({Key? key, required this.show}) : super(key: key);
  @override
  State<_WrongToast> createState() => _WrongToastState();
}

class _WrongToastState extends State<_WrongToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _opacity;
  late Animation<Offset> _slide;
  _WrongMsg _msg = kWrongMessages[0];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _ctrl.addListener(() => setState(() {}));
    _scale = Tween(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _opacity = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_WrongToast old) {
    super.didUpdateWidget(old);
    if (widget.show && !old.show) {
      setState(
          () => _msg = kWrongMessages[Random().nextInt(kWrongMessages.length)]);
      _ctrl.forward(from: 0);
    }
    if (!widget.show && old.show) {
      _ctrl.reverse();
    }
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
      builder: (_, child) {
        if (_ctrl.value == 0) return const SizedBox.shrink();
        return Opacity(
          opacity: _opacity.value,
          child: SlideTransition(
            position: _slide,
            child: ScaleTransition(scale: _scale, child: child),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF0C0), Color(0xFFFFE08A)],
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.8), width: 3),
          boxShadow: const [
            BoxShadow(color: Color(0xFFD4A000), offset: Offset(0, 6)),
            BoxShadow(
                color: Color(0x4DC8A000),
                offset: Offset(0, 10),
                blurRadius: 28),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              builder: (_, t, child) {
                final angle = sin(t * pi * 4) * 15 * (1 - t) * pi / 180;
                final scale = 1.0 + sin(t * pi) * 0.3;
                return Transform.scale(
                  scale: scale,
                  child: Transform.rotate(angle: angle, child: child),
                );
              },
              child: Text(_msg.emoji, style: const TextStyle(fontSize: 30)),
            ),
            const SizedBox(width: 10),
            Text(
              _msg.getText(AppLocalizations.of(context)!),
              style: const TextStyle(
                fontFamily: 'Baloo2 ExtraBold',
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Color(0xFF7A4800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
