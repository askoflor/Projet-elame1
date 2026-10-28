import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/localization/translation_provider.dart';
import 'modules/auth/domain/auth_provider.dart';
import 'modules/provider/state/provider_dashboard_state.dart';
import 'modules/provider/state/availability_provider.dart';
import 'modules/intervention/state/intervention_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // URLs "propres" (sans #) sur le web, pour que les liens emailes
  // (reinitialisation de mot de passe, etc.) et les liens partages/mis en
  // favoris vers une sous-page fonctionnent au premier chargement.
  usePathUrlStrategy();
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
