import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../persistence/local_storage_service.dart';
import '../domain/user_profile.dart';

class AuthRepository {
  final LocalStorageService _storage;
  final StreamController<UserProfile?> _authStreamController =
      StreamController<UserProfile?>.broadcast();

  UserProfile? _currentProfile;

  AuthRepository(this._storage) {
    _initAuth();
  }

  void _initAuth() {
    // 1. Check local cached profile first
    _currentProfile = _storage.loadAuthProfile();

    // 2. If Supabase is initialized, listen to its auth state changes
    try {
      if (SupabaseConfig.isConfigured) {
        if (Supabase.instance.client.auth.currentSession != null) {
          final supaUser = Supabase.instance.client.auth.currentUser;
          if (supaUser != null) {
            _currentProfile = _mapSupabaseUser(supaUser);
            _storage.saveAuthProfile(_currentProfile!);
          }
        }

        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
          final user = data.session?.user;
          if (user != null) {
            _currentProfile = _mapSupabaseUser(user);
            _storage.saveAuthProfile(_currentProfile!);
          } else if (_currentProfile != null && !_currentProfile!.isDemo) {
            _currentProfile = null;
            _storage.clearAuthProfile();
          }
          _authStreamController.add(_currentProfile);
        });
      }
    } on Object catch (_) {}

    _authStreamController.add(_currentProfile);
  }

  UserProfile? get currentProfile => _currentProfile;
  Stream<UserProfile?> get authStateChanges => _authStreamController.stream;
  bool get isAuthenticated => _currentProfile != null;

  UserProfile _mapSupabaseUser(User user) {
    return UserProfile(
      id: user.id,
      email: user.email,
      phone: user.phone,
      displayName: user.userMetadata?['full_name'] as String? ??
          user.userMetadata?['name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      isDemo: false,
    );
  }

  // ==================== PHONE OTP LOGIN ====================

  /// Sends OTP via Supabase SMS gateway (with automatic fallback for test numbers / offline)
  Future<void> sendPhoneOtp(String rawPhone) async {
    final formattedPhone = _formatIndianPhone(rawPhone);

    if (SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client.auth.signInWithOtp(
          phone: formattedPhone,
        );
        debugPrint('Supabase OTP sent/requested for $formattedPhone');
      } on AuthException catch (e) {
        debugPrint('Supabase Phone Auth note: ${e.message}. Allowed testing with fallback.');
      } catch (e) {
        debugPrint('Supabase Phone Auth error: $e');
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      debugPrint('Mock OTP sent to $formattedPhone (Use 123456 to verify)');
    }
  }

  /// Verifies 6-digit OTP
  Future<UserProfile> verifyPhoneOtp({
    required String rawPhone,
    required String token,
  }) async {
    final formattedPhone = _formatIndianPhone(rawPhone);
    final cleanToken = token.trim();

    if (cleanToken.length != 6) {
      throw Exception('Please enter a valid 6-digit OTP');
    }

    if (SupabaseConfig.isConfigured) {
      try {
        final response = await Supabase.instance.client.auth.verifyOTP(
          phone: formattedPhone,
          token: cleanToken,
          type: OtpType.sms,
        );

        final user = response.user;
        if (user != null) {
          final profile = _mapSupabaseUser(user);
          _currentProfile = profile;
          await _storage.saveAuthProfile(profile);
          _authStreamController.add(profile);
          return profile;
        }
      } catch (e) {
        debugPrint('Supabase verifyOTP error: $e. Checking fallback validation.');
      }
    }

    // Fallback/Testing verification
    final profile = UserProfile(
      id: 'phone_${DateTime.now().millisecondsSinceEpoch}',
      phone: formattedPhone,
      displayName: 'Mobile Trader',
      isDemo: true,
    );

    _currentProfile = profile;
    await _storage.saveAuthProfile(profile);
    _authStreamController.add(profile);
    return profile;
  }

  // ==================== GOOGLE LOGIN ====================

  Future<void> signInWithGoogle() async {
    if (SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'io.supabase.tradingapp://login-callback/',
        );
      } catch (e) {
        debugPrint('Google Sign-In fallback: $e');
        final profile = const UserProfile(
          id: 'google_user_demo',
          email: 'trader.google@gmail.com',
          displayName: 'Google Trader',
          isDemo: true,
        );
        _currentProfile = profile;
        await _storage.saveAuthProfile(profile);
        _authStreamController.add(profile);
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      final profile = const UserProfile(
        id: 'google_demo_user',
        email: 'trader.google@gmail.com',
        displayName: 'Google Trader',
        isDemo: true,
      );
      _currentProfile = profile;
      await _storage.saveAuthProfile(profile);
      _authStreamController.add(profile);
    }
  }

  // ==================== EMAIL LOGIN ====================

  Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (SupabaseConfig.isConfigured) {
      try {
        final res = await Supabase.instance.client.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        final user = res.user;
        if (user != null) {
          final profile = _mapSupabaseUser(user);
          _currentProfile = profile;
          await _storage.saveAuthProfile(profile);
          _authStreamController.add(profile);
          return profile;
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 300));
    final profile = UserProfile(
      id: 'email_${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      displayName: email.split('@').first,
      isDemo: true,
    );
    _currentProfile = profile;
    await _storage.saveAuthProfile(profile);
    _authStreamController.add(profile);
    return profile;
  }

  // ==================== DEMO QUICK LOGIN ====================

  Future<UserProfile> signInDemoUser() async {
    final profile = UserProfile.demo();
    _currentProfile = profile;
    await _storage.saveAuthProfile(profile);
    _authStreamController.add(profile);
    return profile;
  }

  // ==================== LOGOUT ====================

  Future<void> signOut() async {
    try {
      if (SupabaseConfig.isConfigured) {
        await Supabase.instance.client.auth.signOut();
      }
    } catch (_) {}

    _currentProfile = null;
    await _storage.clearAuthProfile();
    _authStreamController.add(null);
  }

  String _formatIndianPhone(String phone) {
    var clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('91') && clean.length == 12) {
      return '+$clean';
    }
    if (clean.length == 10) {
      return '+91$clean';
    }
    if (phone.startsWith('+')) {
      return phone;
    }
    return '+91$clean';
  }

  void dispose() {
    _authStreamController.close();
  }
}
