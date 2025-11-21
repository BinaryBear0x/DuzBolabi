import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/products/home_screen.dart';
import '../features/products/product_add_screen.dart';
import '../features/products/product_detail_screen.dart';
import '../features/fridge/fridge_screen.dart';
import '../features/reports/weekly_report_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/trash_screen.dart';
import '../features/gamification/screens/game_screen.dart';
import '../features/gamification/screens/shop_screen.dart';
import '../core/utils/storage_utils.dart';

// Custom page transitions helper functions
Page _fadeTransitionPage({
  required Widget child,
  required String key,
}) {
  return CustomTransitionPage(
    key: ValueKey(key),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeOut).animate(animation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}

// Hızlı fade transition - bottom navigation için optimize edilmiş
Page _fastFadeTransitionPage({
  required Widget child,
  required String key,
}) {
  return CustomTransitionPage(
    key: ValueKey(key),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeOut).animate(animation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 150), // Daha hızlı
  );
}

Page _slideTransitionPage({
  required Widget child,
  required String key,
  required AxisDirection direction,
}) {
  Offset begin;
  
  switch (direction) {
    case AxisDirection.right:
      begin = const Offset(-1.0, 0.0);
      break;
    case AxisDirection.left:
      begin = const Offset(1.0, 0.0);
      break;
    case AxisDirection.up:
      begin = const Offset(0.0, 1.0);
      break;
    case AxisDirection.down:
      begin = const Offset(0.0, -1.0);
      break;
  }

  return CustomTransitionPage(
    key: ValueKey(key),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) {
      final isOnboardingCompleted = ref.read(onboardingCompletedProvider);
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isAuth = state.matchedLocation == '/auth';

      if (!isOnboardingCompleted && !isOnboarding) {
        return '/onboarding';
      }

      if (isOnboardingCompleted && !isAuthenticated && !isAuth && !isOnboarding) {
        return '/auth';
      }

      if (isAuthenticated && (isOnboarding || isAuth)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.uri.toString(),
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) => _fadeTransitionPage(
          key: state.uri.toString(),
          child: const AuthScreen(),
        ),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _fastFadeTransitionPage(
          key: state.uri.toString(),
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/products/add',
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.uri.toString(),
          direction: AxisDirection.up,
          child: const ProductAddScreen(),
        ),
      ),
      GoRoute(
        path: '/products/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _slideTransitionPage(
            key: state.uri.toString(),
            direction: AxisDirection.left,
            child: ProductDetailScreen(productId: id),
          );
        },
      ),
      GoRoute(
        path: '/fridge',
        pageBuilder: (context, state) => _fastFadeTransitionPage(
          key: state.uri.toString(),
          child: const FridgeScreen(),
        ),
      ),
      GoRoute(
        path: '/reports/weekly',
        pageBuilder: (context, state) => _fastFadeTransitionPage(
          key: state.uri.toString(),
          child: const WeeklyReportScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _fastFadeTransitionPage(
          key: state.uri.toString(),
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/trash',
        pageBuilder: (context, state) => _slideTransitionPage(
          key: state.uri.toString(),
          direction: AxisDirection.left,
          child: const TrashScreen(),
        ),
      ),
      // Oyunlaştırma rotaları
      GoRoute(
        path: '/game',
        pageBuilder: (context, state) => _fastFadeTransitionPage(
          key: state.uri.toString(),
          child: const GameScreen(),
        ),
        routes: [
          GoRoute(
            path: 'shop',
            pageBuilder: (context, state) => _slideTransitionPage(
              key: state.uri.toString(),
              direction: AxisDirection.left,
              child: const ShopScreen(),
            ),
          ),
        ],
      ),
    ],
  );

  ref.listen<bool>(onboardingCompletedProvider, (previous, next) {
    router.refresh();
  });
  ref.listen<bool>(isAuthenticatedProvider, (previous, next) {
    router.refresh();
  });

  return router;
});

