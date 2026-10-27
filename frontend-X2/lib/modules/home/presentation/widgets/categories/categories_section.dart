import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/localization/translation_provider.dart';
import '../../../../../core/constants/category_taxonomy.dart';
import '../../../../../core/widgets/category_picker_dialogs.dart';
import '../../../../search/domain/entities/search_entry_args.dart';
import 'category_card.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  Future<void> _openCategorie(MainCategory categorie) async {
    final sousCategorie = await SubcategoryPickerDialog.show(context, categorie);
    if (sousCategorie == null || !mounted) return;
    context.push('/recherche', extra: sousCategorie);
  }

  Future<void> _openRechercheGlobale() async {
    final resultat = await AllCategoriesSearchDialog.show(context);
    if (resultat == null || !mounted) return;
    final (specialite, date) = resultat;
    context.push('/recherche', extra: SearchEntryArgs(specialite: specialite, date: date));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 36 : 56,
            horizontal: isMobile ? 16 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(isMobile),
              SizedBox(height: isMobile ? 20 : 32),
              _buildCategoryGrid(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(bool isMobile) {
    final title = Text(
      context.tr('categories.sectionTitle'),
      style: GoogleFonts.sora(
        fontSize: isMobile ? 19 : 26,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E293B),
        letterSpacing: -0.5,
        height: 1.25,
      ),
    );
    final subtitle = Text(
      context.tr('categories.sectionSubtitle'),
      style: GoogleFonts.dmSans(
        fontSize: isMobile ? 13 : 14,
        color: const Color(0xFF64748B),
      ),
    );
    final button = _HoverButton(
      onTap: _openRechercheGlobale,
      builder: (isHovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isHovered
                ? const Color(0xFF2563EB)
                : const Color(0xFFE8ECF2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_rounded, size: 14, color: Color(0xFF2563EB)),
            const SizedBox(width: 6),
            Text(
              context.tr('categories.voirTout'),
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isHovered
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );

    if (isMobile) {
      // Empile le titre/sous-titre et le bouton au lieu de les mettre côte à
      // côte : sur un écran étroit, le Row faisait flotter le bouton au
      // niveau du sous-titre une fois le titre passé sur plusieurs lignes.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 6),
          subtitle,
          const SizedBox(height: 14),
          button,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 6), subtitle],
          ),
        ),
        const SizedBox(width: 12),
        button,
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 3;
        }
        final childAspectRatio = crossAxisCount == 2
            ? 1.15
            : (crossAxisCount == 3 ? 1.35 : 1.7);

        final categories = CategoryTaxonomy.categories;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final categorie = categories[index];
            return CategoryCard(
              name: categorie.label,
              subtitle: '${categorie.sousCategories.length} ${context.tr('categories.metiers')}',
              emoji: categorie.emoji,
              pastelBg: categorie.pastelBg,
              accent: categorie.accent,
              onTap: () => _openCategorie(categorie),
            );
          },
        );
      },
    );
  }
}

class _HoverButton extends StatefulWidget {
  final Widget Function(bool isHovered) builder;
  final VoidCallback onTap;

  const _HoverButton({required this.builder, required this.onTap});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: widget.builder(isHovered),
      ),
    );
  }
}
