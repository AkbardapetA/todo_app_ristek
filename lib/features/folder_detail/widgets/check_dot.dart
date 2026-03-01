import 'package:flutter/material.dart';

class CheckDot extends StatelessWidget {
  const CheckDot({super.key, required this.checked, required this.accent});

  final bool checked;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? accent : Colors.transparent,
        border: Border.all(
          width: 1.8,
          color: checked ? accent : cs.onSurface.withValues(alpha: 0.5),
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
