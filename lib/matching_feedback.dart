import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

enum FeedbackState { none, correct, wrong }

abstract class MatchingFeedbackConfig {
  static const correctMs = 1450;
  static const wrongMs = 1300;
  static const finalMs = 1000;
  static const closeMs = 1050;
  static const maxWidth = 330.0;
  static const maxHeight = 285.0;
  static const reactionWidth =
      .90; // The fitted grid is narrower than the board.
  static const reactionHeight = .66;
  static const reactionAlignment = Alignment.center;
  static const textSize = 30.0;
  static const spotlightStart = 850.0;
  static const spotlightPeak = 900.0;
  static const spotlightRelease = 1200.0;
  static double spotlight(double ms) =>
      _interval(ms, spotlightStart, spotlightPeak) *
      (1 - _interval(ms, spotlightRelease, correctMs.toDouble()));
  static const spotlightScale = 1.08;
  static const bounce = .07;
  static const wiggle = .025;
}

double _interval(double time, double start, double end) =>
    ((time - start) / (end - start)).clamp(0.0, 1.0);

/// Restricted to the board's bounds so navigation and instructions stay visible.
class MatchingFeedbackOverlay extends StatelessWidget {
  final FeedbackState state;
  final double elapsedMs;
  final int messageIndex;
  const MatchingFeedbackOverlay(
      {super.key,
      required this.state,
      required this.elapsedMs,
      required this.messageIndex});

  static const assets = [
    'assets/matching/ui/hippo_correct.webp',
    'assets/matching/ui/hippo_try_again.webp',
    'assets/matching/ui/question_mark.webp',
    'assets/splash/new/star_smile.webp',
    'assets/splash/new/star_pink.webp',
    'assets/splash/new/star_blue.webp',
    'assets/splash/new/star_green.webp',
    'assets/puzzle/level_complete/sparkle.webp',
  ];

  @override
  Widget build(BuildContext context) {
    final correct = state == FeedbackState.correct;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final t = elapsedMs;
    final fade = 1 - _interval(t, correct ? 700 : 850, correct ? 850 : 1050);
    final enter = _interval(t, 180, correct ? 320 : 340);
    final l = AppLocalizations.of(context)!;
    final messages = correct
        ? [l.matchGreat, l.matchAwesome, l.matchYay]
        : [l.matchTryAgain, l.matchAlmost, l.matchYouCan];
    return IgnorePointer(
      child: Semantics(
        liveRegion: true,
        label: messages[messageIndex % 3],
        child:
            ExcludeSemantics(child: LayoutBuilder(builder: (context, bounds) {
          final baseWidth = math.min(
              bounds.maxWidth * MatchingFeedbackConfig.reactionWidth,
              MatchingFeedbackConfig.maxWidth);
          final baseHeight = math.min(
              math.min(bounds.maxHeight * MatchingFeedbackConfig.reactionHeight,
                  MatchingFeedbackConfig.maxHeight),
              baseWidth * .95);
          final region = MatchingFeedbackConfig.reactionAlignment.inscribe(
              Size(baseWidth, baseHeight), Offset.zero & bounds.biggest);
          final width = region.width;
          final height = region.height;
          return Stack(children: [
            Positioned.fromRect(
                rect: region,
                child: SizedBox(
                  key: const ValueKey('reaction-group'),
                  width: width,
                  height: height,
                  child: Opacity(
                      opacity: fade,
                      child: Stack(clipBehavior: Clip.none, children: [
                        // A small translucent backing keeps faces and text legible without a modal veil.
                        Positioned.fill(
                            child: DecoratedBox(
                                decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(80),
                          gradient: RadialGradient(colors: [
                            Colors.white.withValues(alpha: .10),
                            Colors.white.withValues(alpha: 0)
                          ]),
                        ))),
                        Align(
                            alignment: const Alignment(0, -1),
                            child: FractionallySizedBox(
                              widthFactor: .68,
                              heightFactor: .78,
                              child: Opacity(
                                  opacity: enter,
                                  child: Transform.scale(
                                    scale: reduce
                                        ? 1
                                        : .78 +
                                            .22 *
                                                Curves.easeOutBack
                                                    .transform(enter),
                                    child: Image.asset(assets[correct ? 0 : 1],
                                        fit: BoxFit.contain),
                                  )),
                            )),
                        for (var i = 0; i < 4; i++)
                          _decoration(i, correct, width, height, reduce),
                        if (correct)
                          for (var i = 0; i < 2; i++)
                            Positioned(
                                left: width * (i == 0 ? .16 : .70),
                                top: height * (i == 0 ? .46 : .12),
                                child: Opacity(
                                    opacity: reduce
                                        ? .7
                                        : math
                                            .sin(_interval(
                                                    t, 200 + i * 90, 800) *
                                                math.pi)
                                            .abs(),
                                    child: Image.asset(assets[7],
                                        width: width * .14))),
                        Align(
                            alignment: const Alignment(0, .80),
                            child: FractionallySizedBox(
                              widthFactor: .96,
                              heightFactor: .20,
                              child: Opacity(
                                opacity: _interval(t, 250, 500),
                                child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: MotivationText(
                                        messages[messageIndex % 3])),
                              ),
                            )),
                      ])),
                ))
          ]);
        })),
      ),
    );
  }

  Widget _decoration(
      int i, bool correct, double width, double height, bool reduce) {
    final pop = _interval(elapsedMs, (correct ? 180 : 220) + i * 60,
        (correct ? 300 : 340) + i * 60);
    const anchors = [
      Offset(.03, .18),
      Offset(.78, .08),
      Offset(.09, .58),
      Offset(.80, .53)
    ];
    final point = anchors[i];
    return Positioned(
      left: width * point.dx,
      top: height * point.dy -
          (reduce ? 0 : 8 * _interval(elapsedMs, 850, 1050)),
      child: Opacity(
          opacity: pop,
          child: Transform.rotate(
            angle: [-.30, .21, -.18, .43][i],
            child: Transform.scale(
                scale: reduce ? 1 : Curves.easeOutBack.transform(pop),
                child: Image.asset(correct ? assets[3 + i] : assets[2],
                    width: width *
                        (correct
                            ? (i == 0 ? .16 : .12)
                            : [.10, .12, .14, .16][i]),
                    height: height * (correct ? .20 : [.12, .14, .16, .18][i]),
                    fit: BoxFit.contain)),
          )),
    );
  }
}

