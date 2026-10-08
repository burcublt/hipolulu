import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

enum PuzzleCompletionPhase {
  playing,
  lastPieceSnap,
  completedReveal,
  celebration,
  titleEntrance,
  actionsReady
}

/// One finite timeline, cancelled by the arena on reset and dispose.
class PuzzleCompletionController extends AnimationController {
  PuzzleCompletionController({required super.vsync})
      : super(duration: const Duration(milliseconds: 2700));
  bool _started = false;
  PuzzleCompletionPhase get phase {
    if (!_started) return PuzzleCompletionPhase.playing;
    final ms = value * 2700;
    if (ms < 170) return PuzzleCompletionPhase.lastPieceSnap;
    if (ms < 570) return PuzzleCompletionPhase.completedReveal;
    if (ms < 1170) return PuzzleCompletionPhase.celebration;
    if (ms < 2070) return PuzzleCompletionPhase.titleEntrance;
    return PuzzleCompletionPhase.actionsReady;
  }

  void begin({required bool reduceMotion}) {
    if (_started) return;
    _started = true;
    if (reduceMotion) {
      value = 1;
    } else {
      forward(from: 0);
    }
  }

  void restartRound() {
    _started = false;
    reset();
  }
}

class PuzzleCompletionOverlay extends StatefulWidget {
  final PuzzleCompletionController timeline;
  final Rect board;
  final String imagePath;
  final VoidCallback onReplay, onNext;
  const PuzzleCompletionOverlay(
      {super.key,
      required this.timeline,
      required this.board,
      required this.imagePath,
      required this.onReplay,
      required this.onNext});
  @override
  State<PuzzleCompletionOverlay> createState() =>
      _PuzzleCompletionOverlayState();
}

class _PuzzleCompletionOverlayState extends State<PuzzleCompletionOverlay> {
  bool _actionTaken = false;
  void _act(VoidCallback callback) {
    if (_actionTaken ||
        widget.timeline.phase != PuzzleCompletionPhase.actionsReady) {
      return;
    }
    _actionTaken = true;
    widget.timeline.stop();
    callback();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: widget.timeline,
      builder: (context, _) => LayoutBuilder(builder: (context, constraints) {
            final ms = widget.timeline.value * 2700;
            double track(double start, double end) =>
                ((ms - start) / (end - start)).clamp(0.0, 1.0);
            final reduced = MediaQuery.disableAnimationsOf(context);
            // Placement already used 480 ms; offsets continue that timeline.
            final message = reduced ? 1.0 : track(1170, 1670);
            final actions = reduced ? 1.0 : track(1520, 2070);
            final burst = reduced ? 0.0 : math.sin(track(570, 2600) * math.pi);
            final size = constraints.biggest;
            final board = widget.board;
            final groupWidth = math.min(size.width * .86, 760.0);
            const actionGap = 34.0;
            final bottomSpace = size.height - board.bottom - actionGap - 12;
            final sideActions = bottomSpace < 48;
            final stacked = sideActions;
            final actionsHeight = sideActions
                ? math.min(184.0, board.height)
                : math.min(96.0, bottomSpace);
            final buttonWidth = sideActions
                ? math.max(100.0, (size.width - board.width) / 2 - 40)
                : math.min(groupWidth, math.max(board.width * 1.1, 520.0));
            final actionLeft =
                sideActions ? board.right + 28 : (size.width - buttonWidth) / 2;
            final actionTop = sideActions
                ? board.bottom - actionsHeight
                : board.bottom + actionGap;
            final top = board.top < 126 ? 4.0 : math.max(62.0, board.top - 150);
            final titleHeight = math.max(1.0, board.top - top - 14);
            final l10n = AppLocalizations.of(context)!;
            return Stack(clipBehavior: Clip.hardEdge, children: [
              Positioned.fromRect(
                  rect: board.inflate(14),
                  child: IgnorePointer(
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFFFFD54F)
                              .withValues(alpha: burst * 0.65),
                          blurRadius: 28,
                          spreadRadius: 6)
                    ],
                  )))),
              if (burst > 0)
                Positioned.fill(
                    child: IgnorePointer(
                        child: CustomPaint(
                            painter: _CompletionParticles(
                                board, burst, track(570, 2600))))),
              Positioned(
                  left: (size.width -
                          (board.top < 126 ? size.width * .42 : groupWidth)) /
                      2,
                  top: top,
                  width: board.top < 126 ? size.width * .42 : groupWidth,
                  height: titleHeight,
                  child: IgnorePointer(
                      child: Opacity(
                          opacity: message,
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Transform.scale(
                                  scale: reduced
                                      ? 1
                                      : (message < .65
                                          ? .85 + .25 * message / .65
                                          : 1.10 - .10 * (message - .65) / .35),
                                  child: _CelebrationHeading(l10n.awesome)))))),
              if (actions > 0)
                Positioned(
                  left: actionLeft,
                  top: actionTop,
                  width: buttonWidth,
                  height: actionsHeight,
                  child: IgnorePointer(
                      ignoring: widget.timeline.phase !=
                          PuzzleCompletionPhase.actionsReady,
                      child: Opacity(
                          opacity: actions,
                          child: RepaintBoundary(
                              child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - actions)),
                                  child: Flex(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      direction: stacked
                                          ? Axis.vertical
                                          : Axis.horizontal,
                                      children: [
                                        Expanded(
                                            child: _CompletionButton(
                                                label: l10n.playAgain,
                                                icon:
                                                    'assets/puzzle/level_complete/replay_icon.webp',
                                                color: const Color(0xFFFF851A),
                                                onTap: () =>
                                                    _act(widget.onReplay))),
                                        SizedBox(
                                            width: stacked ? 0 : 18,
                                            height: stacked ? 16 : 0),
                                        Expanded(
                                            child: _CompletionButton(
                                                label: l10n.puzzleNewPuzzle,
                                                icon:
                                                    'assets/puzzle/level_complete/play_icon.webp',
                                                color: const Color(0xFF079CED),
                                                onTap: () =>
                                                    _act(widget.onNext))),
                                      ]))))),
                ),
            ]);
          }));
}

