import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

class SplashAssets {
  static const root = 'assets/splash/new/';
  static const shared = 'assets/puzzle/level_complete/';
  static const paths = [
    '${root}sky.webp',
    '${root}foreground.webp',
    '${root}ferris_wheel_base.webp',
    '${root}ferris_wheel_rotor.webp',
    '${root}hippo.webp',
    '${root}hippo_shadow.webp',
    '${root}logo.webp',
    '${root}balloon_pink.webp',
    '${root}balloon_purple.webp',
    '${root}balloon_orange.webp',
    '${root}balloon_yellow.webp',
    '${root}balloon_blue.webp',
    '${root}star_pink.webp',
    '${root}star_blue.webp',
    '${root}star_green.webp',
    '${root}star_smile.webp',
    '${shared}star.webp',
    '${root}lets_play.webp',
    '${shared}sparkle.webp',
    '${shared}pink_confetti.webp',
    '${shared}purple_confetti.webp',
    '${shared}blue_confetti.webp',
    '${shared}green_confetti.webp',
  ];

  static ImageProvider provider(String path) {
    final large = path.endsWith('/sky.webp') ||
        path.endsWith('/park_background.webp') ||
        path.endsWith('/foreground.webp');
    final medium = path.endsWith('/hippo.webp') || path.endsWith('/logo.webp');
    return ResizeImage(AssetImage(path),
        width: large
            ? 1800
            : medium
                ? 1000
                : 400);
  }
}

Widget _art(String name, {bool shared = false, BoxFit fit = BoxFit.contain}) =>
    Image(
        image: SplashAssets.provider(
            '${shared ? SplashAssets.shared : SplashAssets.root}$name.webp'),
        fit: fit,
        excludeFromSemantics: true);

double _phase(double seconds, double start, double end,
        [Curve curve = Curves.linear]) =>
    curve.transform(((seconds - start) / (end - start)).clamp(0.0, 1.0));

double _pop(double progress) => TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.12)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 0.94), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.0), weight: 20),
    ]).transform(progress);

/// A deterministic scene driven by the one 4.5-second controller.
class SplashScene extends StatelessWidget {
  final double seconds;
  final bool reduceMotion;
  const SplashScene(
      {super.key, required this.seconds, this.reduceMotion = false});

  @override
  Widget build(BuildContext context) {
    final time = reduceMotion ? 4.25 : seconds;
    return ClipRect(
      child: Transform.scale(
        scale: reduceMotion ? 1 : 1 + 0.02 * _phase(time, 4.35, 4.5),
        child: Stack(fit: StackFit.expand, children: [
          SplashBackground(seconds: time, reduceMotion: reduceMotion),
          SafeArea(child: LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final landscape = w > h;
            final logoWidth = math.min(w * (landscape ? 0.42 : 0.90), 560.0);
            final logoHeight =
                math.min(logoWidth / 3, h * (landscape ? 0.17 : 0.21));
            final hippoHeight = math.min(h * (landscape ? 0.53 : 0.43), 480.0);
            final hippoWidth = hippoHeight * 1145 / 1374;
            final logoTop = h * (landscape ? 0.065 : 0.16);
            final hippoBottom = h * 0.20;
            return Stack(clipBehavior: Clip.none, children: [
              Positioned(
                left: (w - hippoWidth * 0.95) / 2,
                bottom: hippoBottom - hippoHeight * 0.06,
                width: hippoWidth * 0.95,
                height: hippoHeight * 0.16,
                child: Opacity(
                  opacity: 0.65 * _phase(time, 0.85, 1.1),
                  child: Transform.scale(
                    scaleX:
                        0.6 + 0.4 * _phase(time, 0.85, 1.1, Curves.easeOutBack),
                    child: _art('hippo_shadow'),
                  ),
                ),
              ),
              Positioned(
                left: (w - hippoWidth) / 2,
                bottom: hippoBottom,
                width: hippoWidth,
                height: hippoHeight,
                child: AnimatedHippo(
                    seconds: time, travel: h, reduceMotion: reduceMotion),
              ),
              Positioned(
                key: const ValueKey('splash-logo'),
                left: (w - logoWidth) / 2,
                top: logoTop,
                width: logoWidth,
                height: logoHeight,
                child: Opacity(
                    opacity: _phase(time, 1.45, 1.6),
                    child: Transform.scale(
                        scale:
                            reduceMotion ? 1 : _pop(_phase(time, 1.45, 1.95)),
                        child: _art('logo'))),
              ),
              FloatingBalloons(
                  seconds: time, size: Size(w, h), reduceMotion: reduceMotion),
              StarEffects(
                  seconds: time,
                  size: Size(w, h),
                  logoTop: logoTop,
                  logoHeight: logoHeight,
                  reduceMotion: reduceMotion),
              ConfettiEffects(
                  seconds: time, size: Size(w, h), reduceMotion: reduceMotion),
              Positioned(
                key: const ValueKey('splash-play-label'),
                bottom: h * 0.075,
                left: w * 0.10,
                right: w * 0.10,
                height: h * (landscape ? 0.23 : 0.20),
                child: Opacity(
                    opacity: _phase(time, 3.5, 3.95),
                    child: Transform.scale(
                        scale: reduceMotion
                            ? 1
                            : 0.8 +
                                0.2 * _phase(time, 3.5, 4, Curves.easeOutBack),
                        child: FittedBox(
                            fit: BoxFit.contain,
                            child: LetsPlayLabel(
                                text:
                                    AppLocalizations.of(context)!.letsPlay)))),
              ),
              Positioned(
                bottom: h * 0.035,
                left: (w - math.min(w * 0.57, 340)) / 2,
                width: math.min(w * 0.57, 340),
                height: (h * 0.027).clamp(18, 26),
                child: Opacity(
                    opacity: _phase(time, 3.75, 3.95),
                    child:
                        SplashProgress(progress: _phase(seconds, 3.75, 4.5))),
              ),
            ]);
          })),
        ]),
      ),
    );
  }
}

