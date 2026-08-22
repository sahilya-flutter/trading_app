import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../market/presentation/market_providers.dart';
import '../data/auth_repository.dart';
import '../domain/user_profile.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  final repo = AuthRepository(storage);
  ref.onDispose(() => repo.dispose());
  return repo;
});

class AuthNotifier extends StateNotifier<UserProfile?> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(_repo.currentProfile) {
    _repo.authStateChanges.listen((profile) {
      state = profile;
    });
  }

  Future<void> signInMobile({
    required String mobile,
    required String password,
  }) async {
    final profile = await _repo.signInWithMobile(mobile: mobile, password: password);
    state = profile;
  }

  Future<void> signInGoogle() async {
    final profile = await _repo.signInWithGoogle();
    state = profile;
  }

  Future<void> signInDemo() async {
    final profile = await _repo.signInDemoUser();
    state = profile;
  }

  Future<void> updateProfileImage(String path) async {
    final profile = await _repo.updateCustomProfileImage(path);
    state = profile;
  }

  Future<void> removeCustomProfileImage() async {
    final profile = await _repo.removeCustomProfileImage();
    state = profile;
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = null;
  }
}

final authStateProvider =
    StateNotifierProvider<AuthNotifier, UserProfile?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

class AuthControllerState {
  final bool isLoading;
  final String? errorMessage;

  const AuthControllerState({
    this.isLoading = false,
    this.errorMessage,
  });

  AuthControllerState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthControllerState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends StateNotifier<AuthControllerState> {
  final AuthRepository _repo;
  final Ref _ref;

  AuthController(this._repo, this._ref) : super(const AuthControllerState());

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<bool> signInWithMobile({
    required String mobile,
    required String password,
  }) async {
    final clean = mobile.replaceAll(RegExp(r'\s+'), '');
    if (clean.length != 10) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Enter a valid 10-digit mobile number',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final profile = await _repo.signInWithMobile(mobile: clean, password: password);
      _ref.read(authStateProvider.notifier).state = profile;
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _repo.signInWithGoogle();
      state = state.copyWith(isLoading: false);
      if (profile == null) {
        return false;
      }
      _ref.read(authStateProvider.notifier).state = profile;
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      );
      return false;
    }
  }

  Future<bool> signInDemo() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _repo.signInDemoUser();
      _ref.read(authStateProvider.notifier).state = profile;
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateProfileImage(String path) async {
    try {
      final profile = await _repo.updateCustomProfileImage(path);
      if (profile != null) {
        _ref.read(authStateProvider.notifier).state = profile;
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update profile picture');
      return false;
    }
  }

  Future<bool> removeCustomProfileImage() async {
    try {
      final profile = await _repo.removeCustomProfileImage();
      _ref.read(authStateProvider.notifier).state = profile;
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to remove custom photo');
      return false;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    _ref.read(authStateProvider.notifier).state = null;
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthControllerState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo, ref);
});
