import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
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
    final colors = context.colors;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        title: Text(
          'Create Watchlist',
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Banking, IT Stocks, Auto',
            hintStyle: TextStyle(color: colors.textMuted, fontSize: 14),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
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
              backgroundColor: colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Create',
              style: TextStyle(color: colors.onPrimary, fontWeight: FontWeight.w600),
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
    final colors = context.colors;

    final accentBlue = colors.primary;
    final textDark = colors.textPrimary;
    final textMuted = colors.textSecondary;
    final inactivePillBg = colors.chipBackground;
    final borderGrey = colors.border;
    final hairline = colors.divider;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Plain header reading "Watchlist" in 24 bold, no back arrow, no icons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Text(
                'Watchlist',
                style: TextStyle(
                  fontFamily: 'Hanken Grotesk',
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
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? colors.onPrimary
                                        : colors.textPrimary,
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
                          color: colors.chipBackground,
                          border: Border.all(color: borderGrey),
                        ),
                        child: Icon(
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
                        color: colors.chipBackground,
                        border: Border.all(color: borderGrey),
                      ),
                      child: Icon(
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

            // Column header strip: a 32pt band in surfaceHigh with uppercase grey labels
            Container(
              height: 32,
              color: colors.chipBackground,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SYMBOL',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    'LTP / CHG',
                    style: TextStyle(
                      fontFamily: 'Inter',
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
                                Divider(
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
                                  backgroundColor: colors.surface,
                                  side: BorderSide(
                                    color: borderGrey,
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 20,
                                      color: textDark,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Add stocks',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
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
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.chipBackground,
              ),
              child: Icon(
                Icons.playlist_add,
                size: 32,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No stocks yet',
              style: TextStyle(
                fontFamily: 'Hanken Grotesk',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add stocks to this watchlist to track live prices.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => _openAddStocks(context),
                icon: Icon(Icons.add, size: 18, color: colors.onPrimary),
                label: Text(
                  'Add stocks',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
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
