import 'package:flutter/material.dart';

class FloatingPlus extends StatelessWidget {
  const FloatingPlus({
    super.key,
    required this.accent,
    required this.onPressed,
  });

  final Color accent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: accent,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}
