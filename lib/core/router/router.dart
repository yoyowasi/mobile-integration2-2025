import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../screens/stats_screen.dart';
import '../../screens/history_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/timer_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNav(navigationShell: navigationShell);
        },
        branches: [
          // 1. 타이머 화면
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TimerScreen(),
                ),
              ),
            ],
          ),
          // 2. 통계 화면
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: StatsScreen(),
                ),
              ),
            ],
          ),
          // 3. 히스토리 화면 (추가 예정)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HistoryScreen(),
                ),
              ),
            ],
          ),
          // 4. 설정 화면
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithBottomNav({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        selectedItemColor: const Color(0xFFE74D50),
        unselectedItemColor: Colors.black38,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        backgroundColor: Colors.white,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_rounded),
            activeIcon: Icon(Icons.timer, size: 28),
            label: '타이머',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            activeIcon: Icon(Icons.bar_chart, size: 28),
            label: '통계',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            activeIcon: Icon(Icons.history, size: 28),
            label: '기록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            activeIcon: Icon(Icons.settings, size: 28),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
