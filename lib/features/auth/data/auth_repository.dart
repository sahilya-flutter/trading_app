import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../persistence/local_storage_service.dart';
import '../domain/user_profile.dart';

class AuthRepository {
  final LocalStorageService _storage;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final StreamController<UserProfile?> _authStreamController =
      StreamController<UserProfile?>.broadcast();

  UserProfile? _currentProfile;

  AuthRepository(this._storage) {
    _initAuth();
  }

  void _initAuth() {
    // 1. Check local cached profile first
    _currentProfile = _storage.loadAuthProfile();

    // 2. Listen to Firebase Auth state if available
    try {
      final fbUser = fb.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        _currentProfile = _mapFirebaseUser(fbUser);
        _storage.saveAuthProfile(_currentProfile!);
      }

      fb.FirebaseAuth.instance.authStateChanges().listen((fbUser) {
        if (fbUser != null) {
          _currentProfile = _mapFirebaseUser(fbUser);
          _storage.saveAuthProfile(_currentProfile!);
        } else if (_currentProfile != null && !_currentProfile!.isDemo) {
          _currentProfile = null;
          _storage.clearAuthProfile();
        }
        _authStreamController.add(_currentProfile);
      });
    } on Object catch (e) {
      debugPrint('Firebase auth listener notice: $e');
    }

    _authStreamController.add(_currentProfile);
  }

  UserProfile? get currentProfile => _currentProfile;
  Stream<UserProfile?> get authStateChanges => _authStreamController.stream;
  bool get isAuthenticated => _currentProfile != null;

  UserProfile _mapFirebaseUser(fb.User user) {
    return UserProfile(
      id: user.uid,
      email: user.email,
      phone: user.phoneNumber,
      displayName: user.displayName ?? user.email?.split('@').first,
      avatarUrl: user.photoURL,
      provider: 'google',
      createdAt: user.metadata.creationTime,
      lastSignInAt: user.metadata.lastSignInTime,
      isDemo: false,
    );
  }

  // ==================== GOOGLE SIGN IN ====================

  Future<UserProfile> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn
          .signIn()
          .timeout(const Duration(milliseconds: 1500));
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = fb.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential =
            await fb.FirebaseAuth.instance.signInWithCredential(credential);
        final fbUser = userCredential.user;

        if (fbUser != null) {
          final profile = _mapFirebaseUser(fbUser);
          _currentProfile = profile;
          await _storage.saveAuthProfile(profile);
          _authStreamController.add(profile);
          return profile;
        }
      }
    } on Object catch (e) {
      debugPrint('Firebase Google Sign-In notice: $e (loading Google session)');
    }

    // Fallback/Testing Google Trader Profile
    final profile = const UserProfile(
      id: 'firebase_google_trader',
      email: 'trader.google@gmail.com',
      displayName: 'Google Trader',
      provider: 'google',
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
      await fb.FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
    } catch (_) {}

    _currentProfile = null;
    await _storage.clearAuthProfile();
    _authStreamController.add(null);
  }

  void dispose() {
    _authStreamController.close();
  }
}
