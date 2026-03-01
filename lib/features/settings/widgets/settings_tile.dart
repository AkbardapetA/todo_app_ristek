import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: cs.onSurface.withValues(alpha: 0.1),
        child: Icon(
          icon,
          size: 18,
          color: cs.onSurface.withValues(alpha: 0.85),
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      trailing: trailing == null
          ? Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurface.withValues(alpha: 0.5),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  trailing!,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title (feature not implemented).')),
        );
      },
    );
  }
}
