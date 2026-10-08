import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hippolulu/l10n/app_localizations.dart';
import 'catalog_service.dart';
import 'puzzle_arena.dart';
import 'unlock_screen.dart';

const _art = 'assets/images/puzzle/item_selection/';

class PuzzleItemSelection extends StatefulWidget {
  final String themeId;
  final String themeTitle;
  final VoidCallback onBack;
  const PuzzleItemSelection(
      {super.key,
      required this.themeId,
      required this.themeTitle,
      required this.onBack});
  @override
  State<PuzzleItemSelection> createState() => _PuzzleItemSelectionState();
}

class _PuzzleItemSelectionState extends State<PuzzleItemSelection> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true, _error = false, _opening = false;
  String? _locale;
  int _request = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (_locale != locale) {
      _locale = locale;
      _load();
    }
  }

  @override
  void didUpdateWidget(PuzzleItemSelection old) {
    super.didUpdateWidget(old);
    if (old.themeId != widget.themeId) _load();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final data = await CatalogService.instance.fetch(
          'games/puzzle/themes/${Uri.encodeComponent(widget.themeId)}/contents',
          _locale!);
      if (mounted && request == _request) {
        setState(() {
          _items = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted && request == _request) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  Future<void> _open(int index) async {
    if (_opening) return;
    final item = _items[index];
    if (item['locked'] == true) {
      showUnlockScreen(context, returnOrientations: DeviceOrientation.values);
      return;
    }
    setState(() => _opening = true);
    try {
      final path = item['image_url'] as String;
      // Load the selected original only; thumbnails are decoded lazily by the grid.
      await loadCatalogImage(path, context);
      if (!mounted) return;
      final available = _items.where((i) => i['locked'] != true).toList();
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (puzzleContext) => PuzzleArena(
                imagePath: path,
                themeImages:
                    available.map((i) => i['image_url'] as String).toList(),
                currentIndex: available.indexOf(item),
                onBack: () => Navigator.of(puzzleContext).pop(),
              )));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.puzzleImageLoadError)));
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) => PuzzleItemCollection(
        key: ValueKey(widget.themeId),
        themeTitle: widget.themeTitle,
        items: _items,
        onBack: widget.onBack,
        onSelect: _open,
        loading: _loading,
        status: _error ? CatalogStatus(error: _error, retry: _load) : null,
        opening: _opening,
      );
}

/// Presentation shared by every theme. Data and lock decisions remain with the caller.
class PuzzleItemCollection extends StatelessWidget {
  final String themeTitle;
  final List<Map<String, dynamic>> items;
  final VoidCallback onBack;
  final ValueChanged<int> onSelect;
  final Widget? status;
  final bool opening;
  final bool loading;
  const PuzzleItemCollection(
      {super.key,
      required this.themeTitle,
      required this.items,
      required this.onBack,
      required this.onSelect,
      this.status,
      this.opening = false,
      this.loading = false});
  static int columns(double width) => width >= 1000
      ? 4
      : width >= 500
          ? 3
          : 2;
  @override
  Widget build(BuildContext context) => Scaffold(
          body: Stack(children: [
        Positioned.fill(
            child: Image.asset('${_art}item_selection_background.webp',
                fit: BoxFit.cover)),
        SafeArea(
            top: false,
            child: LayoutBuilder(builder: (context, constraints) {
              final width = math.min(constraints.maxWidth, 1100.0);
              final padding = width < 360
                  ? 12.0
                  : width < 600
                      ? 16.0
                      : 24.0;
              return Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: width,
                    child: CustomScrollView(
                        key: const PageStorageKey('puzzle-collection-scroll'),
                        slivers: [
                          SliverToBoxAdapter(
                              child: _CollectionHeader(
                                  title: themeTitle,
                                  onBack: onBack,
                                  compact: constraints.maxHeight < 500)),
                          if (loading)
                            SliverPadding(
                                padding: EdgeInsets.all(padding),
                                sliver: SliverGrid(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: columns(width),
                                            childAspectRatio: 0.84,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 8),
                                    delegate: SliverChildBuilderDelegate(
                                        (_, index) => Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                child:
                                                    const CatalogPlaceholder())),
                                        childCount: 6)))
                          else if (status != null)
                            SliverFillRemaining(
                                hasScrollBody: false, child: status!)
                          else if (items.isEmpty)
                            SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                    child: Text(AppLocalizations.of(context)!
                                        .noPuzzlesFound)))
                          else
                            SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                    padding, 8, padding, 28),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns(width),
                                    childAspectRatio: 0.84,
                                    crossAxisSpacing: width < 360 ? 8 : 12,
                                    mainAxisSpacing: 8,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                    final item = items[index];
                                    return PuzzlePhotoCard(
                                        key: ValueKey<String>(
                                            (item['slug'] ?? index).toString()),
                                        imagePath: item['image_url'] as String,
                                        title: item['title'] as String,
                                        index: index,
                                        locked: item['locked'] == true,
                                        onTap: () => onSelect(index));
                                  }, childCount: items.length),
                                )),
                        ]),
                  ));
            })),
        if (opening)
          const Positioned.fill(
              child: AbsorbPointer(
                  child: ColoredBox(
                      color: Color(0x44000000),
                      child: Center(child: CircularProgressIndicator())))),
      ]));
}

