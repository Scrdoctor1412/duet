import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:duet/duet.dart';
import 'package:duet_example/screens/auth_screen/auth_screen.dart';
import 'package:duet_example/screens/auth_screen/auth_viewmodel.dart';
import 'package:duet_example/screens/cart_screen/cart_screen.dart';
import 'package:duet_example/screens/my_test_screen/my_test_screen.dart';
import 'package:duet_example/screens/product_screen/product_screen.dart';
import 'package:duet_example/screens/profile_screen/profile_screen.dart';
import 'package:duet_example/screens/splash_screen/splash_screen.dart';
import 'package:duet_example/screens/stress_test_screen/stress_test_screen.dart';

abstract class AppRouter {
  static final AuthViewModel _authVM = getVM(() => AuthViewModel());

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _authVM.dataNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final authData = _authVM.dataState;
      final bool isSplash = state.matchedLocation == '/splash';
      final bool isLoggingIn = state.matchedLocation == '/login';

      // 1. N   u   ang kh   i t   o/     c session t   ?secure storage
      if (authData.isInitializing) {
        return isSplash ? null : '/splash';
      }

      final bool isAuthenticated = authData.isAuthenticated;

      // 2. N   u v   a k   t th  c kh   i t   o t   ?splash -> chuy   n h     ng      n trang th  ch h   p
      if (isSplash) {
        return isAuthenticated ? '/' : '/login';
      }

      // 3. N   u ch  a     ng nh   p v     ang truy c   p trang y  u c   u     ng nh   p
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // 4. N   u          ng nh   p v     ang    ?trang login
      if (isAuthenticated && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'products',
        builder: (context, state) => const ProductScreen(),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/stress-test',
        name: 'stress-test',
        builder: (context, state) => const StressTestScreen(),
      ),
      GoRoute(
        path: MyTestScreen.route,
        name: MyTestScreen.route,
        builder: (context, state) => const MyTestScreen(),
      ),
    ],
  );
}
