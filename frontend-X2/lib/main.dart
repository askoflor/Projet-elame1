import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/localization/translation_provider.dart';
import 'modules/auth/domain/auth_provider.dart';
import 'modules/provider/state/provider_dashboard_state.dart';
import 'modules/provider/state/availability_provider.dart';
import 'modules/intervention/state/intervention_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final translationProvider = TranslationProvider();
  await translationProvider.loadTranslations(const Locale('fr'));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: translationProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProviderDashboardProvider()),
        ChangeNotifierProvider(create: (_) => AvailabilityProvider()),
        ChangeNotifierProvider(create: (_) => InterventionProvider()),
      ],
      child: const App(),
    ),
  );
}