class _CompletionButton extends StatefulWidget {
  final String label;
  final String icon;
  final Color color;
  final VoidCallback onTap;
  const _CompletionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});
  @override
  State<_CompletionButton> createState() => _CompletionButtonState();
}

class _CompletionButtonState extends State<_CompletionButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final orange = widget.color == const Color(0xFFFF851A);
    final textShadow =
        orange ? const Color(0xFFB95608) : const Color(0xFF0067AD);
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? .97 : 1,
        duration: const Duration(milliseconds: 100),
        child: DecoratedBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: .12),
                    offset: const Offset(0, 7),
                    blurRadius: 10)
              ]),
          child: ElevatedButton(
            onPressed: widget.onTap,
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: const StadiumBorder()),
            child: SizedBox.expand(
                child: TweenAnimationBuilder<double>(
              tween: Tween(end: _pressed ? 1 : 0),
              duration: const Duration(milliseconds: 100),
              builder: (context, press, child) => CustomPaint(
                  key: const ValueKey('completion-button-face'),
                  painter: _CandyButtonPainter(orange, press),
                  child: Transform.translate(
                      offset: Offset(0, press * 3.5), child: child)),
              child: Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 12),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(widget.icon,
                            width: 42, height: 42, fit: BoxFit.contain),
                        const SizedBox(width: 12),
                        Flexible(
                            child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(widget.label,
                                    style: TextStyle(
                                        fontFamily: 'Baloo2 ExtraBold',
                                        fontSize: 26,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                              color: textShadow.withValues(
                                                  alpha: .65),
                                              offset: const Offset(0, 2),
                                              blurRadius: 1.5)
                                        ])))),
                      ])),
            )),
          ),
        ),
      ),
    );
  }
}

class _CandyButtonPainter extends CustomPainter {
  final bool orange;
  final double press;
  const _CandyButtonPainter(this.orange, this.press);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    void solid(Rect bounds, Color color) => canvas.drawRRect(
        RRect.fromRectAndRadius(bounds, Radius.circular(bounds.height / 2)),
        Paint()..color = color);

    // 1. Dark thin border around everything
    solid(rect, orange ? const Color(0xFFB94708) : const Color(0xFF005597));
    
    // 2. 3D depth block
    final depthRect = rect.deflate(1.5);
    solid(depthRect, orange ? const Color(0xFFE56A00) : const Color(0xFF0073CC));

    // 3. White face
    final face = Rect.fromLTRB(depthRect.left, depthRect.top, depthRect.right, depthRect.bottom - 8)
        .shift(Offset(0, press * 3.5));
    solid(face, Colors.white);
    
    // 4. Inner colored face
    final inner = face.deflate(4);
    final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: orange
            ? [
                const Color(0xFFFFF070),
                const Color(0xFFFFCC00),
                const Color(0xFFFF9900),
              ]
            : [
                const Color(0xFF88E8FF),
                const Color(0xFF20C5FF),
                const Color(0xFF0095FF),
              ],
        stops: const [0, .45, 1]);
    canvas.drawRRect(
        RRect.fromRectAndRadius(inner, Radius.circular(inner.height / 2)),
        Paint()..shader = gradient.createShader(inner));
        
    // 5. Top highlight shine
    final shine = Rect.fromLTRB(inner.left + 12, inner.top + 2,
        inner.right - 12, inner.top + inner.height * .4);
    canvas.drawRRect(
        RRect.fromRectAndRadius(shine, Radius.circular(shine.height / 2)),
        Paint()
          ..shader = const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x99FFFFFF), Color(0x00FFFFFF)])
              .createShader(shine));
              
    // 6. Thin specular reflection arc
    final specular = inner.deflate(1);
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(
        inner.left, inner.top, inner.right, inner.top + inner.height * .25));
    canvas.drawRRect(
        RRect.fromRectAndRadius(specular, Radius.circular(specular.height / 2)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white.withValues(alpha: .8));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CandyButtonPainter old) =>
      old.orange != orange || old.press != press;
}

