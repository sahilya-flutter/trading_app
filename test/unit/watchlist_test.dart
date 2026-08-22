import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/features/market/presentation/market_providers.dart';
import 'package:trading_app/features/watchlist/presentation/watchlist_providers.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  group('Watchlist CRUD & Reorder Tests', () {
    late LocalStorageService storage;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService.create();

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

    test('Creating a new watchlist sets it as active and ignores empty names', () {
      final notifier = container.read(watchlistProvider.notifier);
      final prevActiveId = container.read(watchlistProvider).activeWatchlistId;

      // Empty name should be blocked
      final blockedId = notifier.createWatchlist('   ');
      expect(blockedId, prevActiveId);

      // Valid name creates and sets active
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

      // Add TCS and RELIANCE
      notifier.addStockToActiveWatchlist('TCS');
      notifier.addStockToActiveWatchlist('RELIANCE');
      expect(container.read(watchlistProvider).activeWatchlist!.symbols,
          ['INFY', 'TCS', 'RELIANCE']);

      // Remove TCS -> verify INFY and RELIANCE remain intact
      notifier.removeStockFromActiveWatchlist('TCS');
      expect(container.read(watchlistProvider).activeWatchlist!.symbols,
          ['INFY', 'RELIANCE']);
    });

    test('Removing stock from Watchlist A does not affect Watchlist B', () {
      final notifier = container.read(watchlistProvider.notifier);

      // Create Watchlist A and add RELIANCE and TCS
      final idA = notifier.createWatchlist('Watchlist A');
      notifier.addStockToActiveWatchlist('RELIANCE');
      notifier.addStockToActiveWatchlist('TCS');

      // Create Watchlist B and add RELIANCE and INFY
      final idB = notifier.createWatchlist('Watchlist B');
      notifier.addStockToActiveWatchlist('RELIANCE');
      notifier.addStockToActiveWatchlist('INFY');

      // Switch back to Watchlist A and remove RELIANCE
      notifier.setActiveWatchlist(idA);
      notifier.removeStockFromActiveWatchlist('RELIANCE');

      // Verify Watchlist A has only TCS
      final wlA = container.read(watchlistProvider).watchlists.firstWhere((w) => w.id == idA);
      expect(wlA.symbols, ['TCS']);

      // Verify Watchlist B STILL contains RELIANCE and INFY
      final wlB = container.read(watchlistProvider).watchlists.firstWhere((w) => w.id == idB);
      expect(wlB.symbols, ['RELIANCE', 'INFY']);
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

    test('Renaming and deleting watchlists works correctly and maintains persistence', () async {
      final notifier = container.read(watchlistProvider.notifier);
      final id = notifier.createWatchlist('Old Name');

      notifier.renameWatchlist(id, 'New Name');
      expect(container.read(watchlistProvider).activeWatchlist!.name, 'New Name');

      notifier.deleteWatchlist(id);
      final state = container.read(watchlistProvider);
      expect(state.watchlists.any((w) => w.id == id), isFalse);

      // Verify re-loading from LocalStorageService maintains persisted state
      final freshStorage = await LocalStorageService.create();
      final freshWatchlists = freshStorage.loadWatchlists();
      expect(freshWatchlists.any((w) => w.id == id), isFalse);
    });

    test('Undo insertion works at the specified index', () {
      final notifier = container.read(watchlistProvider.notifier);
      notifier.createWatchlist('Undo Test');
      notifier.addStockToActiveWatchlist('RELIANCE');
      notifier.addStockToActiveWatchlist('INFY');

      // Insert TCS at index 1 -> [RELIANCE, TCS, INFY]
      final inserted = notifier.insertStockIntoActiveWatchlist('TCS', 1);
      expect(inserted, isTrue);
      expect(container.read(watchlistProvider).activeWatchlist!.symbols,
          ['RELIANCE', 'TCS', 'INFY']);
    });
  });
}
