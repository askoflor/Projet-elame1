import 'package:flutter/material.dart';
import '../../../home/presentation/widgets/header/nav_bar.dart';
import '../widgets/dashboard/dashboard_content.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

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
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashboardContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
