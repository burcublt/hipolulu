import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Fits every card inside the available board, including the final row.
class MatchingCardGrid extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool isTablet;

  const MatchingCardGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, constraints) {
      // Leave room for the cards' raised bases and shadows.
      final width = math.min(constraints.maxWidth, 950.0);
      final height = math.max(0.0, constraints.maxHeight - 12);
      final spacing = isTablet ? 12.0 : 8.0;
      var columns = 1;
      var cardSize = 0.0;
      for (var candidate = 1; candidate <= itemCount; candidate++) {
        final rows = (itemCount / candidate).ceil();
        final size = math.min(
          (width - (candidate - 1) * spacing) / candidate,
          (height - (rows - 1) * spacing) / rows,
        );
        if (size > cardSize) {
          columns = candidate;
          cardSize = size;
        }
      }
      if (cardSize <= 0) return const SizedBox.shrink();
      final rows = (itemCount / columns).ceil();
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            width: columns * cardSize + (columns - 1) * spacing,
            height: rows * cardSize + (rows - 1) * spacing,
            child: GridView.builder(
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: itemCount,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                mainAxisExtent: cardSize,
              ),
              itemBuilder: itemBuilder,
            ),
          ),
        ),
      );
    });
  }
}
