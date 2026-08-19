import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'package:hippolulu/l10n/game_l10n.dart';
import 'asset_service.dart';

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
class _Level {
  final int pairs, previewSeconds, number;
  const _Level({
    required this.pairs,
    required this.previewSeconds,
    required this.number,
  });
}

const List<_Level> kLevels = [
  _Level(pairs: 5, previewSeconds: 10, number: 1),
  _Level(pairs: 6, previewSeconds: 12, number: 2),
  _Level(pairs: 8, previewSeconds: 14, number: 3),
  _Level(pairs: 10, previewSeconds: 16, number: 4),
];

// ─────────────────────────────────────────────
//  CARD STATE
// ─────────────────────────────────────────────
class CardState {
  final String id, pairId, emoji;
  const CardState(
      {required this.id, required this.pairId, required this.emoji});
}

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
  int _moves = 0;
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
            kLevels[_levelIdx.clamp(0, kLevels.length - 1)].pairs);
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

  _Level get _level => kLevels[_levelIdx.clamp(0, kLevels.length - 1)];

  void _startLevel(int idx) {
    _checkTimer?.cancel();
    _countdownTimer?.cancel();
    setState(() {
      _levelIdx = idx;
      _cards = buildCards(
          widget.theme, kLevels[idx.clamp(0, kLevels.length - 1)].pairs);
      _phase = Phase.preview;
      _countdown = kLevels[idx.clamp(0, kLevels.length - 1)].previewSeconds;
      _selected.clear();
      _matched.clear();
      _disabled = false;
      _moves = 0;
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
        _moves++;
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

        if (_matched.length == _level.pairs) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) setState(() => _showWin = true);
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
        setState(() => _showWrongToast = true);
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

  bool _isFaceUp(CardState card) =>
      _phase == Phase.preview ||
      _matched.contains(card.pairId) ||
      _selected.contains(card.id);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final col = kThemeColors[widget.theme]!;
    final stars = calcStars(_moves, _level.pairs);
    final levelLabel = l10n.levelLabel(_level.number);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.45, 0.80, 1.0],
            colors: [
              Color(0xFF72D8F5),
              Color(0xFFB0EAFC),
              Color(0xFFCAF5E2),
              Color(0xFFB0E8A8)
            ],
          ),
        ),
        child: Stack(
          children: [
            // BG blobs
            Positioned(
                top: -60,
                left: -60,
                child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.13)))),
            Positioned(
                bottom: 100,
                right: -30,
                child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            const Color(0xFFC4A8E8).withValues(alpha: 0.16)))),

            SafeArea(
              child: Column(
                children: [
                  // ── TOP BAR ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BackButton(onTap: widget.onBack),
                        // Level badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF643CC8)
                                      .withValues(alpha: 0.14),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3))
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(levelLabel,
                                  style: const TextStyle(
                                      fontFamily: 'Fredoka Bold',
                                      fontSize: 16,
                                      color: Color(0xFF5C28A0))),
                              const SizedBox(width: 6),
                              Text(
                                  '· ${l10n.pairsProgress(_matched.length, _level.pairs)}',
                                  style: const TextStyle(
                                      fontFamily: 'Fredoka Bold',
                                      fontSize: 13,
                                      color: Color(0xFF9575CD),
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── PREVIEW BANNER or PROGRESS BAR ──
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _phase == Phase.preview
                        ? _PreviewBanner(
                            countdown: _countdown,
                            total: _level.previewSeconds,
                            key: const ValueKey('preview'))
                        : _PlayingHeader(
                            matched: _matched.length,
                            total: _level.pairs,
                            moves: _moves,
                            movesLabel: l10n.movesCount(_moves),
                            key: const ValueKey('playing')),
                  ),

                  // ── CARD GRID ──
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const gap = 8.0;
                        const hpad = 16.0;
                        const vpad = 8.0;

                        final availableW = constraints.maxWidth - hpad * 2;
                        final availableH = constraints.maxHeight - vpad * 2;

                        int bestCols = 2;
                        double bestCardW = 0;
                        final numCards = _cards.length;

                        for (int cols = 2; cols <= numCards; cols++) {
                          final rows = (numCards / cols).ceil();
                          final wByWidth =
                              (availableW - gap * (cols - 1)) / cols;
                          final hByHeight =
                              (availableH - gap * (rows - 1)) / rows;
                          final wByHeight = hByHeight / 1.25;

                          final w = min(wByWidth, wByHeight);
                          if (w > bestCardW) {
                            bestCardW = w;
                            bestCols = cols;
                          }
                        }

                        final cardW = bestCardW.floorToDouble();
                        final cardH = (cardW * 1.25).floorToDouble();

                        return Stack(alignment: Alignment.center, children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: hpad, vertical: vpad),
                              child: Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                alignment: WrapAlignment.center,
                                children: _cards
                                    .map((card) => _MemoryCard(
                                          card: card,
                                          faceUp: _isFaceUp(card),
                                          matched:
                                              _matched.contains(card.pairId),
                                          disabled: _disabled,
                                          cardW: cardW,
                                          cardH: cardH,
                                          themeColors: col,
                                          onTap: () => _handleCardTap(card.id),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                          // ── WRONG TOAST ──
                          Positioned(
                            top: constraints.maxHeight * 0.30,
                            child: IgnorePointer(
                              child: _WrongToast(show: _showWrongToast),
                            ),
                          ),
                        ]);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── WIN OVERLAY ──
            if (_showWin)
              _WinOverlay(
                level: _level,
                levelIdx: _levelIdx,
                moves: _moves,
                stars: stars,
                onNextLevel: () => _startLevel(_levelIdx + 1),
                onRetry: () => _startLevel(_levelIdx),
                onBack: widget.onBack,
              ),
          ],
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
          padding: const EdgeInsets.fromLTRB(12, 9, 16, 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF643CC8).withValues(alpha: 0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.chevron_left_rounded,
                size: 22, color: Color(0xFF5C28A0)),
            const SizedBox(width: 2),
            Text(AppLocalizations.of(context)!.back,
                style: const TextStyle(
                    fontFamily: 'Fredoka Bold',
                    fontSize: 17,
                    color: Color(0xFF5C28A0))),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PREVIEW BANNER
// ─────────────────────────────────────────────
class _PreviewBanner extends StatelessWidget {
  final int countdown;
  final int total;
  const _PreviewBanner(
      {required this.countdown, required this.total, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFDC3C).withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.6), width: 2.5),
          boxShadow: const [
            BoxShadow(color: Color(0xFFC49200), offset: Offset(0, 4)),
            BoxShadow(
                color: Color(0x40C49200), offset: Offset(0, 6), blurRadius: 16),
          ],
        ),
        child: Row(
          children: [
            _CountdownRing(value: countdown, total: total),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.rememberCards,
                      style: const TextStyle(
                          fontFamily: 'Fredoka Bold',
                          fontSize: 17,
                          color: Color(0xFF4A2800),
                          height: 1.2)),
                  const SizedBox(height: 3),
                  Text(l10n.flipCountdown(countdown),
                      style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 13,
                          color: Color(0xFF7A4800),
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  COUNTDOWN RING
// ─────────────────────────────────────────────
class _CountdownRing extends StatelessWidget {
  final int value, total;
  const _CountdownRing({required this.value, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = value / total;
    final color = value <= 3
        ? const Color(0xFFFF4444)
        : value <= 6
            ? const Color(0xFFFFAA00)
            : const Color(0xFF5AAA20);
    const r = 28.0, size = 72.0;
    const circ = 2 * pi * r;
    final dashOffset = circ * (1 - progress);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(size, size),
            painter: _RingPainter(
              progress: progress,
              color: color,
              circ: circ,
              dashOffset: dashOffset,
            ),
          ),
          Text('$value',
              style: TextStyle(
                fontFamily: 'Fredoka Bold',
                fontSize: 26,
                color: color,
                shadows: const [
                  Shadow(
                      color: Color(0x26000000),
                      offset: Offset(0, 2),
                      blurRadius: 4)
                ],
              )),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress, circ, dashOffset;
  final Color color;
  const _RingPainter(
      {required this.progress,
      required this.circ,
      required this.dashOffset,
      required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const r = 28.0;
    final center = Offset(size.width / 2, size.height / 2);
    // Background ring
    canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5);
    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter o) =>
      o.progress != progress || o.color != color;
}

// ─────────────────────────────────────────────
//  PLAYING HEADER
// ─────────────────────────────────────────────
class _PlayingHeader extends StatelessWidget {
  final int matched, total, moves;
  final String movesLabel;

  const _PlayingHeader({
    required this.matched,
    required this.total,
    required this.moves,
    required this.movesLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          // Progress bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 10,
                color: Colors.white.withValues(alpha: 0.45),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedFractionallySizedBox(
                    widthFactor: total > 0 ? matched / total : 0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                            colors: [Color(0xFFA8D85C), Color(0xFF5AAA20)]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Moves badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('🎯 $movesLabel',
                style: const TextStyle(
                    fontFamily: 'Fredoka Bold',
                    fontSize: 13,
                    color: Color(0xFF7854B8),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _WrongToast extends StatefulWidget {
  final bool show;
  const _WrongToast({required this.show});
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
      // her seferinde rastgele mesaj seç
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
        // animasyon tamamen sıfırlandıysa widget'ı render etme
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
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.8), width: 3),
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
            // Titreşen emoji
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
                fontFamily: 'Fredoka Bold',
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

// ─────────────────────────────────────────────
//  MEMORY CARD
// ─────────────────────────────────────────────
class _MemoryCard extends StatefulWidget {
  final CardState card;
  final bool faceUp, matched, disabled;
  final double cardW, cardH;
  final _ThemeColors themeColors;
  final VoidCallback onTap;

  const _MemoryCard({
    required this.card,
    required this.faceUp,
    required this.matched,
    required this.disabled,
    required this.cardW,
    required this.cardH,
    required this.themeColors,
    required this.onTap,
  });

  @override
  State<_MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<_MemoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipCtrl, curve: const Cubic(0.4, 0, 0.2, 1)),
    );
    if (widget.faceUp) _flipCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_MemoryCard old) {
    super.didUpdateWidget(old);
    if (widget.faceUp && !old.faceUp) _flipCtrl.forward();
    if (!widget.faceUp && old.faceUp) _flipCtrl.reverse();
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final col = widget.themeColors;
    final emojiSize = (widget.cardW * 0.65).roundToDouble();

    return GestureDetector(
      onTap: (!widget.disabled && !widget.matched && !widget.faceUp)
          ? widget.onTap
          : null,
      child: SizedBox(
        width: widget.cardW,
        height: widget.cardH,
        child: AnimatedBuilder(
          animation: _flipAnim,
          builder: (_, __) {
            final angle = _flipAnim.value * pi;
            final showFront = angle > pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle - (showFront ? pi : 0)),
              child: showFront ? _buildFront(col, emojiSize) : _buildBack(col),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBack(_ThemeColors col) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: col.cardBack,
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.55), width: 2.5),
        boxShadow: [
          BoxShadow(color: col.cardShadow, offset: const Offset(0, 4)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              offset: const Offset(0, 6),
              blurRadius: 14),
        ],
      ),
      child: Stack(
        children: [
          // Pattern dots
          for (final pos in [
            [0.15, 0.20],
            [0.55, 0.70],
            [0.85, 0.40],
            [0.25, 0.80],
            [0.65, 0.15],
            [0.45, 0.55],
          ])
            Positioned(
              top: widget.cardH * pos[0] - 4,
              left: widget.cardW * pos[1] - 4,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.3)),
              ),
            ),
          const Center(
            child: Opacity(
              opacity: 0.4,
              child: Text('❓',
                  style: TextStyle(fontSize: 22, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFront(_ThemeColors col, double emojiSize) {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.matched
            ? LinearGradient(
                colors: [const Color(0xFFC8F090), col.matched],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)
            : null,
        color: widget.matched ? null : col.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.matched
              ? const Color(0xFFA8D85C)
              : const Color(0xFFC8B4F0).withValues(alpha: 0.4),
          width: 2.5,
        ),
        boxShadow: widget.matched
            ? const [
                BoxShadow(color: Color(0xFF5AAA20), offset: Offset(0, 4)),
                BoxShadow(
                    color: Color(0x335AAA20),
                    offset: Offset(0, 6),
                    blurRadius: 14)
              ]
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    offset: const Offset(0, 4)),
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    offset: const Offset(0, 6),
                    blurRadius: 14)
              ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.card.emoji.endsWith('.webp') ||
                  widget.card.emoji.endsWith('.png') ||
                  widget.card.emoji.endsWith('.jpg')
              ? Image.asset(
                  widget.card.emoji.startsWith('assets/')
                      ? widget.card.emoji
                      : (widget.card.emoji.startsWith('matching/')
                          ? 'assets/images/${widget.card.emoji}'
                          : 'assets/images/matching/${widget.card.emoji}'),
                  width: emojiSize,
                  height: emojiSize,
                  fit: BoxFit.contain,
                )
              : Text(widget.card.emoji, style: TextStyle(fontSize: emojiSize)),
          if (widget.matched)
            Positioned(
              top: 3,
              right: 3,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: Color(0xFF5AAA20), shape: BoxShape.circle),
                child: const Center(
                    child: Text('✓',
                        style: TextStyle(fontSize: 10, color: Colors.white))),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIN OVERLAY
// ─────────────────────────────────────────────
class _WinOverlay extends StatefulWidget {
  final _Level level;
  final int levelIdx, moves, stars;
  final VoidCallback onNextLevel, onRetry, onBack;

  const _WinOverlay({
    required this.level,
    required this.levelIdx,
    required this.moves,
    required this.stars,
    required this.onNextLevel,
    required this.onRetry,
    required this.onBack,
  });

  @override
  State<_WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<_WinOverlay>
    with TickerProviderStateMixin {
  late AnimationController _celebCtrl, _entryCtrl;
  late List<AnimationController> _starCtrls;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();
    _celebCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _starCtrls = List.generate(3, (i) {
      final c = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 400));
      Future.delayed(Duration(milliseconds: 350 + i * 150), () {
        if (mounted) c.forward();
      });
      return c;
    });
  }

  @override
  void dispose() {
    _celebCtrl.dispose();
    _entryCtrl.dispose();
    for (final c in _starCtrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final levelLabel = l10n.levelLabel(widget.level.number);
    final nextLevel = widget.levelIdx < kLevels.length - 1
        ? kLevels[widget.levelIdx + 1]
        : null;

    return FadeTransition(
      opacity: _entryCtrl,
      child: Container(
        color: const Color(0xFF64BE3C).withValues(alpha: 0.93),
        child: Center(
          child: ScaleTransition(
            scale:
                CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🎉 celebrate
                  AnimatedBuilder(
                    animation: _celebCtrl,
                    builder: (_, child) => Transform.scale(
                      scale: 1.0 + 0.15 * _celebCtrl.value,
                      child: Transform.rotate(
                        angle: (-10 + 20 * _celebCtrl.value) * pi / 180,
                        child: child,
                      ),
                    ),
                    child: const Text('🎉', style: TextStyle(fontSize: 72)),
                  ),
                  const SizedBox(height: 12),

                  Text(l10n.levelDone(levelLabel),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Fredoka Bold',
                        fontSize: 42,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Color(0x1F000000), offset: Offset(0, 4))
                        ],
                      )),

                  const SizedBox(height: 4),
                  Text(l10n.matchedAllSummary(widget.level.pairs, widget.moves),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Fredoka Bold',
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),

                  const SizedBox(height: 12),

                  // Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        3,
                        (i) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: ScaleTransition(
                                scale: CurvedAnimation(
                                    parent: _starCtrls[i],
                                    curve: Curves.elasticOut),
                                child: Icon(Icons.star_rounded,
                                    size: 44,
                                    color: i < widget.stars
                                        ? const Color(0xFFFFD93D)
                                        : Colors.white.withValues(alpha: 0.3)),
                              ),
                            )),
                  ),

                  const SizedBox(height: 20),

                  // Next Level button
                  if (nextLevel != null)
                    _WinButton(
                      label: l10n.nextLevel(
                        l10n.levelLabel(nextLevel.number),
                        nextLevel.pairs * 2,
                      ),
                      primary: true,
                      onTap: widget.onNextLevel,
                    ),
                  if (widget.levelIdx >= kLevels.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(l10n.beatAllLevels,
                          style: const TextStyle(
                              fontFamily: 'Fredoka Bold',
                              fontSize: 18,
                              color: Colors.white)),
                    ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _WinButton(
                              label: l10n.retry,
                              primary: false,
                              onTap: widget.onRetry)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _WinButton(
                              label: l10n.menu,
                              primary: false,
                              onTap: widget.onBack)),
                    ],
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

class _WinButton extends StatefulWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _WinButton(
      {required this.label, required this.primary, required this.onTap});
  @override
  State<_WinButton> createState() => _WinButtonState();
}

class _WinButtonState extends State<_WinButton> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.93),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: widget.primary ? 16 : 13,
            horizontal: widget.primary ? 32 : 0,
          ),
          decoration: BoxDecoration(
            gradient: widget.primary
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFE857), Color(0xFFFFC300)])
                : null,
            color: widget.primary ? null : Colors.white.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: widget.primary ? 3 : 2.5),
            boxShadow: widget.primary
                ? const [
                    BoxShadow(color: Color(0xFFC49000), offset: Offset(0, 6)),
                    BoxShadow(
                        color: Color(0x4DC49000),
                        offset: Offset(0, 10),
                        blurRadius: 20)
                  ]
                : null,
          ),
          child: Text(widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka Bold',
                fontSize: widget.primary ? 22 : 16,
                color: widget.primary ? const Color(0xFF4A2800) : Colors.white,
              )),
        ),
      ),
    );
  }
}
