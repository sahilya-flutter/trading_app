import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/features/watchlist/presentation/watchlist_providers.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  group('Watchlist CRUD & Reorder Tests', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.create();

      container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initializes with default watchlist containing default symbols', () {
      final state = container.read(watchlistProvider);
      expect(state.watchlists.isNotEmpty, isTrue);
      expect(state.activeWatchlist, isNotNull);
      expect(state.activeWatchlist!.symbols.contains('RELIANCE'), isTrue);
    });

    test('Creating a new watchlist sets it as active', () {
      final notifier = container.read(watchlistProvider.notifier);
      final newId = notifier.createWatchlist('Banking Stocks');

      final state = container.read(watchlistProvider);
      expect(state.activeWatchlistId, newId);
      expect(state.activeWatchlist!.name, 'Banking Stocks');
      expect(state.activeWatchlist!.symbols.isEmpty, isTrue);
    });

    test('Adding and removing stock from active watchlist works & prevents duplicates', () {
      final notifier = container.read(watchlistProvider.notifier);
      notifier.createWatchlist('Tech');

      // Add INFY
      final added1 = notifier.addStockToActiveWatchlist('INFY');
      expect(added1, isTrue);
      expect(container.read(watchlistProvider).activeWatchlist!.symbols, ['INFY']);

      // Duplicate INFY should be rejected
      final addedDuplicate = notifier.addStockToActiveWatchlist('INFY');
      expect(addedDuplicate, isFalse);
      expect(container.read(watchlistProvider).activeWatchlist!.symbols, ['INFY']);

      // Add TCS
      notifier.addStockToActiveWatchlist('TCS');
      expect(container.read(watchlistProvider).activeWatchlist!.symbols, ['INFY', 'TCS']);

      // Remove INFY
      notifier.removeStockFromActiveWatchlist('INFY');
      expect(container.read(watchlistProvider).activeWatchlist!.symbols, ['TCS']);
    });

    test('Reordering symbols maintains correct list order', () {
      final notifier = container.read(watchlistProvider.notifier);
      notifier.createWatchlist('Test Reorder');
      notifier.addStockToActiveWatchlist('RELIANCE');
      notifier.addStockToActiveWatchlist('TCS');
      notifier.addStockToActiveWatchlist('INFY');

      // Order: [RELIANCE, TCS, INFY]
      // Move RELIANCE (index 0) after TCS (newIndex 2 in flutter reorder)
      notifier.reorderActiveWatchlist(0, 2);

      final symbols = container.read(watchlistProvider).activeWatchlist!.symbols;
      expect(symbols, ['TCS', 'RELIANCE', 'INFY']);
    });

    test('Renaming and deleting watchlists works correctly', () {
      final notifier = container.read(watchlistProvider.notifier);
      final id = notifier.createWatchlist('Old Name');

      notifier.renameWatchlist(id, 'New Name');
      expect(container.read(watchlistProvider).activeWatchlist!.name, 'New Name');

      notifier.deleteWatchlist(id);
      final state = container.read(watchlistProvider);
      expect(state.watchlists.any((w) => w.id == id), isFalse);
    });
  });
}
