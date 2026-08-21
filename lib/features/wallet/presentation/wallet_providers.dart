import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../persistence/local_storage_service.dart';
import '../../market/presentation/market_providers.dart';
import '../domain/wallet_model.dart';

class WalletNotifier extends StateNotifier<WalletModel> {
  final LocalStorageService _storage;

  WalletNotifier(this._storage) : super(_storage.loadWallet());

  bool deduct(int paise) {
    if (paise <= 0) return false;
    if (state.balancePaise < paise) return false;

    state = state.copyWith(balancePaise: state.balancePaise - paise);
    _storage.saveWallet(state);
    return true;
  }

  void credit(int paise) {
    if (paise <= 0) return;
    state = state.copyWith(balancePaise: state.balancePaise + paise);
    _storage.saveWallet(state);
  }

  void reset() {
    state = WalletModel.initial();
    _storage.saveWallet(state);
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletModel>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return WalletNotifier(storage);
});

final walletBalancePaiseProvider = Provider<int>((ref) {
  return ref.watch(walletProvider).balancePaise;
});
