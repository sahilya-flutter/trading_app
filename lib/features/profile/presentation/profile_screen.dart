import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/theme_provider.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../holdings/presentation/holdings_providers.dart';
import '../../watchlist/presentation/watchlist_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.54),
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          'Log out?',
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        content: Text(
          'Your watchlists and holdings stay saved on this device.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.loss,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Log out',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistState = ref.watch(watchlistProvider);
    final holdings = ref.watch(holdingsProvider);
    final colors = context.colors;
    final isDark = context.isDark;

    final holdingsCount = holdings.values.where((h) => h.quantityUnits > 0).length;
    final watchlistCount = watchlistState.watchlists.length;

    final textDark = colors.textPrimary;
    final textGrey = colors.textSecondary;
    final borderGrey = colors.border;
    final cardBg = colors.surfaceElevated;
    final chevronColor = colors.textMuted;
    final errorRed = colors.loss;
    final hairline = colors.divider;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textDark, size: 22),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textDark,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        actions: const [], // No other icons
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Block 1 — Identity Card: full-width #F7F8FA block, 1px border, 8pt radius, 16pt padding, 16pt side margin
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderGrey, width: 1),
                ),
                child: Row(
                  children: [
                    // 48pt circle filled container containing initials "RS"
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.chipBackground,
                      ),
                      child: Center(
                        child: Text(
                          'RS',
                          style: TextStyle(
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Stacked name, phone, Client ID
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rahul Sharma',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+91 98765 43210',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: textGrey,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Client ID · 021RS4821',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: chevronColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Block 2 — Wallet Strip: immediately below, split into two halves by 1px vertical divider
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderGrey, width: 1),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Left half: AVAILABLE BALANCE
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AVAILABLE BALANCE',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textGrey,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹9,64,487.50',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 1px vertical divider
                      Container(
                        width: 1,
                        color: borderGrey,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),

                      // Right half, right-aligned: INVESTED
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'INVESTED',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textGrey,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹3,64,820.00',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Block 3 — Menu List: Plain list with 1px hairline dividers, rows 56pt tall
              _buildMenuItem(
                context: context,
                icon: Icons.receipt_long_outlined,
                label: 'Order history',
                value: '142 orders',
                onTap: () {},
              ),
              Divider(height: 1, thickness: 1, color: hairline),

              _buildMenuItem(
                context: context,
                icon: Icons.pie_chart_outline,
                label: 'Holdings',
                value: holdingsCount > 0 ? '$holdingsCount stocks' : '7 stocks',
                onTap: () => context.go('/holdings'),
              ),
              Divider(height: 1, thickness: 1, color: hairline),

              _buildMenuItem(
                context: context,
                icon: Icons.bookmark_outline,
                label: 'My watchlists',
                value: watchlistCount > 0 ? '$watchlistCount lists' : '3 lists',
                onTap: () => context.go('/watchlist'),
              ),
              Divider(height: 1, thickness: 1, color: hairline),

              // PREFERENCES 32pt band in chipBackground
              Container(
                height: 32,
                width: double.infinity,
                color: colors.chipBackground,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'PREFERENCES',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textGrey,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              _buildMenuItem(
                context: context,
                icon: isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                label: 'Appearance',
                value: isDark
                    ? 'Dark Mode'
                    : 'Light Mode',
                onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
              ),
              Divider(height: 1, thickness: 1, color: hairline),

              _buildMenuItem(
                context: context,
                icon: Icons.speed_outlined,
                label: 'Tick rate',
                value: '5 / sec',
                onTap: () {},
              ),
              Divider(height: 1, thickness: 1, color: hairline),

              _buildMenuItem(
                context: context,
                icon: Icons.info_outline,
                label: 'About',
                value: 'v1.0.0',
                onTap: () {},
              ),
              Divider(height: 1, thickness: 1, color: hairline),

              // Bottom Section: 24pt gap, then full-width 52pt button
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => _showLogoutDialog(context, ref),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: colors.surface,
                      side: BorderSide(color: errorRed, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Log out',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: errorRed,
                      ),
                    ),
                  ),
                ),
              ),

              // Below it, centred 11pt footer line
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 24),
                  child: Text(
                    'Simulated trading. No real money involved.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: chevronColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    String? value,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                if (value != null) ...[
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
