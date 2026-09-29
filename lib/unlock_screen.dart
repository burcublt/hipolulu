import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'parent_gate.dart';

/// The caller supplies its orientation policy so returning restores that route.
Future<void> showUnlockScreen(BuildContext context,
    {required List<DeviceOrientation> returnOrientations}) async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  try {
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const UnlockScreen()),
    );
  } finally {
    await SystemChrome.setPreferredOrientations(returnOrientations);
  }
}

/// Presentation only: store pricing, legal URLs and purchase actions are not
/// connected yet. No local action grants access to locked content.
class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key});
  static const purple = Color(0xFF530AB4);

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  static const purple = UnlockScreen.purple;
  bool _gateOpen = false;
  Future<void> _verifyParent() async {
    if (_gateOpen) return;
    setState(() => _gateOpen = true);
    try {
      final passed = await showParentGate(context);
      if (!mounted || !passed) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.parentStoreUnavailable)));
    } finally {
      if (mounted) setState(() => _gateOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final topInset = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4DB),
      body: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/images/premium_background_portrait.webp',
            fit: BoxFit.cover, alignment: Alignment.topCenter),
        SafeArea(child: LayoutBuilder(builder: (context, bounds) {
          return Column(children: [
            const SizedBox(height: 44),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: (bounds.maxWidth - 32).clamp(320.0, 480.0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        verticalDirection: VerticalDirection.up,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(17, 16, 17, 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFCF5),
                              borderRadius: BorderRadius.circular(34),
                              border: Border.all(
                                  color: const Color(0xFFFFE6A2), width: 5),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x337F4500),
                                    blurRadius: 15,
                                    offset: Offset(0, 6))
                              ],
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _Benefit(
                                      icon: Icons.extension_rounded,
                                      color: const Color(0xFFF32F9A),
                                      title: l.unlockGames,
                                      subtitle: l.unlockGamesDetail),
                                  const Divider(
                                      height: 5, color: Color(0xFFEDE1D9)),
                                  _Benefit(
                                      icon: Icons.collections_rounded,
                                      color: const Color(0xFF20B7ED),
                                      title: l.unlockThemes,
                                      subtitle: l.unlockThemesDetail),
                                  const Divider(
                                      height: 5, color: Color(0xFFEDE1D9)),
                                  _Benefit(
                                      icon: Icons.auto_awesome_rounded,
                                      color: const Color(0xFFF250B1),
                                      title: l.unlockNew,
                                      subtitle: l.unlockNewDetail),
                                  const Divider(
                                      height: 5, color: Color(0xFFEDE1D9)),
                                  _Benefit(
                                      icon: Icons.star_rounded,
                                      color: const Color(0xFFFFBE13),
                                      title: l.unlockSafe,
                                      subtitle: l.unlockSafeDetail),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 8, 10, 10),
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [
                                          Color(0xFFFFF5AC),
                                          Color(0xFFFFFFF4),
                                          Color(0xFFFFF0A1)
                                        ]),
                                        border: Border.all(
                                            color: const Color(0xFFFFD735),
                                            width: 3),
                                        borderRadius:
                                            BorderRadius.circular(26)),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFFF42A4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Text(l.unlockBadge,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12))),
                                          Text(l.unlockAnnual,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 26, color: purple)),
                                          Text(l.unlockPriceUnavailable,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontFamily: 'Baloo2',
                                                  fontSize: 14,
                                                  color: Color(0xFF7D7092))),
                                        ]),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    key: const ValueKey('unlock-parent-gate'),
                                    onTap: _gateOpen ? null : _verifyParent,
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(minHeight: 54),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color(0xFFFF944A),
                                              Color(0xFFFF5100)
                                            ]),
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(
                                            color: const Color(0xFFFFB35E),
                                            width: 3),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Color(0x33C35E00),
                                              blurRadius: 6,
                                              offset: Offset(0, 4))
                                        ],
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                                child: Text(l.unlockSubscribe,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 25,
                                                        shadows: [
                                                          Shadow(
                                                              color: Color(
                                                                  0x778B3200),
                                                              offset:
                                                                  Offset(0, 2))
                                                        ]))),
                                            const SizedBox(width: 15),
                                            const CircleAvatar(
                                                radius: 18,
                                                backgroundColor: Colors.white,
                                                child: Icon(
                                                    Icons.chevron_right_rounded,
                                                    color: Color(0xFFFF5400),
                                                    size: 32)),
                                          ]),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(l.unlockBilling,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontFamily: 'Baloo2',
                                          fontSize: 11,
                                          height: 1.15,
                                          color: Color(0xFF756588))),
                                  const SizedBox(height: 10),
                                  Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 10,
                                      runSpacing: 2,
                                      children: [
                                        for (final label in [
                                          l.unlockPrivacy,
                                          l.unlockTerms,
                                          l.unlockRestore
                                        ])
                                          Semantics(
                                              button: true,
                                              enabled: false,
                                              child: Text(label,
                                                  style: const TextStyle(
                                                      fontFamily: 'Baloo2',
                                                      fontSize: 11,
                                                      color: Color(0xFF8B8299),
                                                      decoration: TextDecoration
                                                          .underline))),
                                      ]),
                                ]),
                          ),
                          Transform.translate(
                            offset: const Offset(0, 24),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 65),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 3),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        gradient: const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color(0xFFFFF28D),
                                              Color(0xFFFFC629)
                                            ]),
                                        border: Border.all(
                                            color: const Color(0xFFFFD45F),
                                            width: 2)),
                                    child: Text(l.unlockAll,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 23, color: purple)),
                                  ),
                                ]),
                          ),
                          SizedBox(
                              height:
                                  (bounds.maxHeight * .18).clamp(70.0, 170.0)),
                        ]),
                  ),
                ),
              ),
            )),
          ]);
        })),
        Positioned(
          top: (topInset - 28).clamp(16.0, double.infinity),
          left: 16,
          right: 16,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _NavigationPill(label: l.back, icon: Icons.chevron_left_rounded),
            _NavigationPill(
                label: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: Icons.close_rounded,
                iconOnly: true),
          ]),
        ),
      ]),
    );
  }
}

class _NavigationPill extends StatelessWidget {
  const _NavigationPill(
      {required this.label, required this.icon, this.iconOnly = false});
  final String label;
  final IconData icon;
  final bool iconOnly;
  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFFFFFCFF),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color(0xFFE7D4FF), width: 2)),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => Navigator.of(context).maybePop(),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon,
                    color: UnlockScreen.purple,
                    size: 28,
                    semanticLabel: iconOnly ? label : null),
                if (!iconOnly)
                  Text(label,
                      style: const TextStyle(
                          color: UnlockScreen.purple, fontSize: 19)),
              ])),
        ),
      );
}

class _Benefit extends StatelessWidget {
  const _Benefit(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle});
  final IconData icon;
  final Color color;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(children: [
          SizedBox(
              width: 60,
              child: Icon(icon, color: color, size: 43, shadows: const [
                Shadow(
                    color: Color(0x22682500),
                    offset: Offset(0, 3),
                    blurRadius: 3)
              ])),
          const SizedBox(width: 6),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(title,
                    style: const TextStyle(
                        color: UnlockScreen.purple, fontSize: 18, height: 1.1)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontFamily: 'Baloo2',
                        color: Color(0xFF726086),
                        fontSize: 12,
                        height: 1.1)),
              ])),
        ]),
      );
}
