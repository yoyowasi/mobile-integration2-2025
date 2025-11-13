import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_integration2_2025/core/scaffold_with_nav.dart';
import 'package:mobile_integration2_2025/screens/stats_screen.dart';

import '../../screens/timer_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/', 
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNav(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const TimerScreen(),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsScreen(),
          ),
        ],
      ),
    ],
  );
});