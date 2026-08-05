import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/category_taxonomy.dart';
import '../localization/translation_provider.dart';

/// Popup listant les sous-categories d'UNE categorie principale. Retourne
/// (via Navigator.pop) le libelle de la sous-categorie choisie, ou null si
/// l'utilisateur ferme la popup sans selectionner.
class SubcategoryPickerDialog extends StatelessWidget {
  final MainCategory categorie;

  const SubcategoryPickerDialog({super.key, required this.categorie});

  static Future<String?> show(BuildContext context, MainCategory categorie) {
    return showDialog<String>(
      context: context,
      builder: (_) => SubcategoryPickerDialog(categorie: categorie),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 24,
                    decoration: BoxDecoration(color: categorie.accent, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      categorie.label,
                      style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, size: 20)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('categories.choisirMetier'),
                style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: categorie.sousCategories.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final sub = categorie.sousCategories[index];
                    return _SousCategorieTile(
                      sub: sub,
                      accent: categorie.accent,
                      onTap: () => Navigator.of(context).pop(sub.label),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Popup de filtre de recherche : categorie -> sous-categorie (dependante) ->
/// disponibilite (date choisie via un calendrier), puis bouton "Rechercher"
/// qui renvoie (via Navigator.pop) le couple (specialite choisie, date) pour
/// naviguer directement vers la page de recherche. Remplace l'ancien lien
/// "Voir tout".
class AllCategoriesSearchDialog extends StatefulWidget {
  const AllCategoriesSearchDialog({super.key});

  static Future<(String, DateTime?)?> show(BuildContext context) {
    return showDialog<(String, DateTime?)>(
      context: context,
      builder: (_) => const AllCategoriesSearchDialog(),
    );
  }

  @override
  State<AllCategoriesSearchDialog> createState() => _AllCategoriesSearchDialogState();
}

class _AllCategoriesSearchDialogState extends State<AllCategoriesSearchDialog> {
  MainCategory? _categorie;
  SubCategory? _sousCategorie;
  DateTime? _dateDisponibilite;
  bool _searchHovered = false;

  void _selectCategorie(MainCategory? c) {
    setState(() {
      _categorie = c;
      _sousCategorie = null;
    });
  }

  Future<void> _choisirDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateDisponibilite ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dateDisponibilite = picked);
  }

  @override
  Widget build(BuildContext context) {
    final peutRechercher = _categorie != null && _sousCategorie != null;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.tr('categories.rechercherTitre'),
                      style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, size: 20)),
                ],
              ),
              const SizedBox(height: 14),
              // Barre segmentee inspiree de l'ancienne recherche du hero :
              // fond blanc, champs empiles separes par un filet, icone + libelle.
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: _buildCategorieField(),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: _buildSousCategorieField(),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: _buildDisponibiliteField(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _searchHovered = true),
                  onExit: (_) => setState(() => _searchHovered = false),
                  child: ElevatedButton.icon(
                    onPressed: peutRechercher
                        ? () => Navigator.of(context).pop((_sousCategorie!.label, _dateDisponibilite))
                        : null,
                    icon: const Icon(Icons.search_rounded, size: 18),
                    label: Text(
                      context.tr('search.heroButton'),
                      style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: peutRechercher
                          ? (_searchHovered ? const Color(0xFFEA6C0A) : const Color(0xFFF97316))
                          : const Color(0xFFE2E8F0),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      disabledForegroundColor: const Color(0xFF94A3B8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorieField() {
    return Row(
      children: [
        const Icon(Icons.search, size: 16, color: Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MainCategory>(
              value: _categorie,
              isExpanded: true,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF64748B)),
              hint: Text(
                context.tr('search.heroPlaceholder'),
                style: GoogleFonts.sora(fontSize: 13, color: const Color(0xFF94A3B8)),
              ),
              style: GoogleFonts.sora(fontSize: 13, color: const Color(0xFF1E293B)),
              items: CategoryTaxonomy.categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.label, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: _selectCategorie,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSousCategorieField() {
    final active = _categorie != null;
    return Opacity(
      opacity: active ? 1 : 0.5,
      child: IgnorePointer(
        ignoring: !active,
        child: Row(
          children: [
            const Icon(Icons.build_outlined, size: 16, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<SubCategory>(
                  value: _sousCategorie,
                  isExpanded: true,
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF64748B)),
                  hint: Text(
                    active ? context.tr('categories.rechercherMetier') : context.tr('categories.etapeMetierPlaceholder'),
                    style: GoogleFonts.sora(fontSize: 13, color: const Color(0xFF94A3B8)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: GoogleFonts.sora(fontSize: 13, color: const Color(0xFF1E293B)),
                  items: (_categorie?.sousCategories ?? const <SubCategory>[])
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.label, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _sousCategorie = val),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisponibiliteField() {
    final date = _dateDisponibilite;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _choisirDate,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 40,
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  date == null
                      ? context.tr('categories.disponibiliteTous')
                      : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    color: date == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                  ),
                ),
              ),
              if (date != null)
                IconButton(
                  onPressed: () => setState(() => _dateDisponibilite = null),
                  icon: const Icon(Icons.close, size: 16, color: Color(0xFF94A3B8)),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else
                const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF64748B)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SousCategorieTile extends StatelessWidget {
  final SubCategory sub;
  final Color accent;
  final VoidCallback onTap;

  const _SousCategorieTile({required this.sub, required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(sub.label, style: GoogleFonts.dmSans(fontSize: 13.5, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: accent),
          ],
        ),
      ),
    );
  }
}
