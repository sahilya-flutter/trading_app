import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../core/widgets/user_avatar_view.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../notifications/presentation/notifications_providers.dart';
import 'widgets/market_snapshot_card.dart';
import 'widgets/notification_sheet.dart';
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
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final isDark = context.isDark;
    final colors = context.colors;

    final bgColor = colors.background;
    final onSurface = colors.textPrimary;
    final onSurfaceVariant = colors.textSecondary;
    final primaryColor = colors.primary;
    final outlineVariant = colors.border;

    final String displayName = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!.split(' ').first
        : (user?.displayTitle != null && user!.displayTitle.isNotEmpty)
            ? user.displayTitle.split(' ').first
            : 'Sahil';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              children: [
                // Fixed Header / TopAppBar
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border(
                      bottom: BorderSide(
                        color: outlineVariant.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // User Avatar + App Title
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 17,
                              backgroundColor: Colors.transparent,
                              child: UserAvatarView(
                                user: user,
                                size: 34,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '021 Trading App',
                              style: TextStyle(
                                fontFamily: 'Hanken Grotesk',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right Actions: Theme Toggle & Notification Bell Button
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Theme Toggle Icon Button
                          IconButton(
                            onPressed: () {
                              ref.read(themeModeProvider.notifier).toggleTheme();
                            },
                            tooltip: isDark ? 'Switch to Light theme' : 'Switch to Dark theme',
                            icon: Icon(
                              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                              color: primaryColor,
                              size: 22,
                            ),
                          ),

                          // Notification Bell Button
                          IconButton(
                            onPressed: () => NotificationSheet.show(context),
                            tooltip: 'Notifications',
                            icon: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  Icons.notifications_outlined,
                                  color: primaryColor,
                                  size: 24,
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    top: -2,
                                    right: -4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.gain,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          unreadCount > 9 ? '9+' : '$unreadCount',
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Scrollable Canvas
                Expanded(
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
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayName,
                          style: TextStyle(
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Portfolio Summary Card
                        const PortfolioSummaryCard(),
                        const SizedBox(height: 16),

                        // Quick Actions Grid (Buy, Sell, Holdings, Wallet)
                        const QuickActionsGrid(),
                        const SizedBox(height: 20),

                        // Market Snapshot Card (RELIANCE, TCS, INFY)
                        const MarketSnapshotCard(),
                        const SizedBox(height: 20),

                        // Recent Orders List
                        const RecentOrdersList(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