class _CelebrationHeading extends StatelessWidget {
  final String text;
  const _CelebrationHeading(this.text);
  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
        fontFamily: 'Baloo2 ExtraBold',
        fontSize: 84,
        height: .92,
        letterSpacing: -1.0);
    // Each localized grapheme follows the same elliptical arc in every layer.
    // Keeping layers separate prevents a later glyph's outline hiding a face.
    Widget curved(TextStyle style) {
      final glyphs = text.characters.toList();
      return Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < glyphs.length; i++)
          Builder(builder: (_) {
            final t = glyphs.length < 2 ? 0.0 : 2 * i / (glyphs.length - 1) - 1;
            final y = 22 * (1 - math.sqrt(1 - .75 * t * t));
            return Transform.translate(
              offset: Offset(0, y),
              child: Transform.rotate(
                  angle: t * .22, child: Text(glyphs[i], style: style)),
            );
          }),
      ]);
    }

    Widget stroke(Color color, double width, {double dy = 0}) =>
        Transform.translate(
            offset: Offset(0, dy),
            child: curved(base.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = width
                  ..strokeJoin = StrokeJoin.round
                  ..color = color)));
    return Semantics(
        label: text,
        child: ExcludeSemantics(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 25, 32, 42),
          child: Stack(clipBehavior: Clip.none, children: [
            // Dark purple drop shadow/depth
            stroke(const Color(0xFF68129E), 30, dy: 8),
            // Outer Purple stroke
            stroke(const Color(0xFFA224F5), 30),
            // Inner Pink stroke
            stroke(const Color(0xFFFF57E5), 18),
            // White outline around the text
            stroke(Colors.white, 8),
            
            // Text Fill
            ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (rect) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFF700), // Vibrant Yellow
                          Color(0xFFFFB800), // Orange-Yellow
                          Color(0xFFFF7A00)  // Orange
                        ],
                        stops: [
                          0.0,
                          0.45,
                          1.0
                        ]).createShader(rect),
                child: curved(base.copyWith(color: Colors.white))),
          ]),
        )));
  }
}

class _CompletionParticles extends CustomPainter {
  final Rect board;
  final double opacity, progress;
  _CompletionParticles(this.board, this.opacity, this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    const colors = [
      Color(0xFFFFBA24),
      Color(0xFFFF70BA),
      Color(0xFF45CFFD),
      Color(0xFFAB7BEE)
    ];
    for (var i = 0; i < 8; i++) {
      final x =
          size.width * (i.isEven ? .04 + (i % 3) * .025 : .96 - (i % 3) * .025);
      final y = size.height * (1.18 - progress * 1.5 + (i % 4) * .12);
      final r = size.shortestSide * .035;
      final bounds =
          Rect.fromCenter(center: Offset(x, y), width: r * 1.6, height: r * 2);
      canvas.drawOval(
          bounds,
          Paint()
            ..shader =
                RadialGradient(center: const Alignment(-.4, -.5), colors: [
              Colors.white.withValues(alpha: opacity),
              colors[i % 4].withValues(alpha: opacity)
            ]).createShader(bounds));
      canvas.drawLine(
          Offset(x, y + r),
          Offset(x + r * .2, y + r * 3),
          Paint()
            ..color = Colors.white.withValues(alpha: opacity * .7)
            ..strokeWidth = 1);
    }
    for (var i = 0; i < 36; i++) {
      final x = size.width * ((i * .137) % 1);
      final y = size.height * ((i * .073 + progress * .8) % 1);
      // Keep the completed artwork unobstructed.
      if (board.inflate(8).contains(Offset(x, y))) continue;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(i + progress * 5);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(-2, -4, 4, 8), const Radius.circular(1)),
          Paint()..color = colors[i % 4].withValues(alpha: opacity));
      canvas.restore();
    }
    for (var i = 0; i < 16; i++) {
      final angle = i * math.pi * 2 / 16;
      final point = Offset(
          board.center.dx +
              math.cos(angle) * (board.width / 2 + 22 + progress * 18),
          board.center.dy +
              math.sin(angle) * (board.height / 2 + 16 + progress * 12));
      final paint = Paint()
        ..color = [
          const Color(0xFFFFCB35),
          const Color(0xFFFF76B8),
          const Color(0xFF60D4FF)
        ][i % 3]
            .withValues(alpha: opacity * 0.85);
      canvas.save();
      canvas.translate(point.dx, point.dy);
      canvas.rotate(angle + progress);
      final path = Path();
      for (var n = 0; n < 10; n++) {
        final radius = n.isEven ? 7.0 : 3.0;
        final x = math.cos(n * math.pi / 5) * radius,
            y = math.sin(n * math.pi / 5) * radius;
        if (n == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path..close(), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CompletionParticles old) =>
      old.opacity != opacity || old.progress != progress || old.board != board;
}
