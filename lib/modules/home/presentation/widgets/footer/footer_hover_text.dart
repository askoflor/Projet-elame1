import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class FooterHoverText extends StatefulWidget {
  final String text;
  final String? route;

  const FooterHoverText({super.key, required this.text, this.route});

  @override
  State<FooterHoverText> createState() => _FooterHoverTextState();
}

class _FooterHoverTextState extends State<FooterHoverText> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () {
          if (widget.route != null) context.go(widget.route!);
        },
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: isHovered ? Colors.white : Colors.white.withOpacity(0.6),
          ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}
