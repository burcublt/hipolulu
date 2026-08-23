import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hippolulu/l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────
//  HIPPO LULU — ANIMATED SPLASH SCREEN
//  Implements the "Hippo Lulu Splash — Flutter Developer Handoff" spec:
//  layered WebP assets, a single 3.2s AnimationController driving every
//  sub-animation via Interval, responsive scaling against a 2048×2732
//  reference design (with a tablet max-content-width cap), a touch of
//  parallax on the background layers, and asset precaching before the
//  first frame plays.
//
//  ── ASSET CHECKLIST — add these under assets/splash/ and register the
//  folder in pubspec.yaml (`assets: - assets/splash/`) before running:
//    sky.webp             park_background.webp   foreground.webp
//    logo.webp            hippo.webp
//    balloon_pink.webp    balloon_purple.webp    balloon_orange.webp
//    balloon_yellow.webp  balloon_blue.webp
//    star.webp            sparkle.webp
// ─────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  /// Called once the 3.2s sequence (including the fade-out) has finished.
  /// The caller is responsible for navigating away — see main.dart, which
  /// pushes MainMenu here exactly like the old 2-second timer splash did.
  final VoidCallback onFinished;

  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Every sub-animation below is defined as an Interval (a *fraction* of
  // this total), so changing this one number stretches or compresses the
  // whole sequence proportionally — no need to touch anything else.
  // Doc originally called for 3.2s; bumped up so it doesn't feel rushed.
  static const _totalDuration = Duration(milliseconds: 5000);

  static const List<String> _assetPaths = [
    'assets/splash/sky.webp',
    'assets/splash/park_background.webp',
    'assets/splash/foreground.webp',
    'assets/splash/logo.webp',
    'assets/splash/hippo.webp',
    'assets/splash/balloon_pink.webp',
    'assets/splash/balloon_purple.webp',
    'assets/splash/balloon_orange.webp',
    'assets/splash/balloon_yellow.webp',
    'assets/splash/balloon_blue.webp',
    'assets/splash/star.webp',
    'assets/splash/sparkle.webp',
  ];

  late final AnimationController _ctrl;
  // Separate, continuously-repeating controller that drives everything
  // that keeps moving *after* it has entered (hippo breathing, balloons
  // floating, sparkles twinkling) — the main _ctrl only plays once.
  late final AnimationController _idleCtrl;

  late final Animation<double> _bgAnim;
  late final Animation<double> _logoAnim;
  late final Animation<double> _hippoAnim;
  late final Animation<double> _shineAnim;
  late final Animation<double> _playTextAnim;
  late final Animation<double> _loadingAnim;
  late final Animation<double> _fadeOutAnim;

  bool _ready = false;
  bool _finished = false;
  bool _precacheStarted = false;

  @override
  void initState() {
    super.initState();
    _applyPortraitLock();

    _ctrl = AnimationController(vsync: this, duration: _totalDuration);
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _bgAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.00, 0.13, curve: Curves.easeOut),
    );
    _logoAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.12, 0.31, curve: Curves.easeOutBack),
    );
    _hippoAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.28, 0.50, curve: Curves.easeOutBack),
    );
    // Shine sweep across the logo.
    _shineAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.65, 0.88, curve: Curves.easeInOut),
    );
    _playTextAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.75, 0.94, curve: Curves.easeOutBack),
    );
    _loadingAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.75, 0.97, curve: Curves.easeInOut),
    );
    // Doc calls for a 250-350ms fade at 3.2s; 0.90->1.00 of a 3200ms
    // controller is ~320ms, matching that more closely than a literal
    // 0.94 cut would.
    _fadeOutAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.90, 1.00, curve: Curves.easeIn),
    );

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted && !_finished) {
        _finished = true;
        _releaseOrientationLock();
        widget.onFinished();
      }
    });
  }

  /// Yalnızca destekleyen cihaz/modlarda dikey kilitler.
  /// iPad pencereli (Stage Manager / Split View) modundaysa hatayı yakalar, çökmesini önler.
  Future<void> _applyPortraitLock() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } catch (e) {
      debugPrint("Oryantasyon kilitlenemedi (iPad Pencereli Mod): $e");
    }
  }

  /// Kilidi kaldırır; böylece iPad çevrildiğinde ekran tekrar dönebilir.
  Future<void> _releaseOrientationLock() async {
    try {
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    } catch (e) {
      debugPrint("Oryantasyon kilit kaldırma hatası: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // precacheImage() needs an InheritedWidget lookup (MediaQuery) under
    // the hood, which isn't available yet during initState() — Flutter
    // throws if you try. didChangeDependencies() runs right after, with a
    // fully attached context, and is the documented place for this. The
    // guard makes sure we still only kick this off once.
    if (!_precacheStarted) {
      _precacheStarted = true;
      _precacheThenStart();
    }
  }

  Future<void> _precacheThenStart() async {
    // Load every splash layer before the first frame animates, so nothing
    // pops in half-loaded partway through the sequence.
    await Future.wait(
      _assetPaths.map((p) => precacheImage(AssetImage(p), context)),
    );
    if (!mounted) return;
    setState(() => _ready = true);
    _ctrl.forward();
  }

  @override
  void dispose() {
    // Safety net: if this widget is ever removed before the sequence
    // finished on its own (status listener above), still release the
    // portrait lock rather than leaving the app stuck in portrait.
    if (!_finished) {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values)
          .catchError((_) {});
    }
    _ctrl.dispose();
    _idleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6FD8F5),
      body: !_ready
          ? const SizedBox.shrink()
          : AnimatedBuilder(
              animation: Listenable.merge([_ctrl, _idleCtrl]),
              builder: (context, _) => FadeTransition(
                // Reverse: opacity goes 1 -> 0 over the fade-out interval.
                opacity: ReverseAnimation(_fadeOutAnim),
                child: _SplashLayers(
                  bg: _bgAnim.value,
                  logo: _logoAnim.value,
                  hippo: _hippoAnim.value,
                  shine: _shineAnim.value,
                  playText: _playTextAnim.value,
                  loading: _loadingAnim.value,
                  idle: _idleCtrl.value,
                  ctrlValue: _ctrl.value,
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────
//  LAYER STACK
// ─────────────────────────────────────────────
class _SplashLayers extends StatelessWidget {
  final double bg, logo, hippo, shine, playText, loading, idle, ctrlValue;

  const _SplashLayers({
    required this.bg,
    required this.logo,
    required this.hippo,
    required this.shine,
    required this.playText,
    required this.loading,
    required this.idle,
    required this.ctrlValue,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Reference design: the handoff doc's "2048×2732" is the *physical*
    // pixel export of a 12.9" iPad Pro (its @2x design resolution) — but
    // MediaQuery.sizeOf() returns *logical* points, not physical pixels.
    // Comparing logical size directly against a physical-pixel reference
    // made everything come out roughly half the intended size on phones.
    // Halving the reference converts it to the iPad's actual logical
    // resolution (1024×1366), which is what MediaQuery deals in.
    //
    // Scale off the *shorter* screen side instead of min(scaleX, scaleY).
    // min(scaleX, scaleY) silently switches which dimension is "binding"
    // depending on orientation — width-bound in portrait, height-bound in
    // landscape — so the exact same physical device could render the logo
    // at a completely different proportion just from rotating (which is
    // exactly what made phone vs. tablet look inconsistent, since this
    // app runs portrait on phone but landscape on tablet). The shorter
    // side stays conceptually the same thing (portrait: width, landscape:
    // height), so basing scale on it keeps every element the same
    // proportion of the screen on any device, in any orientation.
    final shortSide = min(size.width, size.height);
    final baseScale = shortSide / 1024;

    const maxContentWidth = 1000.0;
    final fgScale = min(baseScale, maxContentWidth / 1024);

    const logoY = -0.70;
    const hippoY = 0.52;
    const textY = 0.90;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        // ── Background: sky → park → foreground, subtle parallax slide-in ──
        _BgLayer(
          asset: 'assets/splash/sky.webp',
          progress: bg,
          parallaxFrac: 0.008,
          screenHeight: size.height,
        ),
        _BgLayer(
          asset: 'assets/splash/park_background.webp',
          progress: bg,
          parallaxFrac: 0.016,
          screenHeight: size.height,
        ),
        _BgLayer(
          asset: 'assets/splash/foreground.webp',
          progress: bg,
          parallaxFrac: 0.026,
          screenHeight: size.height,
        ),

        // ── Balloons (behind logo/hippo, in front of scenery) ──
        ..._buildBalloons(size, fgScale),

        // ── Stars / sparkles ──
        ..._buildParticles(size, fgScale),

        // ── Logo ──
        Align(
          alignment: const Alignment(0, logoY),
          child: Transform.translate(
            offset: Offset(0, (1 - logo) * -0.12 * size.height),
            child: Opacity(
              opacity: logo.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: (0.82 + 0.18 * logo) *
                    // small extra bounce/pulse while the shine sweeps by
                    (1 + 0.025 * sin(pi * shine)),
                child: SizedBox(
                  width: 580 * fgScale,
                  child: _ShineLogo(shine: shine),
                ),
              ),
            ),
          ),
        ),

        // ── Hippo ──
        // Big and up-front, dominating the lower portion of the frame —
        // arms wide, close to the "viewer", not a small character off in
        // the distance.
        Align(
          alignment: const Alignment(0, hippoY),
          child: Transform.translate(
            offset: Offset(0, (1 - hippo) * 0.35 * size.height),
            child: Opacity(
              opacity: hippo.clamp(0.0, 1.0),
              child: Transform.scale(
                // Entrance 0.92->1.00, then a gentle breathing loop
                // (1.00 -> 1.015 -> 1.00) once it's fully in.
                scale: (0.92 + 0.08 * hippo) *
                    (1 + 0.015 * hippo * sin(2 * pi * idle)),
                child: Image.asset(
                  'assets/splash/hippo.webp',
                  width: 720 * fgScale,
                ),
              ),
            ),
          ),
        ),

        // ── "Let's Play" + loading bar ──
        Align(
          alignment: const Alignment(0, textY),
          child: Opacity(
            opacity: playText.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.85 + 0.15 * playText,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)?.letsPlay ?? "Haydi Oynayalım!",
                    style: TextStyle(
                      fontFamily: 'Baloo2 ExtraBold',
                      fontWeight: FontWeight.bold,
                      fontSize: 30 * fgScale.clamp(0.55, 1.0) + 12,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Color(0x40000000),
                          offset: Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16 * fgScale),
                  _LoadingBar(progress: loading, width: 260 * fgScale),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBalloons(Size size, double fgScale) {
    final specs = [
      const _BalloonSpec(
          'assets/splash/balloon_pink.webp', 0, 10.0, 0.0, -0.85, -0.30, 150.0),
      const _BalloonSpec('assets/splash/balloon_purple.webp', 70, 14.0, pi / 2,
          0.88, -0.18, 170.0),
      const _BalloonSpec('assets/splash/balloon_orange.webp', 140, 17.0, pi,
          -0.78, 0.28, 140.0),
      const _BalloonSpec('assets/splash/balloon_yellow.webp', 210, 9.0,
          3 * pi / 2, 0.70, 0.42, 130.0),
      const _BalloonSpec('assets/splash/balloon_blue.webp', 280, 13.0, pi / 4,
          0.95, 0.05, 160.0),
    ];

    const windowStartFrac = 0.40;
    const windowEndFrac = 0.70;
    const entranceMs = 450;
    const totalMs = 5000; // keep in sync with _SplashScreenState._totalDuration

    return specs.map((s) {
      final startFrac = windowStartFrac + s.delayMs / totalMs;
      final endFrac =
          min(windowEndFrac + 0.05, startFrac + entranceMs / totalMs);
      final entrance = _fractionOf(ctrlValue, startFrac, endFrac);

      final floatY = s.amplitude * sin(2 * pi * idle + s.phase) * entrance;

      return Align(
        alignment: Alignment(s.dx, s.dy),
        child: Opacity(
          opacity: entrance.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, floatY),
            child: Transform.scale(
              scale: 0.75 + 0.25 * entrance,
              child: Image.asset(s.asset, width: s.width * fgScale),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildParticles(Size size, double fgScale) {
    // A handful of stars + sparkles scattered around the logo/hippo, each
    // with its own delay/phase/duration so they don't all blink in sync.
    final starSpecs = [
      const _StarSpec(-0.55, -0.55, 0.0, 46.0),
      const _StarSpec(0.60, -0.45, 0.08, 38.0),
      const _StarSpec(-0.35, 0.60, 0.16, 34.0),
      const _StarSpec(0.50, 0.55, 0.05, 42.0),
    ];
    final sparkleSpecs = [
      const _SparkleSpec(-0.70, -0.15, 0.0, 0.9, 22.0),
      const _SparkleSpec(0.75, -0.05, 0.30, 1.3, 20.0),
      const _SparkleSpec(-0.20, -0.65, 0.55, 0.7, 18.0),
      const _SparkleSpec(0.25, -0.62, 0.80, 1.1, 24.0),
      const _SparkleSpec(-0.60, 0.15, 0.20, 1.0, 20.0),
      const _SparkleSpec(0.65, 0.30, 0.65, 0.85, 18.0),
    ];

    const windowStartFrac = 0.53;
    const windowEndFrac = 0.78;

    final stars = starSpecs.map((s) {
      final startFrac = windowStartFrac + s.delayFrac * 0.15;
      final endFrac = min(windowEndFrac, startFrac + 0.10);
      final entrance = _fractionOf(ctrlValue, startFrac, endFrac);
      return Align(
        alignment: Alignment(s.dx, s.dy),
        child: Opacity(
          opacity: entrance.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.5 + 0.5 * entrance,
            child: Image.asset('assets/splash/star.webp',
                width: s.width * fgScale),
          ),
        ),
      );
    });

    final sparkles = sparkleSpecs.map((s) {
      final startFrac = windowStartFrac + s.delayFrac * 0.15;
      final endFrac = min(windowEndFrac, startFrac + 0.08);
      final entrance = _fractionOf(ctrlValue, startFrac, endFrac);
      // Continuous twinkle once visible: opacity 0.25<->1, scale 0.75<->1.15.
      final t = (idle * s.speed + s.delayFrac) % 1.0;
      final twinkle = (sin(2 * pi * t) + 1) / 2; // 0..1
      final opacity = (0.25 + 0.75 * twinkle) * entrance;
      final scale = (0.75 + 0.40 * twinkle) * (0.4 + 0.6 * entrance);
      return Align(
        alignment: Alignment(s.dx, s.dy),
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale,
            child: Image.asset('assets/splash/sparkle.webp',
                width: s.width * fgScale),
          ),
        ),
      );
    });

    return [...stars, ...sparkles];
  }
}

/// Maps [value] (0..1, from the *whole* controller) to a local 0..1
/// progress within [start]..[end], clamped outside that range. A tiny
/// standalone helper instead of another CurvedAnimation per particle —
/// there can be a dozen of these, each with a different window.
double _fractionOf(double value, double start, double end) {
  if (end <= start) return value >= start ? 1.0 : 0.0;
  return ((value - start) / (end - start)).clamp(0.0, 1.0);
}

/// Small plain classes standing in for tuples (kept instead of Dart 3
/// record syntax so this file also compiles on SDK constraints below
/// 3.0.0 — see the `_BoardCell` class in puzzle_arena.dart for the same
/// pattern).
class _BalloonSpec {
  final String asset;
  final int delayMs;
  final double amplitude;
  final double phase;
  final double dx;
  final double dy;
  final double width;
  const _BalloonSpec(this.asset, this.delayMs, this.amplitude, this.phase,
      this.dx, this.dy, this.width);
}

class _StarSpec {
  final double dx, dy, delayFrac, width;
  const _StarSpec(this.dx, this.dy, this.delayFrac, this.width);
}

class _SparkleSpec {
  final double dx, dy, delayFrac, speed, width;
  const _SparkleSpec(this.dx, this.dy, this.delayFrac, this.speed, this.width);
}

// ─────────────────────────────────────────────
//  BACKGROUND LAYER (fade + tiny parallax slide-in)
// ─────────────────────────────────────────────
class _BgLayer extends StatelessWidget {
  final String asset;
  final double progress; // 0..1
  final double parallaxFrac; // fraction of screen height to slide in from
  final double screenHeight;

  const _BgLayer({
    required this.asset,
    required this.progress,
    required this.parallaxFrac,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: progress.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - progress) * parallaxFrac * screenHeight),
          child: Image.asset(asset, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  LOGO WITH ONE-SHOT SHINE SWEEP
// ─────────────────────────────────────────────
class _ShineLogo extends StatelessWidget {
  final double shine; // 0..1, sweep progress

  const _ShineLogo({required this.shine});

  @override
  Widget build(BuildContext context) {
    final logoImage = Image.asset('assets/splash/logo.webp');
    if (shine <= 0.0 || shine >= 1.0) return logoImage;

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (rect) {
        // A narrow bright band that sweeps from left to right across the
        // logo's bounds as `shine` goes 0 -> 1.
        final sweep = shine * 1.6 - 0.3; // overshoot both edges a bit
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Colors.transparent,
            Color(0x00FFFFFF),
            Color(0xCCFFFFFF),
            Color(0x00FFFFFF),
            Colors.transparent,
          ],
          stops: [
            0.0,
            (sweep - 0.18).clamp(0.0, 1.0),
            sweep.clamp(0.0, 1.0),
            (sweep + 0.18).clamp(0.0, 1.0),
            1.0,
          ],
        ).createShader(rect);
      },
      child: logoImage,
    );
  }
}

// ─────────────────────────────────────────────
//  LOADING BAR
// ─────────────────────────────────────────────
class _LoadingBar extends StatelessWidget {
  final double progress; // 0..1
  final double width;

  const _LoadingBar({required this.progress, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 14,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD93D), Color(0xFFFF9E2C)],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}
