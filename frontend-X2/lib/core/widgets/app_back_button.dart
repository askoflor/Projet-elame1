import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'micro_interactions.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color iconColor;
  final Color bgColor;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.iconColor = const Color(0xFF1E293B),
    this.bgColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return PointerCursor(
      child: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: iconColor,
            size: 20,
          ),
        ),
        onPressed: onPressed ??
            () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
      ),
    );
  }
}
