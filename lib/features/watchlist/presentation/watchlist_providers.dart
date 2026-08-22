import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../persistence/local_storage_service.dart';
import '../../market/presentation/market_providers.dart';
import '../../notifications/domain/notification_item.dart';
import '../../notifications/presentation/notifications_providers.dart';
import '../domain/watchlist.dart';

class WatchlistState {
  final List<Watchlist> watchlists;
  final String activeWatchlistId;

  const WatchlistState({
    required this.watchlists,
    required this.activeWatchlistId,
  });

  Watchlist? get activeWatchlist {
    try {
      return watchlists.firstWhere((w) => w.id == activeWatchlistId);
    } catch (_) {
      return watchlists.isNotEmpty ? watchlists.first : null;
    }
  }

  WatchlistState copyWith({
    List<Watchlist>? watchlists,
    String? activeWatchlistId,
  }) {
    return WatchlistState(
      watchlists: watchlists ?? this.watchlists,
      activeWatchlistId: activeWatchlistId ?? this.activeWatchlistId,
    );
  }
}

class WatchlistNotifier extends StateNotifier<WatchlistState> {
  final LocalStorageService _storage;
  final Ref? _ref;
  final Uuid _uuid = const Uuid();

  WatchlistNotifier(this._storage, [this._ref])
      : super(WatchlistState(
          watchlists: _storage.loadWatchlists(),
          activeWatchlistId: _storage.loadActiveWatchlistId(),
        )) {
    // Ensure activeWatchlistId is valid and at least one watchlist exists
    if (state.watchlists.isEmpty) {
      final defaultWl = Watchlist(
        id: 'default_watchlist',
        name: 'My Watchlist',
        symbols: ['RELIANCE', 'TCS', 'INFY', 'HDFCBANK', 'ICICIBANK'],
        createdAt: DateTime.now(),
      );
      state = WatchlistState(
        watchlists: [defaultWl],
        activeWatchlistId: defaultWl.id,
      );
      _persist();
    } else if (state.activeWatchlist == null) {
      state = state.copyWith(activeWatchlistId: state.watchlists.first.id);
    }
  }

  void _persist() {
    _storage.saveWatchlists(state.watchlists);
    _storage.saveActiveWatchlistId(state.activeWatchlistId);
  }

  void setActiveWatchlist(String id) {
    if (state.watchlists.any((w) => w.id == id)) {
      state = state.copyWith(activeWatchlistId: id);
      _persist();
    }
  }

  String createWatchlist(String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return state.activeWatchlistId;

    final newWatchlist = Watchlist(
      id: _uuid.v4(),
      name: cleanName,
      symbols: [],
      createdAt: DateTime.now(),
    );

    final updatedList = [...state.watchlists, newWatchlist];
    state = state.copyWith(
      watchlists: updatedList,
      activeWatchlistId: newWatchlist.id,
    );
    _persist();

    _ref?.read(notificationsProvider.notifier).addNotification(
          title: 'Watchlist created',
          message: '$cleanName watchlist created',
          type: NotificationType.watchlist,
          metadata: {'watchlistId': newWatchlist.id},
        );

    return newWatchlist.id;
  }

  void renameWatchlist(String id, String newName) {
    final cleanName = newName.trim();
    if (cleanName.isEmpty) return;

    String? oldName;
    final updated = state.watchlists.map((w) {
      if (w.id == id) {
        oldName = w.name;
        return w.copyWith(name: cleanName);
      }
      return w;
    }).toList();

    state = state.copyWith(watchlists: updated);
    _persist();

    if (oldName != null && oldName != cleanName) {
      _ref?.read(notificationsProvider.notifier).addNotification(
            title: 'Watchlist renamed',
            message: '$oldName renamed to $cleanName',
            type: NotificationType.watchlist,
            metadata: {'watchlistId': id},
          );
    }
  }

  void deleteWatchlist(String id) {
    String? deletedName;
    try {
      deletedName = state.watchlists.firstWhere((w) => w.id == id).name;
    } catch (_) {}

    if (state.watchlists.length <= 1) {
      // Reset the single remaining watchlist to empty symbols
      final reset = state.watchlists.first.copyWith(symbols: []);
      state = state.copyWith(watchlists: [reset]);
      _persist();
      return;
    }

    final updated = state.watchlists.where((w) => w.id != id).toList();
    var newActiveId = state.activeWatchlistId;
    if (newActiveId == id) {
      newActiveId = updated.first.id;
    }

    state = state.copyWith(
      watchlists: updated,
      activeWatchlistId: newActiveId,
    );
    _persist();

    if (deletedName != null) {
      _ref?.read(notificationsProvider.notifier).addNotification(
            title: 'Watchlist deleted',
            message: '$deletedName watchlist deleted',
            type: NotificationType.watchlist,
            metadata: {'watchlistId': id},
          );
    }
  }