class _CollectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final bool compact;
  const _CollectionHeader(
      {required this.title, required this.onBack, required this.compact});
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final width =
            math.min(constraints.maxWidth * 0.82, compact ? 330.0 : 500.0);
        final top = MediaQuery.paddingOf(context).top + 56;
        final signHeight = width * 821 / 1916;
        return SizedBox(
            height: top + signHeight,
            child: Stack(children: [
              // Extend the asset's own rope texture to the physical screen edge.
              Positioned(
                  top: 0,
                  left: (constraints.maxWidth - width) / 2,
                  width: width,
                  height: top + 1,
                  child: IgnorePointer(
                      child: ClipRect(
                          child: OverflowBox(
                    alignment: Alignment.topCenter,
                    minHeight: signHeight,
                    maxHeight: signHeight,
                    child: Transform.scale(
                      alignment: Alignment.topCenter,
                      scaleY: (top + 1) / (width * 0.04),
                      child: Image.asset('${_art}header_sign.webp',
                          width: width, height: signHeight, fit: BoxFit.fill),
                    ),
                  )))),
              Positioned(
                  top: MediaQuery.paddingOf(context).top,
                  left: 0,
                  right: 0,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: onBack,
                          style: TextButton.styleFrom(
                              backgroundColor: const Color(0xF5FFFCF6),
                              foregroundColor: const Color(0xFF6127C9),
                              minimumSize: const Size(88, 48),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              shape: const StadiumBorder()),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 19),
                          label: Text(AppLocalizations.of(context)!.back,
                              style: const TextStyle(
                                  fontFamily: 'Baloo2 ExtraBold',
                                  fontSize: 18)),
                        ),
                      ))),
              Positioned(
                  top: top,
                  left: (constraints.maxWidth - width) / 2,
                  width: width,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return SizedBox(
                        width: width,
                        height: width * 821 / 1916,
                        child: Stack(children: [
                          Positioned.fill(
                              child: Image.asset('${_art}header_sign.webp',
                                  fit: BoxFit.contain)),
                          Positioned(
                              left: width * 0.19,
                              right: width * 0.18,
                              top: width * 0.15,
                              bottom: width * 0.085,
                              child: Center(
                                  child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Stack(children: [
                                        Text(title,
                                            style: TextStyle(
                                                fontFamily: 'Baloo2 ExtraBold',
                                                fontSize: 38,
                                                height: 1.1,
                                                foreground: Paint()
                                                  ..style = PaintingStyle.stroke
                                                  ..strokeWidth = 4
                                                  ..color =
                                                      const Color(0xFF7A3D17))),
                                        Text(title,
                                            style: const TextStyle(
                                                fontFamily: 'Baloo2 ExtraBold',
                                                fontSize: 38,
                                                height: 1.1,
                                                color: Color(0xFFFFFAE9))),
                                      ])))),
                        ]));
                  })),
            ]));
      });
}

class PuzzlePhotoCard extends StatefulWidget {
  final String imagePath, title;
  final int index;
  final bool locked;
  final VoidCallback onTap;
  const PuzzlePhotoCard(
      {super.key,
      required this.imagePath,
      required this.title,
      required this.index,
      required this.onTap,
      this.locked = false});
  @override
  State<PuzzlePhotoCard> createState() => _PuzzlePhotoCardState();
}

class _PuzzlePhotoCardState extends State<PuzzlePhotoCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    const rotations = [-0.018, 0.015, -0.010, 0.020];
    return Semantics(
      button: true,
      label: widget.locked
          ? '${widget.title}, ${AppLocalizations.of(context)!.locked}'
          : widget.title,
      child: ExcludeSemantics(
          child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 190),
          curve: Curves.easeOutBack,
          child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cardHeight = width * 1278 / 1230;
            return Stack(clipBehavior: Clip.none, children: [
              Positioned(
                left: 0,
                right: 0,
                top: width * 0.10,
                height: cardHeight,
                child: Transform.rotate(
                  angle: rotations[widget.index % 4],
                  child: Container(
                    margin: EdgeInsets.all(width * 0.045),
                    padding: EdgeInsets.all(width * 0.055),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3D8),
                      borderRadius: BorderRadius.circular(width * 0.065),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x997A491D),
                            offset: Offset(0, 3),
                            blurRadius: 2)
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(width * 0.025),
                      child: Stack(fit: StackFit.expand, children: [
                        Image(
                          frameBuilder: catalogImageFrame,
                          image: ResizeImage.resizeIfNeeded(
                              (width * MediaQuery.devicePixelRatioOf(context))
                                  .ceil(),
                              null,
                              catalogImageProvider(widget.imagePath)),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                              color: Color(0xFFFFE8BE),
                              child: Icon(Icons.image_outlined)),
                        ),
                        if (widget.locked)
                          ColoredBox(
                              color: const Color(0x66000000),
                              child: Center(
                                  child: Icon(Icons.lock_rounded,
                                      color: const Color(0xFFFFCB3E),
                                      size: width * 0.28))),
                      ]),
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: width * 0.02,
                  left: width * 0.35,
                  width: width * 0.30,
                  height: width * 0.29,
                  child: IgnorePointer(
                      child: Image.asset('${_art}clip.webp',
                          fit: BoxFit.contain))),
            ]);
          }),
        ),
      )),
    );
  }
}
