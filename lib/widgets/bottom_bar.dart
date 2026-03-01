import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.tab, required this.onChange});

  final int tab;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: onChange,
      destinations: const <NavigationDestination>[
        NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
        NavigationDestination(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