  bool addStockToActiveWatchlist(String symbol) {
    final active = state.activeWatchlist;
    if (active == null) return false;

    // Check for duplicate
    if (active.symbols.contains(symbol)) {
      return false; // Already present
    }

    final updatedSymbols = [...active.symbols, symbol];
    final updatedWatchlist = active.copyWith(symbols: updatedSymbols);

    final updatedList = state.watchlists.map((w) {
      return w.id == active.id ? updatedWatchlist : w;
    }).toList();

    state = state.copyWith(watchlists: updatedList);
    _persist();

    _ref?.read(notificationsProvider.notifier).addNotification(
          title: 'Watchlist updated',
          message: '$symbol added to ${active.name}',
          type: NotificationType.watchlist,
          metadata: {'symbol': symbol, 'watchlistId': active.id},
        );

    return true;
  }

  bool insertStockIntoActiveWatchlist(String symbol, int index) {
    final active = state.activeWatchlist;
    if (active == null) return false;

    if (active.symbols.contains(symbol)) {
      return false;
    }

    final updatedSymbols = List<String>.from(active.symbols);
    final targetIndex = index.clamp(0, updatedSymbols.length);
    updatedSymbols.insert(targetIndex, symbol);

    final updatedWatchlist = active.copyWith(symbols: updatedSymbols);
    final updatedList = state.watchlists.map((w) {
      return w.id == active.id ? updatedWatchlist : w;
    }).toList();

    state = state.copyWith(watchlists: updatedList);
    _persist();

    _ref?.read(notificationsProvider.notifier).addNotification(
          title: 'Watchlist updated',
          message: '$symbol added to ${active.name}',
          type: NotificationType.watchlist,
          metadata: {'symbol': symbol, 'watchlistId': active.id},
        );

    return true;
  }

  void removeStockFromActiveWatchlist(String symbol) {
    final active = state.activeWatchlist;
    if (active == null) return;

    if (!active.symbols.contains(symbol)) return;

    final updatedSymbols = active.symbols.where((s) => s != symbol).toList();
    final updatedWatchlist = active.copyWith(symbols: updatedSymbols);

    final updatedList = state.watchlists.map((w) {
      return w.id == active.id ? updatedWatchlist : w;
    }).toList();

    state = state.copyWith(watchlists: updatedList);
    _persist();

    _ref?.read(notificationsProvider.notifier).addNotification(
          title: 'Watchlist updated',
          message: '$symbol removed from ${active.name}',
          type: NotificationType.watchlist,
          metadata: {'symbol': symbol, 'watchlistId': active.id},
        );
  }

  void removeStockFromWatchlist(String watchlistId, String symbol) {
    String? watchlistName;
    final updatedList = state.watchlists.map((w) {
      if (w.id == watchlistId) {
        watchlistName = w.name;
        final updatedSymbols = w.symbols.where((s) => s != symbol).toList();
        return w.copyWith(symbols: updatedSymbols);
      }
      return w;
    }).toList();

    state = state.copyWith(watchlists: updatedList);
    _persist();

    if (watchlistName != null) {
      _ref?.read(notificationsProvider.notifier).addNotification(
            title: 'Watchlist updated',
            message: '$symbol removed from $watchlistName',
            type: NotificationType.watchlist,
            metadata: {'symbol': symbol, 'watchlistId': watchlistId},
          );
    }
  }

  void reorderActiveWatchlist(int oldIndex, int newIndex) {
    final active = state.activeWatchlist;
    if (active == null) return;

    final symbols = List<String>.from(active.symbols);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (oldIndex < 0 ||
        oldIndex >= symbols.length ||
        newIndex < 0 ||
        newIndex >= symbols.length) {
      return;
    }

    final item = symbols.removeAt(oldIndex);
    symbols.insert(newIndex, item);

    final updatedWatchlist = active.copyWith(symbols: symbols);
    final updatedList = state.watchlists.map((w) {
      return w.id == active.id ? updatedWatchlist : w;
    }).toList();

    state = state.copyWith(watchlists: updatedList);
    _persist();
  }
}

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, WatchlistState>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return WatchlistNotifier(storage, ref);
});

final activeWatchlistProvider = Provider<Watchlist?>((ref) {
  return ref.watch(watchlistProvider).activeWatchlist;
});
