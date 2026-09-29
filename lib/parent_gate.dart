import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

/// Verification applies to this action only; it never grants subscription access.
Future<bool> showParentGate(BuildContext context) async =>
    await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: .48),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => const ParentGate(),
      transitionBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ) ??
    false;

class ParentGate extends StatefulWidget {
  const ParentGate({super.key});
  @override
  State<ParentGate> createState() => _ParentGateState();
}

class _ParentGateState extends State<ParentGate>
    with SingleTickerProviderStateMixin {
  final _random = Random();
  late final int _a = 5 + _random.nextInt(8);
  late final int _b = 3 + _random.nextInt(7);
  late final List<int> _answers = [_a + _b - 2, _a + _b, _a + _b + 1]
    ..shuffle(_random);
  late final AnimationController _shake = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 350));
  bool _wrong = false;
  bool _passed = false;
  bool _closing = false;

  void _finish(bool result) {
    if (_closing) return;
    _closing = true;
    Navigator.of(context).pop(result);
  }

  void _answer(int value) {
    if (_passed || _closing || _shake.isAnimating) return;
    setState(() {
      _passed = value == _a + _b;
      _wrong = !_passed;
    });
    if (_wrong && !MediaQuery.disableAnimationsOf(context)) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    const purple = Color(0xFF530AB4);
    return Material(
      type: MaterialType.transparency,
      child: Stack(children: [
        Positioned.fill(
            child: ClipRect(
                child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: const SizedBox.expand(),
        ))),
        SafeArea(
            child: Stack(children: [
          Positioned(
              top: 8,
              right: 16,
              child: IconButton.filled(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE9D6FF),
                    foregroundColor: purple),
                icon: const Icon(Icons.close_rounded, size: 30),
                onPressed: () => _finish(false),
              )),
          Positioned.fill(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 60, 22, 20),
            child: LayoutBuilder(
                builder: (context, bounds) => Center(
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: bounds.maxWidth.clamp(280.0, 390.0),
                            child: AnimatedBuilder(
                              animation: _shake,
                              builder: (_, child) => Transform.translate(
                                  offset: Offset(
                                      sin(_shake.value * pi * 6) *
                                          5 *
                                          (1 - _shake.value),
                                      0),
                                  child: child),
                              child: Column(
                                  // Paint the mascot after the card so its hands rest on the rim.
                                  verticalDirection: VerticalDirection.up,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      key: const ValueKey('parent-gate-card'),
                                      width: double.infinity,
                                      padding: const EdgeInsets.fromLTRB(
                                          24, 22, 24, 16),
                                      decoration: BoxDecoration(
                                          gradient: const RadialGradient(
                                              radius: 1,
                                              colors: [
                                                Colors.white,
                                                Color(0xFFFFF6DF)
                                              ]),
                                          border: Border.all(
                                              color: const Color(0xFFFFE49A),
                                              width: 4),
                                          borderRadius:
                                              BorderRadius.circular(32),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Color(0x337D5614),
                                                blurRadius: 12,
                                                offset: Offset(0, 5))
                                          ]),
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Semantics(
                                                liveRegion: true,
                                                child: Text(
                                                    _passed
                                                        ? l.parentGreat
                                                        : l.parentTitle,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Baloo2 ExtraBold',
                                                        fontSize: 27,
                                                        height: 1.15,
                                                        color: _passed
                                                            ? const Color(
                                                                0xFF169A24)
                                                            : purple))),
                                            const SizedBox(height: 10),
                                            Semantics(
                                                liveRegion: true,
                                                child: Text(
                                                    _passed
                                                        ? l.parentContinue
                                                        : _wrong
                                                            ? l.parentRetry
                                                            : l.parentPrompt,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Baloo2 SemiBold',
                                                        fontSize: 17,
                                                        height: 1.25,
                                                        color: _wrong
                                                            ? const Color(
                                                                0xFFC44374)
                                                            : const Color(
                                                                0xFF615475)))),
                                            const SizedBox(height: 16),
                                            if (_passed)
                                              Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                  child: IconButton.filled(
                                                      key: const ValueKey(
                                                          'parent-gate-continue'),
                                                      tooltip: l.parentContinue,
                                                      style: IconButton.styleFrom(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          padding:
                                                              EdgeInsets.zero),
                                                      icon: Image.asset(
                                                        'assets/images/check_icon.webp',
                                                        width: 76,
                                                        height: 76,
                                                        fit: BoxFit.contain,
                                                        excludeFromSemantics:
                                                            true,
                                                      ),
                                                      onPressed: () =>
                                                          _finish(true)))
                                            else ...[
                                              Container(
                                                  width: double.infinity,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 6),
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFEFE7FF),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                      border: Border.all(
                                                          color: const Color(
                                                              0xFFE4D7F9),
                                                          width: 2)),
                                                  child: Text('$_a + $_b = ?',
                                                      key: const ValueKey(
                                                          'parent-gate-question'),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'Baloo2 ExtraBold',
                                                          fontSize: 30,
                                                          color: purple))),
                                              const SizedBox(height: 12),
                                              Row(children: [
                                                for (var i = 0;
                                                    i < _answers.length;
                                                    i++) ...[
                                                  if (i > 0)
                                                    const SizedBox(width: 10),
                                                  Expanded(
                                                      child: OutlinedButton(
                                                          key: ValueKey(
                                                              'parent-answer-$i'),
                                                          style: OutlinedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              foregroundColor:
                                                                  purple,
                                                              minimumSize:
                                                                  const Size(
                                                                      0, 52),
                                                              padding: const EdgeInsets.symmetric(
                                                                  vertical: 6),
                                                              side: const BorderSide(
                                                                  color: Color(
                                                                      0xFFD2B8F4),
                                                                  width: 2),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          17))),
                                                          onPressed: () => _answer(_answers[i]),
                                                          child: Text('${_answers[i]}', style: const TextStyle(fontFamily: 'Baloo2 ExtraBold', fontSize: 27)))),
                                                ]
                                              ]),
                                              const SizedBox(height: 8),
                                              TextButton(
                                                  onPressed: () =>
                                                      _finish(false),
                                                  child: Text(l.parentCancel,
                                                      style: const TextStyle(
                                                          color: purple,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline))),
                                            ],
                                          ]),
                                    ),
                                    Transform.translate(
                                      offset: Offset(
                                          0,
                                          195 *
                                                  (_passed
                                                      ? 59 / 1128
                                                      : _wrong
                                                          ? 41 / 1159
                                                          : 56 / 1155) +
                                              3),
                                      child: Image.asset(
                                        _passed
                                            ? 'assets/images/hippo_correct.webp'
                                            : _wrong
                                                ? 'assets/images/hippo_wrong.webp'
                                                : 'assets/images/hippo_question.webp',
                                        height: 195,
                                        width: 260,
                                        fit: BoxFit.contain,
                                        alignment: Alignment.bottomCenter,
                                        gaplessPlayback: true,
                                        excludeFromSemantics: true,
                                      ),
                                    ),
                                  ]),
                            ),
                          )),
                    )),
          )),
        ])),
      ]),
    );
  }
}
