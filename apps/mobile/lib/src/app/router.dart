import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/session_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/onboarding/presentation/goal_screen.dart';
import '../features/start/presentation/start_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionControllerProvider);
  final sessionValue = session.valueOrNull;
  final initial = sessionValue != null ? '/home' : '/start';

  return GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/forgot',
        builder: (context, state) => ForgotPasswordScreen(prefillEmail: state.extra as String?),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding/goal',
        builder: (context, state) => const GoalScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const HomeShell(),
      ),
    ],
    redirect: (context, state) {
      final isLoading = session.isLoading;
      final isLoggedIn = session.valueOrNull != null;
      final profileReady = session.valueOrNull?.user.dailyWaterGoal != null && (session.valueOrNull?.user.dailyWaterGoal ?? 0) > 0;

      final loc = state.matchedLocation;
      final isStart = loc == '/start';
      final isAuth = loc.startsWith('/auth');
      final isOnboarding = loc.startsWith('/onboarding');

      // Avoid navigation churn while updating session (e.g. patching profile).
      // Initial boot still starts at /start via initialLocation.
      if (isLoading) return null;
      if (!isLoggedIn) return isAuth || isStart ? null : '/start';
      if (isLoggedIn && !profileReady) return isOnboarding ? null : '/onboarding/goal';
      if (isLoggedIn && profileReady && (isAuth || isStart)) return '/home';
      return null;
    },
    errorBuilder: (context, state) => Scaffold(body: Center(child: Text(state.error.toString()))),
  );
});
