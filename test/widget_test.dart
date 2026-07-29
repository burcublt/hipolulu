import 'package:flutter_test/flutter_test.dart';
import 'package:hippolulu/locale_provider.dart';
import 'package:hippolulu/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches splash screen', (WidgetTester tester) async {
    final localeProvider = LocaleProvider();
    await localeProvider.load();
    await tester.pumpWidget(HippoLuluApp(localeProvider: localeProvider));
    await tester.pump();

    expect(find.byType(CustomSplashScreen), findsOneWidget);
  });
}