class SplashBackground extends StatelessWidget {
  final double seconds;
  final bool reduceMotion;
  const SplashBackground(
      {super.key, required this.seconds, required this.reduceMotion});
  @override
  Widget build(BuildContext context) => Opacity(
        opacity: reduceMotion ? 1 : _phase(seconds, 0, 0.5),
        child: Transform.scale(
          scale: reduceMotion ? 1 : 1.025 - 0.025 * _phase(seconds, 0, 4.35),
          child: LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final landscape = w > h;
            final wheel = math.min(w * (landscape ? 0.19 : 0.32), h * 0.30);
            return Stack(fit: StackFit.expand, children: [
              // sky.webp already contains the complete park and path. Use
              // its left region, excluding the baked-in wheel, as one backdrop.
              const _CroppedScenery(
                  name: 'sky',
                  source: Size(1672, 941),
                  crop: Rect.fromLTWH(0, 0, 1130, 941)),
              Positioned(
                  right: w * 0.055,
                  top: h * (landscape ? 0.25 : 0.35),
                  width: wheel,
                  height: wheel * 1.3,
                  child: FerrisWheel(
                      seconds: seconds, reduceMotion: reduceMotion)),
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: h * 0.32,
                  child: _art('foreground', fit: BoxFit.fill)),
            ]);
          }),
        ),
      );
}

// The supplied sky includes a complete park and the park includes a baked-in
// wheel. Crop those regions at render time so the separate layers are not doubled.
class _CroppedScenery extends StatelessWidget {
  final String name;
  final Size source;
  final Rect crop;
  const _CroppedScenery(
      {required this.name, required this.source, required this.crop});
  @override
  Widget build(BuildContext context) => ClipRect(
          child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: crop.width,
          height: crop.height,
          child: ClipRect(
              child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: source.width,
            maxWidth: source.width,
            minHeight: source.height,
            maxHeight: source.height,
            child: Transform.translate(
                offset: -crop.topLeft, child: _art(name, fit: BoxFit.fill)),
          )),
        ),
      ));
}

class FerrisWheel extends StatelessWidget {
  final double seconds;
  final bool reduceMotion;
  const FerrisWheel(
      {super.key, required this.seconds, required this.reduceMotion});
  @override
  Widget build(BuildContext context) => Opacity(
        opacity: _phase(seconds, 0.25, 0.65),
        child: LayoutBuilder(
            builder: (context, constraints) => Stack(children: [
                  // Base top pivot and rotor hub share (0.5w, 0.5w).
                  Positioned(
                      left: 0,
                      right: 0,
                      top: constraints.maxWidth * 0.43,
                      height: constraints.maxWidth * 0.82,
                      child: _art('ferris_wheel_base')),
                  Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: constraints.maxWidth,
                      child: Transform.rotate(
                          angle: reduceMotion
                              ? 0
                              : math.max(0, seconds - 0.25) * 2 * math.pi / 40,
                          child: _art('ferris_wheel_rotor'))),
                ])),
      );
}

