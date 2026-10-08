import 'package:flutter/material.dart';
import 'catalog_service.dart';

/// The source is fitted in full, never cropped or stretched. Board and pieces
/// use the same inner canvas so every source edge belongs to a puzzle piece.
class PuzzleSourceImage extends StatelessWidget {
  final String path;
  const PuzzleSourceImage({super.key, required this.path});
  @override
  Widget build(BuildContext context) => ColoredBox(
        color: const Color(0xFFFFF0D5),
        child: Image(
            image: catalogImageProvider(path),
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            frameBuilder: catalogImageFrame,
            errorBuilder: (_, __, ___) =>
                const Center(child: Icon(Icons.image_outlined))),
      );
}
