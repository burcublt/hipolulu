import re

def merge():
    with open('lib/matching_game.dart', 'r') as f:
        old_game = f.read()

    with open('lib/matching_game_test.dart', 'r') as f:
        test_game = f.read()

    # Find the logic part
    build_idx = old_game.find('  @override\n  Widget build(BuildContext context) {')
    logic_part = old_game[:build_idx]

    # Replace moves with lives
    logic_part = logic_part.replace('int _moves = 0;', 'int _lives = 5;')
    logic_part = logic_part.replace('_moves = 0;', '_lives = 5;')
    
    # Remove _moves++;
    logic_part = re.sub(r'\s*_moves\+\+;', '', logic_part)

    # In _handleCardTap, add lives logic
    wrong_logic = """        setState(() {
          _showWrongToast = true;
          _lives--;
        });
        if (_lives <= 0) {
          Future.delayed(const Duration(milliseconds: 900), () {
            if (mounted) {
              _startLevel(_levelIdx); // restart on game over
            }
          });
        }"""
    logic_part = logic_part.replace('setState(() => _showWrongToast = true);', wrong_logic)
    logic_part = logic_part.replace('calcStars(_moves, _level.pairs)', 'calcStars(0, _level.pairs)')

    # Extract test_game UI part
    test_build_idx = test_game.find('  @override\n  Widget build(BuildContext context) {')
    test_ui_part = test_game[test_build_idx:]
    test_ui_part = test_ui_part.split('class _WinDialog extends StatelessWidget {')[0]

    # Convert UI part variables to match old logic
    test_ui_part = test_ui_part.replace('MatchingCardData', 'CardState')
    test_ui_part = test_ui_part.replace('_matchedPairs', '_matched.length')
    test_ui_part = test_ui_part.replace('_cards.length ~/ 2', '_level.pairs')
    test_ui_part = test_ui_part.replace('_memorizing', '(_phase == Phase.preview)')
    test_ui_part = test_ui_part.replace('_secondsLeft', '_countdown')
    test_ui_part = test_ui_part.replace('_memorizeSeconds', '_level.previewSeconds')
    test_ui_part = test_ui_part.replace('level: _level,', 'level: _level.number,')

    # TopBar lives
    test_ui_part = test_ui_part.replace('matchedPairs: _matched.length,', 'matchedPairs: _matched.length,\n            lives: _lives,')
    test_ui_part = test_ui_part.replace('final int matchedPairs;', 'final int matchedPairs;\n  final int lives;')
    test_ui_part = test_ui_part.replace('required this.matchedPairs,', 'required this.matchedPairs,\n    required this.lives,')
    test_ui_part = test_ui_part.replace(
'''        _PairsBadge(
          current: matchedPairs,
          total: totalPairs,
        ),''',
'''        _PairsBadge(
          current: lives,
          total: 5,
        ),'''
    )

    # GameGrid bindings
    test_ui_part = test_ui_part.replace('onCardTap: _onCardTap,', 'onCardTap: (card) => _handleCardTap(card.id),\n              isFaceUp: _isFaceUp,\n              isMatched: (card) => _matched.contains(card.pairId),')

    test_ui_part = test_ui_part.replace(
'''  final void Function(
    CardState card,
  ) onCardTap;''',
'''  final void Function(CardState card) onCardTap;
  final bool Function(CardState card) isFaceUp;
  final bool Function(CardState card) isMatched;'''
    )

    test_ui_part = test_ui_part.replace(
'''  const _GameGrid({
    required this.cards,
    required this.onCardTap,
    required this.isLandscape,
    required this.isTablet,
  });''',
'''  const _GameGrid({
    super.key,
    required this.cards,
    required this.onCardTap,
    required this.isFaceUp,
    required this.isMatched,
    required this.isLandscape,
    required this.isTablet,
  });'''
    )

    test_ui_part = test_ui_part.replace(
'''                return _MemoryCard(
                  card: card,
                  onTap: () => onCardTap(card),
                );''',
'''                return _MemoryCard(
                  card: card,
                  faceUp: isFaceUp(card),
                  matched: isMatched(card),
                  onTap: () => onCardTap(card),
                );'''
    )

    # MemoryCard definition
    test_ui_part = test_ui_part.replace(
'''class _MemoryCard extends StatelessWidget {
  final CardState card;
  final VoidCallback onTap;

  const _MemoryCard({
    required this.card,
    required this.onTap,
  });''',
'''class _MemoryCard extends StatelessWidget {
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
  });'''
    )
    test_ui_part = test_ui_part.replace('card.isMatched', 'matched')
    test_ui_part = test_ui_part.replace('card.isFaceUp', 'faceUp')
    
    front_build_old = """    return Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            card.imagePath,
            fit: BoxFit.contain,
          ),
          if (matched)
            Positioned(
              top: 2,
              right: 2,"""
              
    front_build_new = """    return Padding(
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
              right: 2,"""
    test_ui_part = test_ui_part.replace(front_build_old, front_build_new)
    
    # Change Scaffold root to stack with _WinOverlay
    build_sig = '  @override\n  Widget build(BuildContext context) {\n'
    stack_start = """    final col = kThemeColors[widget.theme]!;
    final stars = calcStars(0, _level.pairs);
    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
"""
    test_ui_part = test_ui_part.replace('  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      body: LayoutBuilder(', build_sig + stack_start)

    test_ui_part = test_ui_part.replace(
'''            ],
          );
        },
      ),
    );
  }''',
'''            ],
          );
        },
      ),
      if (_showWin)
        _WinOverlay(
          level: _level,
          levelIdx: _levelIdx,
          moves: 0,
          stars: stars,
          onNextLevel: () => _startLevel(_levelIdx + 1),
          onRetry: () => _startLevel(_levelIdx),
          onBack: widget.onBack,
        ),
    ],
    ),
  );
}'''
    )
    
    # Extract _WinOverlay and below from old_game
    old_win_overlay_idx = old_game.find('class _WinOverlay extends StatefulWidget {')
    old_extras = old_game[old_win_overlay_idx:] if old_win_overlay_idx != -1 else ""
    
    assets_idx = test_game.find('class _MatchingGameAssets {')
    assets_end = test_game.find('class MatchingCardData {')
    assets_code = test_game[assets_idx:assets_end]
    
    logic_part = re.sub(r'class _MatchingGameAssets \{.*?\n\}\n', '', logic_part, flags=re.DOTALL)

    final_code = logic_part[:logic_part.find('enum Phase')] + assets_code + logic_part[logic_part.find('enum Phase'):] + test_ui_part + old_extras
    
    with open('lib/matching_game.dart', 'w') as f:
        f.write(final_code)

if __name__ == '__main__':
    merge()