class AnimatedHippo extends StatelessWidget {
  final double seconds, travel;
  final bool reduceMotion;
  const AnimatedHippo(
      {super.key,
      required this.seconds,
      required this.travel,
      required this.reduceMotion});
  @override
  Widget build(BuildContext context) {
    final entry = _phase(seconds, 0.5, 1.15, Curves.easeOutBack);
    final landing = math.sin(_phase(seconds, 0.95, 1.3) * math.pi) * 0.035;
    final idle = reduceMotion
        ? 0.0
        : math.sin((seconds - 3.1) * math.pi * 2) * _phase(seconds, 3.1, 3.4);
    return Opacity(
        opacity: _phase(seconds, 0.5, 0.65),
        child: Transform.translate(
            offset:
                Offset(0, reduceMotion ? 0 : (1 - entry) * travel + idle * 2),
            child: Transform.rotate(
                angle: idle * 0.012,
                child: Transform.scale(
                    scaleX: 1 + landing,
                    scaleY: 1 - landing,
                    child: _art('hippo')))));
  }
}

class FloatingBalloons extends StatelessWidget {
  final double seconds;
  final Size size;
  final bool reduceMotion;
  const FloatingBalloons(
      {super.key,
      required this.seconds,
      required this.size,
      required this.reduceMotion});
  @override
  Widget build(BuildContext context) => IgnorePointer(
          child: Stack(
              children: List.generate(5, (i) {
        const colors = ['pink', 'purple', 'orange', 'yellow', 'blue'];
        const xs = [0.02, 0.15, 0.83, 0.04, 0.89];
        final p = _phase(seconds, 2.3 + i * 0.15, 4.4);
        final width = math.min(size.width * 0.11, size.height * 0.13);
        return Positioned(
            left: xs[i] * size.width +
                (reduceMotion ? 0 : math.sin(seconds * 2 + i) * 3),
            top: size.height * (0.65 - p * (0.59 - i * 0.025)),
            width: width,
            height: width * 1.5,
            child: Opacity(
                opacity: _phase(seconds, 2.3 + i * 0.15, 2.6 + i * 0.15),
                child: Transform.rotate(
                    angle: reduceMotion ? 0 : math.sin(seconds * 2 + i) * 0.05,
                    child: _art('balloon_${colors[i]}'))));
      })));
}

class StarEffects extends StatelessWidget {
  final double seconds, logoTop, logoHeight;
  final Size size;
  final bool reduceMotion;
  const StarEffects(
      {super.key,
      required this.seconds,
      required this.size,
      required this.logoTop,
      required this.logoHeight,
      required this.reduceMotion});
  @override
  Widget build(BuildContext context) => IgnorePointer(
          child: Stack(
              children: List.generate(9, (i) {
        const names = [
          'star_pink',
          'star_blue',
          'star_green',
          'star',
          'star_smile',
          'star_smile',
          'sparkle',
          'sparkle',
          'sparkle'
        ];
        const xs = [0.24, 0.43, 0.61, 0.76, 0.13, 0.83, 0.06, 0.91, 0.71];
        final start = 1.8 + i * 0.08;
        final progress = _phase(seconds, start, start + 0.35);
        final side = math.min(
            math.min(size.width * (i < 6 ? 0.10 : 0.07), size.height * 0.085),
            62.0);
        final top = i < 4
            ? math.max(0.0, logoTop - side * 0.55)
            : logoTop + logoHeight * (i < 6 ? 1.1 : 2.0);
        return Positioned(
            left: xs[i] * (size.width - side),
            top: top,
            width: side,
            height: side,
            child: Opacity(
                opacity: progress *
                    (i < 6 || reduceMotion
                        ? 1
                        : 0.65 + 0.35 * math.sin(seconds * 5 + i).abs()),
                child: Transform.rotate(
                    angle: (i - 4) * 0.08,
                    child: Transform.scale(
                        scale: reduceMotion ? 1 : _pop(progress),
                        child: _art(names[i], shared: i == 3 || i >= 6)))));
      })));
}

