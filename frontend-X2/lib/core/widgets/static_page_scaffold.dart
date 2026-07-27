import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../modules/home/presentation/widgets/header/nav_bar.dart';
import '../../modules/home/presentation/widgets/footer/app_footer.dart';
import 'app_back_button.dart';

/// Mise en page commune aux pages statiques (À propos, FAQ, Confidentialité...) :
/// entête, bouton retour, contenu centré et pied de page.
class StaticPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const StaticPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AppBackButton(),
                      ),
                    ),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 56),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.sora(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  subtitle!,
                                  style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF64748B)),
                                ),
                              ],
                              const SizedBox(height: 32),
                              child,
                            ],
                          ),
                        ),
                      ),
                    ),
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
