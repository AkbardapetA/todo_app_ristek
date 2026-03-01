import 'package:flutter/material.dart';

import 'widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.currentAccent,
    required this.mode,
    required this.onAccentChanged,
    required this.onModeChanged,
  });

  final Color currentAccent;
  final ThemeMode mode;
  final ValueChanged<Color> onAccentChanged;
  final ValueChanged<ThemeMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final List<Color> colors = <Color>[
      const Color(0xFF7C4DFF),
      const Color(0xFF2962FF),
      const Color(0xFFD50000),
      const Color(0xFF1E88E5),
      const Color(0xFF00C853),
      const Color(0xFFFF6D00),
      const Color(0xFFE91E63),
    ];
    final bool isDark = mode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: <Widget>[
            Text(
              'APPEARANCE',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: cs.onSurface.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.palette_rounded,
                            size: 18,
                            color: cs.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Theme Color',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: colors.map((Color color) {
                        final bool selected =
                            color.toARGB32() == currentAccent.toARGB32();
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () => onAccentChanged(color),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: cs.onSurface.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.dark_mode_rounded,
                            size: 18,
                            color: cs.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Dark Mode',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Switch(
                          value: isDark,
                          onChanged: (bool value) => onModeChanged(
                            value ? ThemeMode.dark : ThemeMode.light,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'GENERAL',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: const <Widget>[
                  SettingsTile(
                    icon: Icons.notifications_rounded,
                    title: 'Notifications',
                  ),
                  Divider(height: 1),
                  SettingsTile(
                    icon: Icons.vibration_rounded,
                    title: 'Sounds & Haptics',
                  ),
                  Divider(height: 1),
                  SettingsTile(
                    icon: Icons.language_rounded,
                    title: 'Language & Region',
                    trailing: 'English (US)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SUPPORT',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: const <Widget>[
                  SettingsTile(
                    icon: Icons.help_center_rounded,
                    title: 'Help Center',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
