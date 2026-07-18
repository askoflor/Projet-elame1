import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'modules/auth/presentation/pages/register_screen.dart';
import 'modules/auth/domain/auth_provider.dart';
import 'core/localization/translation_provider.dart';
import 'core/theme/app_theme.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/register',
    routes: [
    GoRoute(path: '/', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(
      path: '/login',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: Text(context.tr('nav.connexion'))),
        body: const Center(child: Text('Page de connexion (placeholder)')),
      ),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: Text(context.tr('dashboard.title'))),
        body: Center(child: Text(context.tr('placeholder.title'))),
      ),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final translationProvider = TranslationProvider();
  await translationProvider.loadTranslations(const Locale('fr'));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: translationProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Register Preview',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
