import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../watchlist_providers.dart';

class WatchlistSelectorSheet extends ConsumerWidget {
  const WatchlistSelectorSheet({super.key});

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final colors = context.colors;
    String? errorText;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
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
              controller: controller,
              autofocus: true,
              style: TextStyle(color: colors.textPrimary),
              onChanged: (_) {
                if (errorText != null) {
                  setDialogState(() => errorText = null);
                }
              },
              decoration: InputDecoration(
                hintText: 'Watchlist Name (e.g. Banking, Tech)',
                hintStyle: TextStyle(color: colors.textMuted, fontSize: 14),
                errorText: errorText,
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
                child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isEmpty) {
                    setDialogState(() {
                      errorText = 'Please enter a watchlist name';
                    });
                    return;
                  }
                  if (ref.read(watchlistProvider.notifier).isNameDuplicate(name)) {
                    setDialogState(() {
                      errorText = 'A watchlist with this name already exists';
                    });
                    return;
                  }
                  ref.read(watchlistProvider.notifier).createWatchlist(name);
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
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
          );
        },
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context, WidgetRef ref, String id, String currentName) {
    final controller = TextEditingController(text: currentName);
    final colors = context.colors;
    String? errorText;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: colors.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colors.border),
            ),
            title: Text(
              'Rename Watchlist',
              style: TextStyle(
                fontFamily: 'Hanken Grotesk',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(color: colors.textPrimary),
              onChanged: (_) {
                if (errorText != null) {
                  setDialogState(() => errorText = null);
                }
              },
              decoration: InputDecoration(
                hintText: 'New Watchlist Name',
                hintStyle: TextStyle(color: colors.textMuted, fontSize: 14),
                errorText: errorText,
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
                child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isEmpty) {
                    setDialogState(() {
                      errorText = 'Please enter a watchlist name';
                    });
                    return;
                  }
                  if (ref.read(watchlistProvider.notifier).isNameDuplicate(name, excludeId: id)) {
                    setDialogState(() {
                      errorText = 'A watchlist with this name already exists';
                    });
                    return;
                  }
                  ref.read(watchlistProvider.notifier).renameWatchlist(id, name);
                  Navigator.of(ctx).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(color: colors.onPrimary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, String id, String name) {
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
          'Delete Watchlist',
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$name"?',
          style: TextStyle(color: colors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.loss,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              ref.read(watchlistProvider.notifier).deleteWatchlist(id);
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: colors.onPrimary, fontWeight: FontWeight.w600),
            ),
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
    final colors = context.colors;

    return Material(
      color: colors.surfaceElevated,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Manage Watchlists',
                      style: TextStyle(
                        fontFamily: 'Hanken Grotesk',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.add, size: 18, color: colors.primary),
                    label: Text(
                      'New Watchlist',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => _showCreateDialog(context, ref),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: colors.divider),

          // Watchlist list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: watchlists.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, thickness: 1, color: colors.divider),
              itemBuilder: (context, index) {
                final w = watchlists[index];
                final isSelected = w.id == activeId;

                return ListTile(
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected
                        ? colors.primary
                        : colors.textMuted,
                  ),
                  title: Text(
                    w.name,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? colors.textPrimary
                          : colors.textSecondary,
                    ),
                  ),
                  subtitle: Text(
                    '${w.symbols.length} stocks',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: colors.textMuted,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined,
                            size: 18, color: colors.textSecondary),
                        onPressed: () =>
                            _showRenameDialog(context, ref, w.id, w.name),
                        tooltip: 'Rename',
                      ),
                      if (watchlists.length > 1)
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              size: 18, color: colors.loss),
                          onPressed: () =>
                              _showDeleteDialog(context, ref, w.id, w.name),
                          tooltip: 'Delete',
                        ),
                    ],
                  ),
                  onTap: () {
                    ref
                        .read(watchlistProvider.notifier)
                        .setActiveWatchlist(w.id);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }
}
