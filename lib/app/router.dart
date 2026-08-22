import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/domain/user_profile.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/holdings/presentation/holdings_screen.dart';
import '../features/home/presentation/home_dashboard_screen.dart';
import '../features/market/presentation/market_screen.dart';
import '../features/order/domain/order_model.dart';
import '../features/order/presentation/order_confirmation_screen.dart';
import '../features/order/presentation/order_ticket_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/watchlist/presentation/watchlist_screen.dart';
import 'theme/app_colors.dart';

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
    initialLocation: '/home',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final user = ref.read(authStateProvider);
      final isLoggingIn = state.uri.path == '/login';

      if (user == null && !isLoggingIn) {
        return '/login';
      }

      if (user != null && isLoggingIn) {
        return '/home';
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
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/watchlist',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WatchlistScreen(),
            ),
          ),
          GoRoute(
            path: '/market',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MarketScreen(),
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
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNav({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/watchlist')) return 1;
    if (location.startsWith('/market')) return 2;
    if (location.startsWith('/holdings')) return 3;
    return 0; // default to Home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/watchlist');
        break;
      case 2:
        context.go('/market');
        break;
      case 3:
        context.go('/holdings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final colors = context.colors;

    final activeColor = colors.primary;
    final inactiveColor = colors.textSecondary;
    final navBg = colors.surface;
    final borderColor = colors.border;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: navBg,
          elevation: 0,
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context),
          selectedItemColor: activeColor,
          unselectedItemColor: inactiveColor,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: activeColor,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: inactiveColor,
          ),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home, color: activeColor),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.featured_play_list_outlined),
              activeIcon: Icon(Icons.featured_play_list, color: activeColor),
              label: 'Watchlist',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.trending_up),
              activeIcon: Icon(Icons.trending_up, color: activeColor),
              label: 'Market',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet, color: activeColor),
              label: 'Holdings',
            ),
          ],
        ),
      ),
    );
  }
}
