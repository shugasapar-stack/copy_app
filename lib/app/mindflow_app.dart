import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/screens.dart';
import 'providers.dart';
import 'theme.dart';

class MindFlowApp extends ConsumerWidget {
  const MindFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MindFlow',
        theme: mindFlowTheme(),
        routerConfig: ref.watch(routerProvider),
      );
}

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/',
    refreshListenable:
        GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    redirect: (context, state) {
      if (auth.isLoading) return null;
      final user = auth.valueOrNull;
      final path = state.uri.path;
      final public = {'/', '/onboarding', '/login', '/register'};
      if (user == null && !public.contains(path)) return '/login';
      if (user != null && public.contains(path)) return '/home';
      if (user != null && !user.emailVerified && path != '/verify') {
        return '/verify';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/verify', builder: (_, __) => const VerifyEmailScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeShell()),
      GoRoute(path: '/chat', builder: (_, __) => const AiChatScreen()),
      GoRoute(path: '/moods', builder: (_, __) => const MoodTrackerScreen()),
      GoRoute(path: '/journal', builder: (_, __) => const JournalScreen()),
      GoRoute(
          path: '/journal/edit',
          builder: (_, s) => AddEditJournalScreen(entry: s.extra)),
      GoRoute(path: '/voice', builder: (_, __) => const VoiceJournalScreen()),
      GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
      GoRoute(
          path: '/videos', builder: (_, __) => const MotivationVideosScreen()),
      GoRoute(path: '/comfort', builder: (_, __) => const ComfortModeScreen()),
      GoRoute(path: '/community', builder: (_, __) => const CommunityScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
