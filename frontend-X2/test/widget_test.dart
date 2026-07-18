import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend_flutter/app.dart';
import 'package:frontend_flutter/modules/auth/domain/auth_provider.dart';
import 'package:frontend_flutter/core/localization/translation_provider.dart';

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;

    final translationProvider = TranslationProvider();
    await translationProvider.loadTranslations(const Locale('fr'));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: translationProvider),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const App(),
      ),
    );

    expect(find.byType(App), findsOneWidget);

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
