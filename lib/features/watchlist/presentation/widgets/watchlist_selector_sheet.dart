import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../watchlist_providers.dart';

class WatchlistSelectorSheet extends ConsumerWidget {
  const WatchlistSelectorSheet({super.key});

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Create New Watchlist', style: AppTextStyles.headingSmall),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Watchlist Name (e.g. Banking, Tech)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(watchlistProvider.notifier).createWatchlist(name);
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(); // Close sheet too
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, String id, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Rename Watchlist', style: AppTextStyles.headingSmall),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'New Watchlist Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(watchlistProvider.notifier).renameWatchlist(id, name);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Delete Watchlist', style: AppTextStyles.headingSmall),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.loss),
            onPressed: () {
              ref.read(watchlistProvider.notifier).deleteWatchlist(id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(watchlistProvider);
    final watchlists = state.watchlists;
    final activeId = state.activeWatchlistId;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('All Watchlists', style: AppTextStyles.headingSmall),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18, color: AppColors.primaryLight),
                  label: const Text('New Watchlist', style: TextStyle(color: AppColors.primaryLight)),
                  onPressed: () => _showCreateDialog(context, ref),
                ),
              ],
            ),
          ),
          const Divider(),

          // Watchlist list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: watchlists.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final w = watchlists[index];
                final isSelected = w.id == activeId;

                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                  ),
                  title: Text(
                    w.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  subtitle: Text(
                    '${w.symbols.length} stocks',
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textMuted),
                        onPressed: () => _showRenameDialog(context, ref, w.id, w.name),
                        tooltip: 'Rename',
                      ),
                      if (watchlists.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.loss),
                          onPressed: () => _showDeleteDialog(context, ref, w.id, w.name),
                          tooltip: 'Delete',
                        ),
                    ],
                  ),
                  onTap: () {
                    ref.read(watchlistProvider.notifier).setActiveWatchlist(w.id);
                    Navigator.of(context).pop();
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
