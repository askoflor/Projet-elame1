import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Grille de sélection multiple des 24 heures d'une journée (00h à 23h),
/// utilisée à la fois par le calendrier du profil prestataire et par
/// l'étape Date & Heure du parcours de réservation. Les heures présentes
/// dans [bookedHours] sont affichées "Complet" et non cliquables.
class HourSlotGrid extends StatelessWidget {
  final List<int> selectedHours;
  final Set<int> bookedHours;
  final ValueChanged<List<int>> onChanged;

  const HourSlotGrid({
    super.key,
    required this.selectedHours,
    required this.bookedHours,
    required this.onChanged,
  });

  void _toggle(int hour) {
    final next = List<int>.from(selectedHours);
    if (next.contains(hour)) {
      next.remove(hour);
    } else {
      next.add(hour);
    }
    next.sort();
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 480 ? 4 : 8;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.4,
          ),
          itemCount: 24,
          itemBuilder: (context, hour) {
            final isBooked = bookedHours.contains(hour);
            final isSelected = selectedHours.contains(hour);
            return _Slot(
              hour: hour,
              isBooked: isBooked,
              isSelected: isSelected,
              onTap: isBooked ? null : () => _toggle(hour),
            );
          },
        );
      },
    );
  }
}

class _Slot extends StatefulWidget {
  final int hour;
  final bool isBooked;
  final bool isSelected;
  final VoidCallback? onTap;

  const _Slot({
    required this.hour,
    required this.isBooked,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_Slot> createState() => _SlotState();
}

class _SlotState extends State<_Slot> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final label = '${widget.hour.toString().padLeft(2, '0')}h';
    final Color bg;
    final Color border;
    final Color textColor;

    if (widget.isBooked) {
      bg = const Color(0xFFF5F7FA);
      border = const Color(0xFFE8ECF2);
      textColor = const Color(0xFF94A3B8);
    } else if (widget.isSelected) {
      bg = const Color(0xFFEFF4FF);
      border = const Color(0xFF2563EB);
      textColor = const Color(0xFF2563EB);
    } else if (isHovered) {
      bg = Colors.white;
      border = const Color(0xFFBFCFFD);
      textColor = const Color(0xFF1E293B);
    } else {
      bg = Colors.white;
      border = const Color(0xFFE8ECF2);
      textColor = const Color(0xFF1E293B);
    }

    return MouseRegion(
      cursor: widget.isBooked
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: border,
              width: widget.isSelected ? 1.5 : 1,
              style: widget.isBooked ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.sora(
                  fontSize: 12,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
              if (widget.isBooked)
                Text(
                  'Complet',
                  style: GoogleFonts.dmSans(fontSize: 9, color: textColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
