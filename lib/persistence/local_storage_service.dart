import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../features/auth/domain/user_profile.dart';
import '../features/holdings/domain/holding.dart';
import '../features/order/domain/order_model.dart';
import '../features/wallet/domain/wallet_model.dart';
import '../features/watchlist/domain/watchlist.dart';
import 'storage_keys.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // ==================== WATCHLISTS ====================

  List<Watchlist> loadWatchlists() {
    try {
      final raw = _prefs.getString(StorageKeys.watchlists);
      if (raw == null || raw.isEmpty) {
        return _createDefaultWatchlists();
      }
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final list = decoded
            .map((item) {
              try {
                return Watchlist.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                return null;
              }
            })
            .whereType<Watchlist>()
            .toList();

        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('Error loading watchlists from storage: $e');
    }
    return _createDefaultWatchlists();
  }

  Future<bool> saveWatchlists(List<Watchlist> watchlists) async {
    try {
      final jsonList = watchlists.map((w) => w.toJson()).toList();
      return await _prefs.setString(StorageKeys.watchlists, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving watchlists: $e');
      return false;
    }
  }

  String loadActiveWatchlistId() {
    return _prefs.getString(StorageKeys.activeWatchlistId) ??
        AppConstants.defaultWatchlistId;
  }

  Future<bool> saveActiveWatchlistId(String id) async {
    return await _prefs.setString(StorageKeys.activeWatchlistId, id);
  }

  List<Watchlist> _createDefaultWatchlists() {
    return [
      Watchlist(
        id: AppConstants.defaultWatchlistId,
        name: 'My Watchlist',
        symbols: List.from(AppConstants.defaultWatchlistSymbols),
        createdAt: DateTime.now(),
      ),
      Watchlist(
        id: 'watchlist_banking',
        name: 'Banking',
        symbols: ['HDFCBANK', 'ICICIBANK', 'SBIN', 'AXISBANK'],
        createdAt: DateTime.now(),
      ),
      Watchlist(
        id: 'watchlist_it',
        name: 'IT Stocks',
        symbols: ['TCS', 'INFY'],
        createdAt: DateTime.now(),
      ),
    ];
  }

  // ==================== WALLET ====================

  WalletModel loadWallet() {
    try {
      final raw = _prefs.getString(StorageKeys.wallet);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return WalletModel.fromJson(decoded);
        }
      }
    } catch (e) {
      debugPrint('Error loading wallet from storage: $e');
    }
    return WalletModel.initial();
  }

  Future<bool> saveWallet(WalletModel wallet) async {
    try {
      return await _prefs.setString(StorageKeys.wallet, jsonEncode(wallet.toJson()));
    } catch (e) {
      debugPrint('Error saving wallet: $e');
      return false;
    }
  }

  // ==================== HOLDINGS ====================

  Map<String, Holding> loadHoldings() {
    try {
      final raw = _prefs.getString(StorageKeys.holdings);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final map = <String, Holding>{};
          for (final item in decoded) {
            try {
              final holding = Holding.fromJson(item as Map<String, dynamic>);
              if (holding.quantityUnits > 0) {
                map[holding.symbol] = holding;
              }
            } catch (_) {}
          }
          return map;
        }
      }
    } catch (e) {
      debugPrint('Error loading holdings from storage: $e');
    }
    return <String, Holding>{};
  }

  Future<bool> saveHoldings(Map<String, Holding> holdings) async {
    try {
      final list = holdings.values.where((h) => h.quantityUnits > 0).map((h) => h.toJson()).toList();
      return await _prefs.setString(StorageKeys.holdings, jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving holdings: $e');
      return false;
    }
  }

  // ==================== ORDERS ====================

  List<OrderModel> loadOrders() {
    try {
      final raw = _prefs.getString(StorageKeys.orders);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .map((item) {
                try {
                  return OrderModel.fromJson(item as Map<String, dynamic>);
                } catch (_) {
                  return null;
                }
              })
              .whereType<OrderModel>()
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }
    return [];
  }

  Future<bool> saveOrders(List<OrderModel> orders) async {
    try {
      final list = orders.map((o) => o.toJson()).toList();
      return await _prefs.setString(StorageKeys.orders, jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving orders: $e');
      return false;
    }
  }

  // ==================== AUTH PROFILE ====================

  UserProfile? loadAuthProfile() {
    try {
      final raw = _prefs.getString(StorageKeys.authProfile);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return UserProfile.fromJson(decoded);
        }
      }
    } catch (e) {
      debugPrint('Error loading auth profile: $e');
    }
    return null;
  }

  Future<bool> saveAuthProfile(UserProfile profile) async {
    try {
      return await _prefs.setString(
        StorageKeys.authProfile,
        jsonEncode(profile.toJson()),
      );
    } catch (e) {
      debugPrint('Error saving auth profile: $e');
      return false;
    }
  }

  Future<bool> clearAuthProfile() async {
    return await _prefs.remove(StorageKeys.authProfile);
  }
}
