import 'package:flutter/material.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'package:hippolulu/locale_provider.dart';

class LanguagePickerSheet extends StatelessWidget {
  const LanguagePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LanguagePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = LocaleProviderScope.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F4FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5C28A0).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                l10n.languageTitle,
                style: const TextStyle(
                  fontFamily: 'Baloo2 ExtraBold',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF5C28A0),
                ),
              ),
              const SizedBox(height: 16),
              _LanguageTile(
                label: l10n.languageDeviceDefault,
                emoji: '📱',
                selected: provider.isSelected(null),
                onTap: () {
                  provider.useDeviceLocale();
                  Navigator.of(context).pop();
                },
              ),
              _LanguageTile(
                label: l10n.languageEnglish,
                emoji: '🇬🇧',
                selected: provider.isSelected(const Locale('en')),
                onTap: () {
                  provider.setLocale(const Locale('en'));
                  Navigator.of(context).pop();
                },
              ),
              _LanguageTile(
                label: l10n.languageTurkish,
                emoji: '🇹🇷',
                selected: provider.isSelected(const Locale('tr')),
                onTap: () {
                  provider.setLocale(const Locale('tr'));
                  Navigator.of(context).pop();
                },
              ),
              _LanguageTile(
                label: l10n.languageSpanish,
                emoji: '🇪🇸',
                selected: provider.isSelected(const Locale('es')),
                onTap: () {
                  provider.setLocale(const Locale('es'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? const Color(0xFF5C28A0).withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Baloo2 ExtraBold',
                      fontSize: 16,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: const Color(0xFF5C28A0),
                    ),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF5C28A0), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Exposes [LocaleProvider] to the widget tree without an extra package.
class LocaleProviderScope extends InheritedNotifier<LocaleProvider> {
  const LocaleProviderScope({
    super.key,
    required LocaleProvider super.notifier,
    required super.child,
  });

  static LocaleProvider of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<LocaleProviderScope>();
    assert(scope != null, 'LocaleProviderScope not found in widget tree');
    return scope!.notifier!;
  }
}
