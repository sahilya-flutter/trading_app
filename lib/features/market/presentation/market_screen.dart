import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../auth/presentation/auth_providers.dart';
import 'market_providers.dart';
import 'widgets/market_price_row.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProfileDialog(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                user?.initials ?? 'T',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'Trader',
                    style: AppTextStyles.labelLarge,
                  ),
                  Text(
                    user?.email ?? user?.phone ?? 'Active Session',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user?.isDemo == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Demo Trading Account',
                      style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'Supabase Auth Session Active',
              style: TextStyle(color: AppColors.gain, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.loss),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authControllerProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allStocks = ref.watch(allStocksProvider);
    final isStressMode = ref.watch(stressModeProvider);
    final user = ref.watch(authStateProvider);

    final filteredStocks = allStocks.where((s) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return s.symbol.toLowerCase().contains(q) ||
          s.companyName.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isStressMode ? Colors.amber : AppColors.gain,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isStressMode ? Colors.amber : AppColors.gain).withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text('Market Overview'),
          ],
        ),
        actions: [
          // Stress Mode Button Chip
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              avatar: Icon(
                isStressMode ? Icons.bolt : Icons.speed,
                size: 16,
                color: isStressMode ? Colors.amber : AppColors.textSecondary,
              ),
              label: Text(
                isStressMode ? '50+ t/s' : 'Feed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isStressMode ? Colors.amber : AppColors.textSecondary,
                ),
              ),
              selected: isStressMode,
              selectedColor: Colors.amber.withValues(alpha: 0.15),
              backgroundColor: AppColors.surfaceElevated,
              side: BorderSide(
                color: isStressMode ? Colors.amber.withValues(alpha: 0.5) : AppColors.border,
              ),
              onSelected: (val) {
                ref.read(stressModeProvider.notifier).toggle();
              },
            ),
          ),

          // User Profile Avatar
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => _showProfileDialog(context, user),
              borderRadius: BorderRadius.circular(16),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primary,
                child: Text(
                  user?.initials ?? 'T',
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search stocks (e.g. RELIANCE, TCS)...',
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
            ),
          ),

          // Header summary info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '10 Universe Stocks',
                  style: AppTextStyles.bodySmall,
                ),
                Text(
                  'Tap stock to trade',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryLight),
                ),
              ],
            ),
          ),
          const Divider(),

          // Stocks List
          Expanded(
            child: filteredStocks.isEmpty
                ? const Center(
                    child: Text('No stocks match your search'),
                  )
                : ListView.separated(
                    itemCount: filteredStocks.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final stock = filteredStocks[index];
                      return MarketPriceRow(
                        key: ValueKey(stock.symbol),
                        stock: stock,
                        onTap: () {
                          context.push('/order?symbol=${stock.symbol}');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
