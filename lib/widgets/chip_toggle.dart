import 'package:flutter/material.dart';

class ChipToggle extends StatelessWidget {
  const ChipToggle({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? cs.primary.withValues(alpha: 0.22)
              : cs.onSurface.withValues(alpha: 0.06),
          border: Border.all(
            color: selected
                ? cs.primary.withValues(alpha: 0.7)
                : Colors.transparent,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? cs.primary : cs.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
