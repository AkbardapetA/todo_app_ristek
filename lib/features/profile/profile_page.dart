import 'package:flutter/material.dart';

import '../../models/profile_data.dart';
import 'widgets/info_row.dart';
import 'widgets/mini_metric.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.profile,
    required this.totalDone,
    required this.totalPending,
    required this.accent,
    required this.onDeleteCompletedTasks,
    required this.onChanged,
  });

  final ProfileData profile;
  final int totalDone;
  final int totalPending;
  final Color accent;
  final int Function() onDeleteCompletedTasks;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    String dateFmt(DateTime d) => '${d.month}/${d.day}/${d.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(profile.avatarUrl),
              ),
              Container(
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: const <BoxShadow>[
                    BoxShadow(blurRadius: 16, color: Color(0x33000000)),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('(feature not implemented).'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            profile.fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            profile.major,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: MiniMetric(value: '$totalDone', label: 'TASKS DONE'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MiniMetric(value: '$totalPending', label: 'PENDING'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: totalDone == 0
                  ? null
                  : () async {
                      final bool? confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Finished Tasks'),
                          content: const Text(
                            'This will remove all completed tasks from every folder.',
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true || !context.mounted) return;
                      final int removed = onDeleteCompletedTasks();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            removed > 0
                                ? '$removed finished task(s) deleted.'
                                : 'No finished tasks to delete.',
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.delete_sweep_rounded),
              label: const Text('Delete All Finished Tasks'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          'Personal Info',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final bool saved = await _editPersonalInfo(
                            context,
                            profile,
                          );
                          if (saved) onChanged();
                        },
                        icon: Icon(Icons.edit_rounded, size: 16, color: accent),
                        label: Text(
                          'Edit',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InfoRow(
                    icon: Icons.person_rounded,
                    label: 'FULL NAME',
                    value: profile.fullName,
                  ),
                  InfoRow(
                    icon: Icons.school_rounded,
                    label: 'MAJOR',
                    value: profile.major,
                  ),
                  InfoRow(
                    icon: Icons.cake_rounded,
                    label: 'DATE OF BIRTH',
                    value: dateFmt(profile.dob),
                  ),
                  InfoRow(
                    icon: Icons.email_rounded,
                    label: 'EMAIL',
                    value: profile.email,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool> _editPersonalInfo(
    BuildContext context,
    ProfileData profile,
  ) async {
    final TextEditingController name = TextEditingController(
      text: profile.fullName,
    );
    final TextEditingController major = TextEditingController(
      text: profile.major,
    );
    final TextEditingController email = TextEditingController(
      text: profile.email,
    );
    DateTime dob = profile.dob;

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder:
            (
              BuildContext context,
              void Function(void Function()) setLocalState,
            ) {
              return AlertDialog(
                title: const Text('Edit Personal Info'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: name,
                      decoration: const InputDecoration(hintText: 'Full name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: major,
                      decoration: const InputDecoration(hintText: 'Major'),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: dob,
                          firstDate: DateTime(1970),
                          lastDate: DateTime(DateTime.now().year + 1),
                        );
                        if (picked != null) setLocalState(() => dob = picked);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.06),
                        ),
                        child: Text('DOB: ${dob.month}/${dob.day}/${dob.year}'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: email,
                      decoration: const InputDecoration(hintText: 'Email'),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      profile.fullName = name.text.trim().isEmpty
                          ? profile.fullName
                          : name.text.trim();
                      profile.major = major.text.trim().isEmpty
                          ? profile.major
                          : major.text.trim();
                      profile.email = email.text.trim().isEmpty
                          ? profile.email
                          : email.text.trim();
                      profile.dob = dob;
                      Navigator.pop(context, true);
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
      ),
    );

    name.dispose();
    major.dispose();
    email.dispose();
    return result == true;
  }
}
