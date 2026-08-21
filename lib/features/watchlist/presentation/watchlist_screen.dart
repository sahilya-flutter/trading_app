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
            color: Color(0xFF111827),
          ),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Pharma, FMCG, Tech',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0066FF), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
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
              backgroundColor: const Color(0xFF0066FF),
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Plain header reading "Watchlist" in 20 semibold, no back arrow, no icons
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text(
                'Watchlist',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                  letterSpacing: -0.3,
                ),
              ),
            ),

            // Horizontally scrolling strip of pill chips
            SizedBox(
              height: 38,
              child: ListView(
                controller: _chipScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Watchlist Pill Chips
                  for (final wl in watchlists) ...[
                    Builder(
                      builder: (context) {
                        final isActive = wl.id == watchlistState.activeWatchlistId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(watchlistProvider.notifier)
                                  .setActiveWatchlist(wl.id);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF0066FF) // Accent blue
                                    : const Color(0xFFF1F3F5), // Light grey
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  wl.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.white
                                        : const Color(0xFF374151), // Dark grey
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
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () => _showCreateWatchlistDialog(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF1F3F5),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 18,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),

                  // Small circular three-dot chip at the end
                  InkWell(
                    onTap: () => _openWatchlistManager(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF1F3F5),
                      ),
                      child: const Icon(
                        Icons.more_horiz,
                        size: 18,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Column header strip: a 32pt band in #F7F8FA with tiny uppercase grey labels
            Container(
              height: 32,
              color: const Color(0xFFF7F8FA),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SYMBOL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8E95A2),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'LTP / CHG',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8E95A2),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Body: Stock List OR Empty State Variant
            Expanded(
              child: symbols.isEmpty
                  ? _buildEmptyState(context)
                  : Column(
                      children: [
                        Expanded(
                          child: ReorderableListView.builder(
                            buildDefaultDragHandles: false,
                            itemCount: symbols.length,
                            // ignore: deprecated_member_use
                            onReorder: (oldIndex, newIndex) {
                              ref
                                  .read(watchlistProvider.notifier)
                                  .reorderActiveWatchlist(oldIndex, newIndex);
                            },
                            itemBuilder: (context, index) {
                              final symbol = symbols[index];
                              return Column(
                                key: ValueKey('watchlist_row_$symbol'),
                                children: [
                                  WatchlistRow(
                                    key: ValueKey('row_$symbol'),
                                    symbol: symbol,
                                    index: index,
                                    onTap: () {
                                      context.push('/order?symbol=$symbol');
                                    },
                                  ),
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Color(0xFFECEFF2),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        // Bottom of content: full-width, 48pt, white button with 1px grey border and + icon
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () => _openAddStocks(context),
                              icon: const Icon(
                                Icons.add,
                                size: 18,
                                color: Color(0xFF111827),
                              ),
                              label: const Text(
                                'Add stocks',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
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

  /// Empty State Variant:
  /// centred in the body a light grey playlist icon, the title "No stocks yet" in 16 semibold,
  /// the grey one-line subtitle "Add stocks to this watchlist to track live prices.",
  /// and a blue filled "Add stocks" button beneath.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.playlist_add,
              size: 56,
              color: Color(0xFFC4C8D0), // Light grey playlist icon
            ),
            const SizedBox(height: 16),
            const Text(
              'No stocks yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add stocks to this watchlist to track live prices.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => _openAddStocks(context),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text(
                  'Add stocks',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF), // Blue filled
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
