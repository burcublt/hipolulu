import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A local snap/pop and short particle burst, independent for each placed piece.
class PuzzlePlacementEffect extends StatefulWidget {
  static const duration = Duration(milliseconds: 480);
  final Offset startOffset;
  final double startScale;
  final Widget child;
  final VoidCallback onCompleted;
  const PuzzlePlacementEffect(
      {super.key,
      required this.startOffset,
      required this.startScale,
      required this.child,
      required this.onCompleted});
  @override
  State<PuzzlePlacementEffect> createState() => _PuzzlePlacementEffectState();
}

class _PuzzlePlacementEffectState extends State<PuzzlePlacementEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: PuzzlePlacementEffect.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          widget.onCompleted();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
        child: ExcludeSemantics(
            child: AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => LayoutBuilder(builder: (context, bounds) {
        final t = _controller.value;
        final snap = Curves.easeOutCubic.transform((t / .42).clamp(0.0, 1.0));
        final pop = math.sin(((t - .32) / .68).clamp(0.0, 1.0) * math.pi);
        final scale = reduce
            ? 1.0
            : widget.startScale + (1 - widget.startScale) * snap + .055 * pop;
        return Stack(clipBehavior: Clip.none, fit: StackFit.expand, children: [
          Transform.translate(
              offset: reduce
                  ? Offset.zero
                  : Offset(widget.startOffset.dx * bounds.maxWidth * (1 - snap),
                      widget.startOffset.dy * bounds.maxHeight * (1 - snap)),
              child: Transform.scale(scale: scale, child: child)),
          if (!reduce)
            Positioned.fill(child: CustomPaint(painter: _SnapParticles(t))),
        ]);
      }),
    )));
  }
}

class _SnapParticles extends CustomPainter {
  final double progress;
  _SnapParticles(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final t = ((progress - .30) / .70).clamp(0.0, 1.0);
    if (t <= 0 || t >= 1) return;
    final radius =
        size.shortestSide * (.25 + .38 * Curves.easeOut.transform(t));
    final opacity = (1 - t) * .95;
    const colors = [
      Color(0xFFFFCA28),
      Color(0xFFFF71BC),
      Color(0xFF66D8FF),
      Color(0xFFAAEB64)
    ];
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi * 2 / 12;
      final center = size.center(Offset.zero) +
          Offset(math.cos(angle) * radius,
              math.sin(angle) * radius + t * t * size.height * .12);
      final r = (size.shortestSide * .023).clamp(1.5, 3.5) * (1 - .4 * t);
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: opacity);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle + t * 2);
      if (i.isEven) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset.zero, width: r * 1.3, height: r * 3),
                Radius.circular(r * .4)),
            paint);
      } else {
        final path = Path()
          ..moveTo(0, -r * 1.8)
          ..lineTo(r * .55, -r * .55)
          ..lineTo(r * 1.8, 0)
          ..lineTo(r * .55, r * .55)
          ..lineTo(0, r * 1.8)
          ..lineTo(-r * .55, r * .55)
          ..lineTo(-r * 1.8, 0)
          ..lineTo(-r * .55, -r * .55)
          ..close();
        canvas.drawPath(path, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SnapParticles oldDelegate) =>
      progress != oldDelegate.progress;
}
