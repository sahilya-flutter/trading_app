import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/theme/app_colors.dart';
import '../features/auth/domain/user_profile.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/holdings/presentation/holdings_screen.dart';
import '../features/market/presentation/market_screen.dart';
import '../features/order/domain/order_model.dart';
import '../features/order/presentation/order_confirmation_screen.dart';
import '../features/order/presentation/order_ticket_screen.dart';
import '../features/watchlist/presentation/watchlist_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

class AuthRouterListenable extends ChangeNotifier {
  AuthRouterListenable(Ref ref) {
    ref.listen<UserProfile?>(authStateProvider, (prev, next) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = AuthRouterListenable(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/market',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final user = ref.read(authStateProvider);
      final isLoggingIn = state.uri.path == '/login';

      if (user == null && !isLoggingIn) {
        return '/login';
      }

      if (user != null && isLoggingIn) {
        return '/market';
      }

      return null;
    },
    routes: [
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithBottomNav(child: child);
        },
        routes: [
          GoRoute(
            path: '/market',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MarketScreen(),
            ),
          ),
          GoRoute(
            path: '/watchlist',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WatchlistScreen(),
            ),
          ),
          GoRoute(
            path: '/holdings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HoldingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/order',
        builder: (context, state) {
          final symbol = state.uri.queryParameters['symbol'] ?? 'RELIANCE';
          return OrderTicketScreen(symbol: symbol);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/order/confirmation',
        builder: (context, state) {
          final order = state.extra as OrderModel?;
          if (order == null) {
            return const MarketScreen();
          }
          return OrderConfirmationScreen(order: order);
        },
      ),
    ],
  );
});

class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNav({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/watchlist')) return 1;
    if (location.startsWith('/holdings')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/market');
        break;
      case 1:
        context.go('/watchlist');
        break;
      case 2:
        context.go('/holdings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              activeIcon: Icon(Icons.show_chart, color: AppColors.primaryLight),
              label: 'Market',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              activeIcon: Icon(Icons.bookmark, color: AppColors.primaryLight),
              label: 'Watchlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline),
              activeIcon: Icon(Icons.pie_chart, color: AppColors.primaryLight),
              label: 'Holdings',
            ),
          ],
        ),
      ),
    );
  }
}
