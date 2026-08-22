import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/trading_app_bar.dart';
import '../../auth/presentation/auth_providers.dart';
import 'widgets/market_snapshot_card.dart';
import 'widgets/portfolio_summary_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/recent_orders_list.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final colors = context.colors;

    final String displayName = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!.split(' ').first
        : (user?.displayTitle != null && user!.displayTitle.isNotEmpty)
            ? user.displayTitle.split(' ').first
            : 'Sahil';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: TradingAppBar.home(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Section
                Text(
                  _getTimeBasedGreeting(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayName,
                  style: TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Market Snapshot Card (Top 3 Movers)
                const MarketSnapshotCard(),
                const SizedBox(height: 16),

                // Live Portfolio Card
                const PortfolioSummaryCard(),
                const SizedBox(height: 16),

                // Quick Actions (2x2 Grid)
                const QuickActionsGrid(),
                const SizedBox(height: 20),

                // Recent Orders List (Last 3)
                const RecentOrdersList(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
