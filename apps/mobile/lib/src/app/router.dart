import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/session_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/onboarding/presentation/intro_screen.dart';
import '../features/onboarding/presentation/goal_screen.dart';
import '../core/storage/prefs.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionControllerProvider);
  final prefs = ref.watch(sharedPrefsProvider);
  final sessionValue = session.valueOrNull;
  final initial = sessionValue != null ? '/home' : '/auth/login';

  return GoRouter(
    initialLocation: initial,
    routes: [
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
        path: '/onboarding/intro',
        builder: (context, state) => const IntroSplashScreen(),
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
      final introSeen = prefs.getBool('onboarding_intro_seen') ?? false;

      final loc = state.matchedLocation;
      final isAuth = loc.startsWith('/auth');
      final isOnboarding = loc.startsWith('/onboarding');
      final isIntro = loc == '/onboarding/intro';

      // Avoid navigation churn while updating session (e.g. patching profile).
      if (isLoading) return null;
      if (!isLoggedIn) return isAuth ? null : '/auth/login';
      if (isLoggedIn && !introSeen) return isIntro ? null : '/onboarding/intro';
      if (isLoggedIn && !profileReady) return isOnboarding ? null : '/onboarding/goal';
      if (isLoggedIn && profileReady && isAuth) return '/home';
      return null;
    },
    errorBuilder: (context, state) => Scaffold(body: Center(child: Text(state.error.toString()))),
  );
});