class ConfettiEffects extends StatelessWidget {
  final double seconds;
  final Size size;
  final bool reduceMotion;
  const ConfettiEffects(
      {super.key,
      required this.seconds,
      required this.size,
      required this.reduceMotion});
  @override
  Widget build(BuildContext context) => IgnorePointer(
          child: Stack(
              children: List.generate(8, (i) {
        const colors = ['pink', 'purple', 'blue', 'green'];
        final p = _phase(seconds, 3.4 + i * 0.025, 4.4);
        final side = math.min(size.shortestSide * 0.055, 30.0);
        return Positioned(
            left: size.width * (i.isEven ? 0.10 + i * 0.012 : 0.84 - i * 0.012),
            top: size.height * (0.30 + p * 0.30) + i % 3 * side,
            width: side,
            height: side * 1.5,
            child: Opacity(
                opacity:
                    _phase(seconds, 3.4, 3.6) * (1 - _phase(seconds, 4.2, 4.5)),
                child: Transform.rotate(
                    angle: reduceMotion ? 0 : p * (i.isEven ? 1 : -1),
                    child: _art('${colors[i % 4]}_confetti', shared: true))));
      })));
}

class LetsPlayLabel extends StatelessWidget {
  final String text;
  const LetsPlayLabel({super.key, required this.text});
  @override
  Widget build(BuildContext context) => Semantics(
        label: text,
        image: true,
        child: SizedBox(width: 600, height: 400, child: _art('lets_play')),
      );
}

class SplashProgress extends StatelessWidget {
  final double progress;
  const SplashProgress({super.key, required this.progress});
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final value = progress.clamp(0.0, 1.0);
        final starSize = constraints.maxHeight * 1.12;
        const inset = 3.5;
        final innerWidth = math.max(0.0, constraints.maxWidth - inset * 2);
        return Semantics(
            value: '${(value * 100).round()}%',
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned.fill(
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFFBE3),
                      Color(0xFFFFD271),
                      Color(0xFFFFF4C1)
                    ]),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xAAFFF3A5),
                      blurRadius: 12,
                      spreadRadius: 2),
                  BoxShadow(
                      color: Color(0x667C51BA),
                      blurRadius: 4,
                      offset: Offset(0, 2)),
                ],
              ))),
              Positioned.fill(
                  child: Padding(
                padding: const EdgeInsets.all(1.5),
                child: Container(
                    decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 1.5),
                  gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF6655CA), Color(0xFFADA6F3)]),
                )),
              )),
              Positioned.fill(
                  child: Padding(
                padding: const EdgeInsets.all(inset),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                              decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFB6FFFF),
                                  Color(0xFF36D6FF),
                                  Color(0xFF079AF8),
                                  Color(0xFF6DEBFF)
                                ],
                                stops: [
                                  0,
                                  0.35,
                                  0.72,
                                  1
                                ]),
                          )),
                        )),
                    Positioned(
                        left: 0,
                        top: 0,
                        width: innerWidth * value,
                        bottom: 0,
                        child: CustomPaint(painter: _ProgressSparkles(value))),
                    Positioned(
                        left: 3,
                        right: 3,
                        top: 0,
                        height: constraints.maxHeight * 0.25,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.8),
                                Colors.white.withValues(alpha: 0)
                              ]),
                        ))),
                  ]),
                ),
              )),
              Positioned(
                  left: (inset + innerWidth * value - starSize / 2)
                      .clamp(0.0, constraints.maxWidth - starSize),
                  top: (constraints.maxHeight - starSize) / 2,
                  width: starSize,
                  height: starSize,
                  child: _art('star', shared: true)),
            ]));
      });
}

class _ProgressSparkles extends CustomPainter {
  final double progress;
  const _ProgressSparkles(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final center = Offset(
          size.width * (i + 0.5) / 8, size.height * (i.isEven ? 0.30 : 0.68));
      final radius =
          size.height * (0.08 + 0.06 * math.sin(progress * 10 + i).abs());
      canvas.drawLine(
          center - Offset(radius, 0), center + Offset(radius, 0), paint);
      canvas.drawLine(
          center - Offset(0, radius), center + Offset(0, radius), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressSparkles old) =>
      old.progress != progress;
}
