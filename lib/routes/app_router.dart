import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/timer/presentation/home_screen.dart';
import '../features/context/presentation/context_list_screen.dart';
import '../features/stats/presentation/stats_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (ctx, st) => const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/contexts',
          name: 'contexts',
          pageBuilder: (ctx, st) => const NoTransitionPage(child: ContextListScreen()),
        ),
        GoRoute(
          path: '/stats',
          name: 'stats',
          pageBuilder: (ctx, st) => const NoTransitionPage(child: StatsScreen()),
        ),
      ],
    ),
  ],
);

class AppScaffold extends StatefulWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _indexFromLocation(GoRouterState s) {
    switch (s.fullPath) {
      case '/':
        return 0;
      case '/contexts':
        return 1;
      case '/stats':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final currentIndex = _indexFromLocation(state);

    return Scaffold(
      body: SafeArea(child: widget.child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer), label: '홈'),
          NavigationDestination(icon: Icon(Icons.category), label: '컨텍스트'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: '통계'),
        ],
        onDestinationSelected: (i) {
          if (i == currentIndex) return;
          switch (i) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/contexts');
              break;
            case 2:
              context.go('/stats');
              break;
          }
        },
      ),
    );
  }
}
