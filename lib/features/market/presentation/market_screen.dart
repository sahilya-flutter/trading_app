import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
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
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              avatar: Icon(
                isStressMode ? Icons.bolt : Icons.speed,
                size: 16,
                color: isStressMode ? Colors.amber : AppColors.textSecondary,
              ),
              label: Text(
                isStressMode ? 'Stress 50+ t/s' : 'Normal Feed',
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
