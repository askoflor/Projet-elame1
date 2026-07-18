import 'package:flutter/material.dart';

class PointerCursor extends StatelessWidget {
  final Widget child;
  const PointerCursor({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: child,
    );
  }
}

class HoverWrap extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;
  final Curve curve;

  const HoverWrap({
    super.key,
    required this.child,
    this.scale = 1.02,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOut,
  });

  @override
  State<HoverWrap> createState() => _HoverWrapState();
}

class _HoverWrapState extends State<HoverWrap> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? widget.scale : 1.0,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}

class ScaleOnHover extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;
  final Curve curve;

  const ScaleOnHover({
    super.key,
    required this.child,
    this.scale = 1.03,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOut,
  });

  @override
  State<ScaleOnHover> createState() => _ScaleOnHoverState();
}

class _ScaleOnHoverState extends State<ScaleOnHover> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? widget.scale : 1.0,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}

class SlideOnHover extends StatefulWidget {
  final Widget child;
  final Offset offset;
  final Duration duration;
  final Curve curve;

  const SlideOnHover({
    super.key,
    required this.child,
    this.offset = const Offset(0, -0.03),
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOut,
  });

  @override
  State<SlideOnHover> createState() => _SlideOnHoverState();
}

class _SlideOnHoverState extends State<SlideOnHover> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedSlide(
        offset: isHovered ? widget.offset : Offset.zero,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}

class GlowOnHover extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double blurRadius;
  final Duration duration;
  final Curve curve;

  const GlowOnHover({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF2563EB),
    this.blurRadius = 16,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.ease,
  });

  @override
  State<GlowOnHover> createState() => _GlowOnHoverState();
}

class _GlowOnHoverState extends State<GlowOnHover> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: widget.duration,
        curve: widget.curve,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: widget.glowColor.withOpacity(0.2),
                    blurRadius: widget.blurRadius,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}

class StaggeredFadeIn extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Offset slideOffset;

  const StaggeredFadeIn({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 80),
    this.itemDuration = const Duration(milliseconds: 400),
    this.slideOffset = const Offset(0, 20),
  });

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn> {
  late List<bool> _visible;

  @override
  void initState() {
    super.initState();
    _visible = List.filled(widget.children.length, false);
    for (var i = 0; i < widget.children.length; i++) {
      Future.delayed(widget.staggerDelay * i, () {
        if (mounted) setState(() => _visible[i] = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.children.length, (i) {
        return AnimatedSlide(
          duration: widget.itemDuration,
          curve: Curves.easeOut,
          offset: _visible[i] ? Offset.zero : widget.slideOffset,
          child: AnimatedOpacity(
            duration: widget.itemDuration,
            curve: Curves.easeOut,
            opacity: _visible[i] ? 1.0 : 0.0,
            child: widget.children[i],
          ),
        );
      }),
    );
  }
}
