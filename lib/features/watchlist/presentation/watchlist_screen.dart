import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'watchlist_providers.dart';
import 'widgets/add_stock_sheet.dart';
import 'widgets/watchlist_row.dart';
import 'widgets/watchlist_selector_sheet.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  final ScrollController _chipScrollController = ScrollController();

  @override
  void dispose() {
    _chipScrollController.dispose();
    super.dispose();
  }

  void _openAddStocks(BuildContext context) {
    AddStockSheet.show(context);
  }

  void _openWatchlistManager(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WatchlistSelectorSheet(),
    );
  }

  void _showCreateWatchlistDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Create Watchlist',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0E1621),
          ),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Banking, IT Stocks, Auto',
            hintStyle: const TextStyle(color: Color(0xFF9AA4B0), fontSize: 14),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF1F4FD8), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF65707D)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                ref.read(watchlistProvider.notifier).createWatchlist(name);
                Navigator.of(ctx).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F4FD8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Create',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final watchlistState = ref.watch(watchlistProvider);
    final activeWatchlist = watchlistState.activeWatchlist;
    final watchlists = watchlistState.watchlists;
    final symbols = activeWatchlist?.symbols ?? [];

    const accentBlue = Color(0xFF1F4FD8);
    const textDark = Color(0xFF0E1621);
    const textMuted = Color(0xFF64748B);
    const inactivePillBg = Color(0xFFD9E2EC);
    const borderGrey = Color(0xFFE2E8F0);
    const hairline = Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Plain header reading "Watchlist" in 24 bold, no back arrow, no icons
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Text(
                'Watchlist',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                  letterSpacing: -0.4,
                ),
              ),
            ),

            // Horizontally scrolling strip of pill chips
            SizedBox(
              height: 40,
              child: ListView(
                controller: _chipScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Watchlist Pill Chips
                  for (final wl in watchlists) ...[
                    Builder(
                      builder: (context) {
                        final isActive =
                            wl.id == watchlistState.activeWatchlistId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(watchlistProvider.notifier)
                                  .setActiveWatchlist(wl.id);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isActive ? accentBlue : inactivePillBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  wl.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.white
                                        : const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  // Small circular + chip at the end
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => _showCreateWatchlistDialog(context),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: borderGrey),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                          color: textMuted,
                        ),
                      ),
                    ),
                  ),

                  // Small circular three-dot chip at the end
                  InkWell(
                    onTap: () => _openWatchlistManager(context),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: borderGrey),
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        size: 20,
                        color: textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Column header strip: a 32pt band in #F8FAFC with uppercase grey labels
            Container(
              height: 32,
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SYMBOL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    'LTP / CHG',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),

            // Body: Stock List OR Empty State Variant
            Expanded(
              child: symbols.isEmpty
                  ? _buildEmptyState(context)
                  : CustomScrollView(
                      slivers: [
                        SliverReorderableList(
                          itemCount: symbols.length,
                          // ignore: deprecated_member_use
                          onReorder: (oldIndex, newIndex) {
                            ref
                                .read(watchlistProvider.notifier)
                                .reorderActiveWatchlist(oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final sym = symbols[index];
                            return Column(
                              key: ValueKey(sym),
                              children: [
                                WatchlistRow(
                                  key: Key('watchlist_row_$sym'),
                                  symbol: sym,
                                  index: index,
                                  onTap: () {
                                    context.push('/order?symbol=$sym');
                                  },
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: hairline,
                                ),
                              ],
                            );
                          },
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () => _openAddStocks(context),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: borderGrey,
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 20,
                                      color: textDark,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Add stocks',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: textDark,
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF1F5F9),
              ),
              child: const Icon(
                Icons.playlist_add,
                size: 32,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No stocks yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0E1621),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add stocks to this watchlist to track live prices.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => _openAddStocks(context),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text(
                  'Add stocks',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F4FD8),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
