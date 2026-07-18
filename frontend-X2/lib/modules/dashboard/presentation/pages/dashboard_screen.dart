import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../auth/domain/auth_provider.dart';
import '../../../home/presentation/widgets/header/nav_bar.dart';
import '../../../../core/widgets/app_back_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const NavBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: AppBackButton(),
                      ),
                      const SizedBox(height: 32),
                      const Icon(
                        Icons.dashboard_rounded,
                        size: 80,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.tr('dashboard.welcome'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.tr('dashboard.subtitle'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 24),
                      HoverWrap(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<AuthProvider>().logout();
                            context.go(AppConstants.loginRoute);
                          },
                          icon: const Icon(Icons.logout, size: 18),
                          label: Text(context.tr('dashboard.logout')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
