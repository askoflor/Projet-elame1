import 'package:flutter/material.dart';
import '../widgets/header/nav_bar.dart';
import '../widgets/hero/hero_section.dart';
import '../widgets/categories/categories_section.dart';
import '../widgets/how_it_works/how_it_works_section.dart';
import '../widgets/providers/provider_section.dart';
import '../widgets/testimonials/testimonials_section.dart';
import '../widgets/footer/app_footer.dart';
import '../widgets/partners/partners_section.dart';
import '../../../../core/widgets/app_back_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const NavBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: AppBackButton(),
                    ),
                    const SizedBox(height: 16),
                    const HeroSection(),
                    const CategoriesSection(),
                    const HowItWorksSection(),
                    const PartnersSection(),
                    const ProviderSection(),
                    const TestimonialsSection(),
                    const AppFooter(),
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
