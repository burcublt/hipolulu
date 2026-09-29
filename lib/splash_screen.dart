import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_scene.dart';

/// App initialization (locale and AssetService) finishes before runApp in main.
/// This screen only warms its artwork and plays the introduction once.
class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _timeline;
  bool _started = false;
  bool _ready = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    // Keep the intro upright; the destination screen owns its orientation.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _timeline = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
      animationBehavior: AnimationBehavior.preserve,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted && !_finished) {
          _finished = true;
          widget.onFinished();
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _warmScene();
    }
  }

  Future<void> _warmScene() async {
    // Use the same bounded decode sizes in precache and the live widgets.
    await Future.wait(SplashAssets.paths.map((path) => precacheImage(
          SplashAssets.provider(path),
          context,
          onError: (error, stack) => debugPrint('Splash asset $path: $error'),
        )));
    if (!mounted) return;
    setState(() => _ready = true);
    _timeline.forward();
  }

  @override
  void dispose() {
    _timeline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF83CEFF),
      body: _ready
          ? AnimatedBuilder(
              animation: _timeline,
              builder: (context, _) => SplashScene(
                seconds: _timeline.value * 4.5,
                reduceMotion: MediaQuery.of(context).disableAnimations,
              ),
            )
          : const SizedBox.expand(),
    );
  }
}
