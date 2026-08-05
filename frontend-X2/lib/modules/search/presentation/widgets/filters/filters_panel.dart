import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/localization/translation_provider.dart';
import '../../../../../core/constants/referentials.dart';
import '../../../../../core/constants/category_taxonomy.dart';

class FiltersPanel extends StatefulWidget {
  final String? initialCategory;
  final ValueChanged<String>? onCategoryChanged;
  final String? initialQuartier;
  final ValueChanged<String?>? onQuartierChanged;
  final bool? initialAvailability;
  final ValueChanged<bool?>? onAvailabilityChanged;

  const FiltersPanel({
    super.key,
    this.initialCategory,
    this.onCategoryChanged,
    this.initialQuartier,
    this.onQuartierChanged,
    this.initialAvailability,
    this.onAvailabilityChanged,
  });

  @override
  State<FiltersPanel> createState() => _FiltersPanelState();
}

class _FiltersPanelState extends State<FiltersPanel> {
  late String selectedCategory;
  late String selectedAvailabilityKey;
  String? selectedQuartier;
  String selectedUrgency = 'Semi-urgent';

  static List<String> get categories =>
      ['Tous', ...CategoryTaxonomy.toutesSousCategories.map((s) => s.label)];

  final List<String> availabilityKeys = ['tous', 'maintenant'];
  final List<String> urgencies = ['Planifié', 'Semi-urgent', 'Urgent'];

  String _categoryLabel(String v) => v == 'Tous' ? context.tr('search.categoryAll') : v;

  String _availabilityLabel(String v) {
    switch (v) {
      case 'maintenant':
        return context.tr('search.availabilityNow');
      case 'tous':
      default:
        return context.tr('search.availabilityAll');
    }
  }

  String _urgencyLabel(String v) {
    switch (v) {
      case 'Planifié':
        return context.tr('booking.urgencePlanifie');
      case 'Semi-urgent':
        return context.tr('search.urgencySemiUrgent');
      case 'Urgent':
        return context.tr('booking.urgenceUrgent');
      default:
        return v;
    }
  }

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory != null &&
            categories.contains(widget.initialCategory)
        ? widget.initialCategory!
        : 'Tous';
    selectedQuartier = widget.initialQuartier;
    selectedAvailabilityKey = widget.initialAvailability == true ? 'maintenant' : 'tous';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            label: context.tr('search.categoryLabel'),
            showBorder: true,
            child: _buildTagsFilter(
              items: categories,
              selected: selectedCategory,
              labelBuilder: _categoryLabel,
              onSelect: (val) {
                setState(() => selectedCategory = val);
                widget.onCategoryChanged?.call(val);
              },
            ),
          ),
          // Disponibilité
          _buildFilterGroup(
            label: context.tr('search.availabilityLabel'),
            showBorder: true,
            child: _buildTagsFilter(
              items: availabilityKeys,
              selected: selectedAvailabilityKey,
              labelBuilder: _availabilityLabel,
              onSelect: (val) {
                setState(() => selectedAvailabilityKey = val);
                widget.onAvailabilityChanged?.call(val == 'maintenant' ? true : null);
              },
            ),
          ),
          // Localisation
          _buildFilterGroup(
            label: context.tr('search.locationLabel'),
            showBorder: false,
            child: _buildQuartierDropdown(),
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
              selectedCategory = 'Tous';
              selectedAvailabilityKey = 'tous';
              selectedQuartier = null;
              selectedUrgency = 'Semi-urgent';
              widget.onCategoryChanged?.call(selectedCategory);
              widget.onQuartierChanged?.call(null);
              widget.onAvailabilityChanged?.call(null);
            }),
            child: Text(
              context.tr('search.resetButton'),
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
    String Function(String)? labelBuilder,
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
              labelBuilder != null ? labelBuilder(item) : item,
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

  Widget _buildQuartierDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedQuartier,
          isExpanded: true,
          hint: Text(context.tr('search.locationAll'), style: GoogleFonts.sora(fontSize: 13, color: const Color(0xFF64748B))),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF64748B), size: 18),
          style: GoogleFonts.sora(
            fontSize: 13,
            color: const Color(0xFF1E293B),
          ),
          items: [
            DropdownMenuItem<String?>(value: null, child: Text(context.tr('search.locationAll'))),
            ...Referentials.quartiers.map((q) => DropdownMenuItem<String?>(value: q, child: Text(q))),
          ],
          onChanged: (val) {
            setState(() => selectedQuartier = val);
            widget.onQuartierChanged?.call(val);
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
              _urgencyLabel(item),
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
