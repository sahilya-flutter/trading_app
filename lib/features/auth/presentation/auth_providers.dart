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

  Future<void> signInDemo() async {
    await _repo.signInDemoUser();
  }

  Future<void> signOut() async {
    await _repo.signOut();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, UserProfile?>((ref) {
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

  AuthController(this._repo) : super(const AuthControllerState());

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.signInWithGoogle();
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

  Future<bool> signInDemo() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.signInDemoUser();
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

  Future<void> signOut() async {
    await _repo.signOut();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthControllerState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});
