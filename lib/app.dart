import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/localization/translation_provider.dart';
import 'core/theme/app_theme.dart';
import 'modules/auth/domain/auth_provider.dart';
import 'routes/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return MaterialApp.router(
      title: context.tr('app.title'),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router(authProvider),
    );
  }
}
