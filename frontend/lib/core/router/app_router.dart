import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/savings/screens/dashboard_screen.dart';
import '../../features/goals/screens/goals_screen.dart';
import '../../features/goals/screens/goal_detail_screen.dart';
import '../../features/ai/screens/ai_advisor_screen.dart';
import '../../features/admin/screens/admin_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = isAuthenticated;
      final onAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!loggedIn && !onAuth) return '/login';
      if (loggedIn && onAuth) return '/';
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            _AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/goals', builder: (_, __) => const GoalsScreen()),
          GoRoute(
            path: '/goals/:id',
            builder: (_, state) =>
                GoalDetailScreen(goalId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/ai', builder: (_, __) => const AiAdvisorScreen()),
          GoRoute(path: '/admin', builder: (_, __) => const AdminScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

class _AppShell extends StatelessWidget {
  final String location;
  final Widget child;

  const _AppShell({required this.location, required this.child});

  int get _index {
    if (location == '/') return 0;
    if (location.startsWith('/goals')) return 1;
    if (location == '/ai') return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          backgroundColor: SedixColors.surface,
          indicatorColor: SedixColors.accentLight,
          selectedIndex: _index,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (i) {
            switch (i) {
              case 0: context.go('/');
              case 1: context.go('/goals');
              case 2: context.go('/ai');
              case 3: context.go('/profile');
            }
          },
          destinations: const [
            NavigationDestination(
              icon: FaIcon(FontAwesomeIcons.house, size: 18),
              selectedIcon: FaIcon(FontAwesomeIcons.house, size: 18, color: SedixColors.accent),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: FaIcon(FontAwesomeIcons.bullseye, size: 18),
              selectedIcon: FaIcon(FontAwesomeIcons.bullseye, size: 18, color: SedixColors.accent),
              label: 'Metas',
            ),
            NavigationDestination(
              icon: FaIcon(FontAwesomeIcons.wandMagicSparkles, size: 18),
              selectedIcon: FaIcon(FontAwesomeIcons.wandMagicSparkles, size: 18, color: SedixColors.accent),
              label: 'IA',
            ),
            NavigationDestination(
              icon: FaIcon(FontAwesomeIcons.circleUser, size: 18),
              selectedIcon: FaIcon(FontAwesomeIcons.circleUser, size: 18, color: SedixColors.accent),
              label: 'Perfil',
            ),
          ],
        ),
      );
}
