import 'package:flutter/material.dart';

class HoverButton extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;
  final VoidCallback? onTap;
  final Duration duration;
  final Curve curve;

  const HoverButton({
    super.key,
    required this.builder,
    this.onTap,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.ease,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: widget.curve,
          child: widget.builder(context, isHovered),
        ),
      ),
    );
  }
}
