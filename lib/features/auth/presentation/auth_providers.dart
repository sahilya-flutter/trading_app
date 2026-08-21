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
  final String? otpSentToPhone;

  const AuthControllerState({
    this.isLoading = false,
    this.errorMessage,
    this.otpSentToPhone,
  });

  AuthControllerState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? otpSentToPhone,
    bool clearError = false,
    bool clearPhone = false,
  }) {
    return AuthControllerState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      otpSentToPhone: clearPhone ? null : (otpSentToPhone ?? this.otpSentToPhone),
    );
  }
}

class AuthController extends StateNotifier<AuthControllerState> {
  final AuthRepository _repo;

  AuthController(this._repo) : super(const AuthControllerState());

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<bool> sendPhoneOtp(String phone) async {
    final clean = phone.trim();
    if (clean.isEmpty || clean.length < 10) {
      state = state.copyWith(errorMessage: 'Please enter a valid 10-digit mobile number');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.sendPhoneOtp(clean);
      state = state.copyWith(isLoading: false, otpSentToPhone: clean);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      );
      return false;
    }
  }

  Future<bool> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    if (token.trim().length != 6) {
      state = state.copyWith(errorMessage: 'Please enter a 6-digit OTP code');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.verifyPhoneOtp(rawPhone: phone, token: token);
      state = state.copyWith(isLoading: false, clearPhone: true);
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
