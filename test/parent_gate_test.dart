import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippolulu/parent_gate.dart';
import 'package:hippolulu/l10n/app_localizations.dart';

void main() {
  for (final size in [const Size(320,568),const Size(402,874),const Size(768,1024)]) {
    testWidgets('Gate rejects, verifies and removes blur $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(()=>tester.binding.setSurfaceSize(null));
      bool? result;
      await tester.pumpWidget(MaterialApp(locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context)=>Scaffold(body: TextButton(onPressed: () async {result=await showParentGate(context);},child: const Text('open'))))));
      await tester.tap(find.text('open'));await tester.pumpAndSettle();
      final question=tester.widget<Text>(find.byKey(const ValueKey('parent-gate-question'))).data!;
      final parts=RegExp(r'\d+').allMatches(question).map((m)=>int.parse(m[0]!)).toList();
      final sum=parts[0]+parts[1];
      final wrong=tester.widgetList<OutlinedButton>(find.byType(OutlinedButton)).map((b)=>(b.child as Text).data!).firstWhere((s)=>s!=''+sum.toString());
      await tester.tap(find.text(wrong));await tester.pumpAndSettle();
      expect(find.text('Tekrar deneyin.'),findsOneWidget);expect(result,isNull);
      await tester.tap(find.text('$sum'));await tester.pumpAndSettle();
      expect(find.text('Harika!'),findsOneWidget);expect(result,isNull);
      await tester.tap(find.byKey(const ValueKey('parent-gate-continue')));await tester.pumpAndSettle();
      expect(result,isTrue);expect(find.byType(BackdropFilter),findsNothing);
      await tester.tap(find.text('open'));await tester.pumpAndSettle();
      await tester.tap(find.text('Vazgeç'));await tester.pumpAndSettle();
      expect(result,isFalse);expect(find.byType(BackdropFilter),findsNothing);
      expect(tester.takeException(),isNull);
    });
  }
}
