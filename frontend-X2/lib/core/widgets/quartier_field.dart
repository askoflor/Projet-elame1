import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/referentials.dart';

/// Champ avec autocomplétion pour choisir un quartier parmi
/// [Referentials.quartiers] (23 entrées, pas filtrées par ville). `null`
/// représente "tous les quartiers".
///
/// Pensé pour être réutilisé à la fois dans un conteneur encadré (panneau de
/// filtres) et dans une ligne segmentée icône + valeur (popup de recherche).
class QuartierField extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final IconData? icon;
  final String hintText;

  const QuartierField({
    super.key,
    required this.value,
    required this.onChanged,
    this.icon,
    this.hintText = 'Tous les quartiers',
  });

  @override
  State<QuartierField> createState() => _QuartierFieldState();
}

class _QuartierFieldState extends State<QuartierField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(QuartierField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Resynchronise si la valeur change depuis l'exterieur (ex. bouton
    // "Reinitialiser" du panneau de filtres) sans que l'utilisateur ait tape.
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: _controller,
      focusNode: _focusNode,
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) return Referentials.quartiers;
        return Referentials.quartiers
            .where((q) => q.toLowerCase().contains(query));
      },
      onSelected: widget.onChanged,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return Row(
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 16, color: const Color(0xFF64748B)),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: GoogleFonts.sora(
                    fontSize: 13, color: const Color(0xFF1E293B)),
                decoration: InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: GoogleFonts.sora(
                      fontSize: 13, color: const Color(0xFF94A3B8)),
                ),
                onChanged: (text) {
                  if (text.isEmpty) widget.onChanged(null);
                },
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) {
                  return const Icon(Icons.keyboard_arrow_down,
                      size: 16, color: Color(0xFF64748B));
                }
                return IconButton(
                  onPressed: () {
                    controller.clear();
                    widget.onChanged(null);
                  },
                  icon: const Icon(Icons.close,
                      size: 16, color: Color(0xFF94A3B8)),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                );
              },
            ),
          ],
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, minWidth: 220),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Text(option,
                          style: GoogleFonts.sora(
                              fontSize: 13, color: const Color(0xFF1E293B))),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
