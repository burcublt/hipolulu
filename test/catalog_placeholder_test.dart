import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippolulu/catalog_service.dart';

void main() {
  testWidgets(
      'Image placeholder disappears on decoded frame or memory cache hit',
      (tester) async {
    Widget build(int? frame, bool cached) => MaterialApp(
        home: Builder(
            builder: (context) => catalogImageFrame(
                context, const Text('ready'), frame, cached)));
    await tester.pumpWidget(build(null, false));
    expect(find.byType(CatalogPlaceholder), findsOneWidget);
    expect(find.text('ready'), findsNothing);
    await tester.pumpWidget(build(0, false));
    expect(find.text('ready'), findsOneWidget);
    expect(find.byType(CatalogPlaceholder), findsNothing);
    await tester.pumpWidget(build(null, true));
    expect(find.text('ready'), findsOneWidget);
  });
}
