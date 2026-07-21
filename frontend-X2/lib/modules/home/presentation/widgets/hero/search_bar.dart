import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  static const List<String> _services = [
    'Électricité',
    'Plomberie',
    'Climatisation',
    'Carrelage',
    'Maintenance',
    'Jardinage',
    'Peinture',
    'Menuiserie',
  ];

  static const List<String> _cities = [
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

  String? _selectedService;
  String? _selectedCity;
  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Container(
          constraints: const BoxConstraints(maxWidth: 680),
          margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 60,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return SizedBox(
      height: 63,
      child: Row(
        children: [
          // Service
          Expanded(
            child: _buildDropdown(
              value: _selectedService,
              hint: 'Quel service recherchez-vous ?',
              icon: Icons.search,
              items: _services,
              onChanged: (val) => setState(() => _selectedService = val),
            ),
          ),

          _buildDivider(),

          // Localisation
          Expanded(
            child: _buildDropdown(
              value: _selectedCity,
              hint: 'Votre localisation',
              icon: Icons.location_on_outlined,
              items: _cities,
              onChanged: (val) => setState(() => _selectedCity = val),
            ),
          ),

          _buildDivider(),

          // Disponibilité (date picker)
          Expanded(
            child: _buildDatePicker(),
          ),

          const SizedBox(width: 8),

          // Bouton
          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: _buildDropdown(
            value: _selectedService,
            hint: 'Quel service recherchez-vous ?',
            icon: Icons.search,
            items: _services,
            onChanged: (val) => setState(() => _selectedService = val),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: _buildDropdown(
            value: _selectedCity,
            hint: 'Votre localisation',
            icon: Icons.location_on_outlined,
            items: _cities,
            onChanged: (val) => setState(() => _selectedCity = val),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: _buildDatePicker(),
        ),
        const SizedBox(height: 10),
        Center(child: _buildSearchButton()),
        const SizedBox(height: 2),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down,
                  size: 16, color: Color(0xFF64748B)),
              hint: Text(
                hint,
                style: GoogleFonts.sora(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              style: GoogleFonts.sora(
                fontSize: 13,
                color: const Color(0xFF1E293B),
              ),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _selectDate,
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedDate == null
                    ? 'Disponibilité'
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                style: GoogleFonts.sora(
                  fontSize: 13,
                  color: _selectedDate == null
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: const Color(0xFFE2E8F0),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildSearchButton() {
    return _HoverButton(
      onTap: () => context.go('/recherche', extra: _selectedService),
      builder: (isHovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.ease,
        height: 47,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: isHovered ? const Color(0xFFEA6C0A) : const Color(0xFFF97316),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Trouver un prestataire',
          style: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
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
