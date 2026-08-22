import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../core/widgets/user_avatar_view.dart';
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

  @override
  Widget build(BuildContext context) {
    final allStocks = ref.watch(allStocksProvider);
    final isStressMode = ref.watch(stressModeProvider);
    final user = ref.watch(authStateProvider);
    final colors = context.colors;
    final isDark = context.isDark;

    final filteredStocks = allStocks.where((s) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return s.symbol.toLowerCase().contains(q) ||
          s.companyName.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isStressMode ? Colors.amber : colors.gain,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isStressMode ? Colors.amber : colors.gain)
                        .withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Market Overview',
              style: TextStyle(
                fontFamily: 'Hanken Grotesk',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // Stress Mode Button Chip
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: FilterChip(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              avatar: Icon(
                isStressMode ? Icons.bolt : Icons.speed,
                size: 14,
                color: isStressMode ? Colors.amber : colors.textSecondary,
              ),
              label: Text(
                isStressMode ? '50+ t/s' : 'Feed',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isStressMode ? Colors.amber : colors.textSecondary,
                ),
              ),
              selected: isStressMode,
              selectedColor: Colors.amber.withValues(alpha: 0.15),
              backgroundColor: colors.surfaceElevated,
              side: BorderSide(
                color: isStressMode
                    ? Colors.amber.withValues(alpha: 0.5)
                    : colors.border,
              ),
              onSelected: (val) {
                ref.read(stressModeProvider.notifier).toggle();
              },
            ),
          ),

          // Theme Toggle Icon Button
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            tooltip: isDark
                ? 'Switch to Light theme'
                : 'Switch to Dark theme',
            icon: Icon(
              isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              size: 20,
              color: colors.primary,
            ),
          ),

          // User Profile Avatar with Google Photo / Initials
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => context.push('/profile'),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: user?.isGoogle == true
                        ? const Color(0xFF4285F4)
                        : colors.primary,
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.transparent,
                  child: UserAvatarView(
                    user: user,
                    size: 28,
                    fontSize: 11,
                  ),
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
                prefixIcon: Icon(Icons.search, size: 20, color: colors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 18, color: colors.textMuted),
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
                Text(
                  '10 Universe Stocks',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  'Tap stock to trade',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.primaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Column Headers Strip: SYMBOL / COMPANY vs LTP / CHG (%)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colors.chipBackground.withValues(alpha: 0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SYMBOL / COMPANY',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'LTP / CHG (%)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: colors.divider),

          // Stocks List
          Expanded(
            child: filteredStocks.isEmpty
                ? Center(
                    child: Text(
                      'No stocks match your search',
                      style: TextStyle(color: colors.textSecondary),
                    ),
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
