import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../holdings/presentation/holdings_providers.dart';
import '../../watchlist/presentation/watchlist_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.54),
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: const Text(
          'Log out?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0E1621),
            letterSpacing: -0.2,
          ),
        ),
        content: const Text(
          'Your watchlists and holdings stay saved on this device.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF65707D),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF65707D),
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
              backgroundColor: const Color(0xFFD93025),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Log out',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
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

    final holdingsCount = holdings.values.where((h) => h.quantityUnits > 0).length;
    final watchlistCount = watchlistState.watchlists.length;

    const textDark = Color(0xFF0E1621);
    const textGrey = Color(0xFF65707D);
    const borderGrey = Color(0xFFE3E7ED);
    const cardBg = Color(0xFFF7F8FA);
    const chevronColor = Color(0xFF9AA4B0);
    const errorRed = Color(0xFFD93025);
    const hairline = Color(0xFFECEFF2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark, size: 22),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
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
                    // 48pt circle filled #EEF1F5 containing initials "RS" in 18 semibold #1F4FD8
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFEEF1F5),
                      ),
                      child: const Center(
                        child: Text(
                          'RS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F4FD8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Stacked name, phone, Client ID
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rahul Sharma',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '+91 98765 43210',
                            style: TextStyle(
                              fontSize: 13,
                              color: textGrey,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Client ID · 021RS4821',
                            style: TextStyle(
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

              // Block 2 — Wallet Strip: immediately below, #F7F8FA, split into two halves by 1px vertical divider
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AVAILABLE BALANCE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textGrey,
                                letterSpacing: 0.4,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '₹9,64,487.50',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                                fontFeatures: [
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'INVESTED',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textGrey,
                                letterSpacing: 0.4,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '₹3,64,820.00',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                                fontFeatures: [
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

              // Block 3 — Menu List: Plain white list with 1px hairline dividers, rows 56pt tall
              _buildMenuItem(
                icon: Icons.receipt_long_outlined,
                label: 'Order history',
                value: '142 orders',
                onTap: () {},
              ),
              const Divider(height: 1, thickness: 1, color: hairline),

              _buildMenuItem(
                icon: Icons.pie_chart_outline,
                label: 'Holdings',
                value: holdingsCount > 0 ? '$holdingsCount stocks' : '7 stocks',
                onTap: () => context.go('/holdings'),
              ),
              const Divider(height: 1, thickness: 1, color: hairline),

              _buildMenuItem(
                icon: Icons.bookmark_outline,
                label: 'My watchlists',
                value: watchlistCount > 0 ? '$watchlistCount lists' : '3 lists',
                onTap: () => context.go('/watchlist'),
              ),
              const Divider(height: 1, thickness: 1, color: hairline),

              // PREFERENCES 32pt band in #F7F8FA
              Container(
                height: 32,
                width: double.infinity,
                color: cardBg,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Text(
                  'PREFERENCES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textGrey,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              _buildMenuItem(
                icon: Icons.speed_outlined,
                label: 'Tick rate',
                value: '5 / sec',
                onTap: () {},
              ),
              const Divider(height: 1, thickness: 1, color: hairline),

              _buildMenuItem(
                icon: Icons.info_outline,
                label: 'About',
                value: 'v1.0.0',
                onTap: () {},
              ),
              const Divider(height: 1, thickness: 1, color: hairline),

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
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: errorRed, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: errorRed,
                      ),
                    ),
                  ),
                ),
              ),

              // Below it, centred 11pt #9AA4B0 line
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 14, bottom: 24),
                  child: Text(
                    'Simulated trading. No real money involved.',
                    style: TextStyle(
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
    required IconData icon,
    required String label,
    String? value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
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
                  color: const Color(0xFF65707D),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF0E1621),
                    ),
                  ),
                ),
                if (value != null) ...[
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF65707D),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Color(0xFF9AA4B0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
