import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/localization/translation_provider.dart';

class FiltersPanel extends StatefulWidget {
  const FiltersPanel({super.key});

  @override
  State<FiltersPanel> createState() => _FiltersPanelState();
}

class _FiltersPanelState extends State<FiltersPanel> {
  late String selectedCategory;
  String selectedAvailability = 'Maintenant';
  String selectedCity = 'Douala';
  String selectedUrgency = 'Semi-urgent';

  late List<String> categories;
  final List<String> availabilities = [
    'Maintenant',
    'Aujourd\'hui',
    'Cette semaine'
  ];
  final List<String> cities = [
    'Douala',
    'Yaoundé',
    'Bafoussam',
    'Garoua',
    'Bamenda',
    'Maroua',
    'Ngaoundéré',
    'Bertoua',
    'Buea',
    'Ebolowa',
  ];
  final List<String> urgencies = ['Planifié', 'Semi-urgent', 'Urgent'];

  @override
  void initState() {
    super.initState();
    selectedCategory = context.tr('search.categoryAll');
    categories = [
      context.tr('search.categoryAll'),
      'Électricité',
      context.tr('search.categoryPlomberie'),
      context.tr('search.categoryClim'),
      context.tr('search.categoryMaintenance'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre filtres
          _buildPanelTitle(),
          const SizedBox(height: 16),
          // Catégorie
          _buildFilterGroup(
            label: 'CATÉGORIE',
            showBorder: true,
            child: _buildTagsFilter(
              items: categories,
              selected: selectedCategory,
              onSelect: (val) => setState(() => selectedCategory = val),
            ),
          ),
          // Disponibilité
          _buildFilterGroup(
            label: 'DISPONIBILITÉ',
            showBorder: true,
            child: _buildTagsFilter(
              items: availabilities,
              selected: selectedAvailability,
              onSelect: (val) => setState(() => selectedAvailability = val),
            ),
          ),
          // Localisation
          _buildFilterGroup(
            label: context.tr('search.locationLabel'),
            showBorder: false,
            child: _buildCityDropdown(),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.tr('search.filtersTitle'),
          style: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => setState(() {
              selectedCategory = context.tr('search.categoryAll');
              selectedAvailability = 'Maintenant';
              selectedCity = 'Douala';
              selectedUrgency = 'Semi-urgent';
            }),
            child: Text(
              'Réinitialiser',
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterGroup({
    required String label,
    required Widget child,
    required bool showBorder,
  }) {
    return Container(
      padding: EdgeInsets.only(bottom: showBorder ? 20 : 0),
      margin: EdgeInsets.only(bottom: showBorder ? 20 : 0),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(
                bottom: BorderSide(color: Color(0xFFE8ECF2)),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.sora(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildTagsFilter({
    required List<String> items,
    required String selected,
    required Function(String) onSelect,
  }) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items.map((item) {
        final isActive = selected == item;
        return _HoverButton(
          onTap: () => onSelect(item),
          builder: (isHovered) => AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFEFF4FF)
                  : isHovered
                      ? const Color(0xFFF8FAFC)
                      : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isActive
                    ? const Color(0xFFBFCFFD)
                    : const Color(0xFFE8ECF2),
              ),
            ),
            child: Text(
              item,
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCity,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF64748B), size: 18),
          style: GoogleFonts.sora(
            fontSize: 13,
            color: const Color(0xFF1E293B),
          ),
          items: cities
              .map((city) => DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => selectedCity = val);
          },
        ),
      ),
    );
  }

  Widget _buildUrgencyFilter() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: urgencies.map((item) {
        final isActive = selectedUrgency == item;
        final isUrgent = item == 'Urgent';
        return _HoverButton(
          onTap: () => setState(() => selectedUrgency = item),
          builder: (isHovered) => AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isActive && isUrgent
                  ? Colors.white
                  : isActive
                      ? const Color(0xFFEFF4FF)
                      : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isActive && isUrgent
                    ? const Color(0xFFF97316)
                    : isActive
                        ? const Color(0xFFBFCFFD)
                        : const Color(0xFFE8ECF2),
              ),
            ),
            child: Text(
              item,
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                color: isActive && isUrgent
                    ? const Color(0xFFF97316)
                    : isActive
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF64748B),
              ),
            ),
          ),
        );
      }).toList(),
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
