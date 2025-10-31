// lib/core/scaffold_with_nav.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ScaffoldWithNav extends StatefulWidget {
  const ScaffoldWithNav({
    required this.child,
    super.key,
  });
  final Widget child;
  @override
  State<ScaffoldWithNav> createState() => _ScaffoldWithNavState();
}

class _ScaffoldWithNavState extends State<ScaffoldWithNav> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location == '/') {
      return 0; // 'Timer'
    }
    if (location == '/stats') {
      return 1; // 'Stats'
    }
    return 0; // 기본값
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/stats');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive Pomodoro'),
        elevation: 0,
      ),
      body: widget.child, 
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.timer),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.chartBar),
            label: 'Stats',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}