class MotivationText extends StatelessWidget {
  final String text;
  const MotivationText(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Stack(children: [
        Text(text,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
                fontFamily: 'Baloo2 ExtraBold',
                fontSize: MatchingFeedbackConfig.textSize,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = Colors.white)),
        Text(text,
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(
                fontFamily: 'Baloo2 ExtraBold',
                fontSize: MatchingFeedbackConfig.textSize,
                color: Color(0xFF6025C7),
                shadows: [
                  Shadow(
                      color: Color(0x44A052CC),
                      offset: Offset(0, 3),
                      blurRadius: 3)
                ])),
      ]);
}

class MatchedCardEffect extends StatelessWidget {
  final FeedbackState state;
  final double elapsedMs;
  final Widget child;
  const MatchedCardEffect(
      {super.key,
      required this.state,
      required this.elapsedMs,
      required this.child});
  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final correct = state == FeedbackState.correct;
    final scale = correct && !reduce
        ? 1 +
            MatchingFeedbackConfig.bounce *
                math.sin(_interval(elapsedMs, 80, 300) * math.pi)
        : 1.0;
    final angle = state == FeedbackState.wrong && !reduce
        ? MatchingFeedbackConfig.wiggle *
            math.sin(_interval(elapsedMs, 120, 300) * math.pi * 4)
        : 0.0;
    return Transform.rotate(
        angle: angle,
        child: Transform.scale(
            scale: scale,
            child: DecoratedBox(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: correct
                        ? [
                            BoxShadow(
                                color: const Color(0xFFFFC52A).withValues(
                                    alpha: .65 *
                                        (1 - _interval(elapsedMs, 850, 1050))),
                                blurRadius: 18,
                                spreadRadius: 3)
                          ]
                        : []),
                child: child)));
  }
}

/// Painted after the grid and reaction; no gesture or model state lives here.
class SpotlightCard extends StatelessWidget {
  final double strength;
  final double elapsedMs;
  final Widget child;
  const SpotlightCard(
      {super.key,
      required this.strength,
      required this.elapsedMs,
      required this.child});

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final pop = _interval(elapsedMs, 900, 1050);
    final release = 1 - _interval(elapsedMs, 1200, 1450);
    return Transform.scale(
      key: const ValueKey('spotlight-transform'),
      scale: 1 + (MatchingFeedbackConfig.spotlightScale - 1) * strength,
      child: DecoratedBox(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(22), boxShadow: [
          BoxShadow(
              color: const Color(0xFFFFC52A).withValues(
                  alpha: strength *
                      (reduce ? .75 : .7 + .1 * math.sin(elapsedMs / 70))),
              blurRadius: 18 + 6 * strength,
              spreadRadius: 4 * strength)
        ]),
        child: Stack(fit: StackFit.expand, clipBehavior: Clip.none, children: [
          child,
          if (strength > 0)
            Positioned(
              top: 5,
              right: 5,
              child: Opacity(
                opacity: release,
                child: Transform.scale(
                  scale: reduce ? 1 : Curves.easeOutBack.transform(pop),
                  child: Container(
                      key: const ValueKey('golden-check'),
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFC328),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)),
                      child: const Icon(Icons.check_rounded,
                          size: 18, color: Colors.white)),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
