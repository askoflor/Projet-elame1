import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/localization/translation_provider.dart';
import 'category_card.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Électricité',
      'count': 342,
      'icon': Icons.electrical_services,
      'iconColor': const Color(0xFFD97706),
      'bgColor': const Color(0xFFFFFBEB),
    },
    {
      'name': 'Plomberie',
      'count': 218,
      'icon': Icons.plumbing,
      'iconColor': const Color(0xFF2563EB),
      'bgColor': const Color(0xFFEFF6FF),
    },
    {
      'name': 'Climatisation',
      'count': 156,
      'icon': Icons.ac_unit,
      'iconColor': const Color(0xFF0D9488),
      'bgColor': const Color(0xFFF0FDFA),
    },
    {
      'name': 'Carrelage',
      'count': 94,
      'icon': Icons.grid_on,
      'iconColor': const Color(0xFFF97316),
      'bgColor': const Color(0xFFFFF7ED),
    },
    {
      'name': 'Maintenance',
      'count': 287,
      'icon': Icons.build,
      'iconColor': const Color(0xFF7C3AED),
      'bgColor': const Color(0xFFF5F3FF),
    },
    {
      'name': 'Jardinage',
      'count': 73,
      'icon': Icons.yard,
      'iconColor': const Color(0xFF16A34A),
      'bgColor': const Color(0xFFF0FDF4),
    },
    {
      'name': 'Peinture',
      'count': 128,
      'icon': Icons.format_paint,
      'iconColor': const Color(0xFFDB2777),
      'bgColor': const Color(0xFFFDF2F8),
    },
    {
      'name': 'Menuiserie',
      'count': 81,
      'icon': Icons.carpenter,
      'iconColor': const Color(0xFF16A34A),
      'bgColor': const Color(0xFFF0FDF4),
    },
  ];

  String _categoryLabel(BuildContext context, String v) {
    switch (v) {
      case 'Électricité':
        return context.tr('search.categoryElectricite');
      case 'Plomberie':
        return context.tr('search.categoryPlomberie');
      case 'Climatisation':
        return context.tr('search.categoryClim');
      case 'Carrelage':
        return context.tr('search.categoryCarrelage');
      case 'Maintenance':
        return context.tr('search.categoryMaintenance');
      case 'Jardinage':
        return context.tr('search.categoryJardinage');
      case 'Peinture':
        return context.tr('search.categoryPeinture');
      case 'Menuiserie':
        return context.tr('search.categoryMenuiserie');
      default:
        return v;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 32),
          _buildCategoryGrid(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('categories.sectionTitle'),
              style: GoogleFonts.sora(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('categories.sectionSubtitle'),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        _HoverButton(
          onTap: () => context.go('/recherche'),
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
            child: Text(
              context.tr('categories.voirTout'),
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isHovered
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
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
            ? 0.95
            : (crossAxisCount == 3 ? 1.3 : 224 / 135);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return CategoryCard(
              name: _categoryLabel(context, categories[index]['name'] as String),
              count: '${categories[index]['count']} ${context.tr('categories.countPrestataires')}',
              icon: categories[index]['icon'] as IconData,
              iconColor: categories[index]['iconColor'] as Color,
              bgColor: categories[index]['bgColor'] as Color,
              isSelected: selectedIndex == index,
              onTap: () {
                setState(() => selectedIndex = index);
                context.push('/recherche', extra: categories[index]['name'] as String);
              },
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
