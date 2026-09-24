import re

with open('lib/matching_game.dart', 'r') as f:
    code = f.read()

# 1. Add _WrongToast to the Stack in build
build_match = re.search(r'          \),\n          if \(_showWin\)', code)
if build_match:
    toast_widget = """          // ── WRONG TOAST ──
          Positioned(
            top: MediaQuery.of(context).size.height * 0.30,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: _WrongToast(show: _showWrongToast),
              ),
            ),
          ),
"""
    code = code[:build_match.start()] + toast_widget + code[build_match.start():]

# 2. Append _WrongToast, _WrongToastState at the end
wrong_toast_classes = """
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
          border:
              Border.all(color: const Color(0xFFFFFFFF).withValues(alpha: 0.8), width: 3),
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
"""

if "class _WrongToast" not in code:
    code += wrong_toast_classes

# 3. Remove unused variables and fields
code = code.replace("import 'package:hippolulu/l10n/game_l10n.dart';\n", "")
code = re.sub(r'  static const String parrot = [^;]+;\n\n', '', code)
code = re.sub(r'  static const String fox = [^;]+;\n\n', '', code)
code = re.sub(r'  static const String cat = [^;]+;\n\n', '', code)
code = re.sub(r'  static const String cow = [^;]+;\n\n', '', code)
code = re.sub(r'  static const String frog = [^;]+;\n\n', '', code)

with open('lib/matching_game.dart', 'w') as f:
    f.write(code)
