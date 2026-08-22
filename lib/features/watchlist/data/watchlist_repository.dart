import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../persistence/local_storage_service.dart';
import '../../market/presentation/market_providers.dart';
import '../domain/watchlist.dart';

abstract class WatchlistRepository {
  List<Watchlist> loadWatchlists();
  Future<bool> saveWatchlists(List<Watchlist> watchlists);
  String loadActiveWatchlistId();
  Future<bool> saveActiveWatchlistId(String id);
}

class LocalWatchlistRepository implements WatchlistRepository {
  final LocalStorageService _storage;

  LocalWatchlistRepository(this._storage);

  @override
  List<Watchlist> loadWatchlists() {
    return _storage.loadWatchlists();
  }

  @override
  Future<bool> saveWatchlists(List<Watchlist> watchlists) {
    return _storage.saveWatchlists(watchlists);
  }

  @override
  String loadActiveWatchlistId() {
    return _storage.loadActiveWatchlistId();
  }

  @override
  Future<bool> saveActiveWatchlistId(String id) {
    return _storage.saveActiveWatchlistId(id);
  }
}

final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalWatchlistRepository(storage);
});
