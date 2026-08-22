import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/features/auth/data/auth_repository.dart';
import 'package:trading_app/features/auth/domain/user_profile.dart';
import 'package:trading_app/firebase_options.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth & 021 Trade Login Tests', () {
    late LocalStorageService storage;
    late AuthRepository authRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService.create();
      authRepo = AuthRepository(storage);
    });

    tearDown(() {
      authRepo.dispose();
    });

    test('Initial state is unauthenticated when no session exists', () {
      expect(authRepo.isAuthenticated, isFalse);
      expect(authRepo.currentProfile, isNull);
    });

    test('Mobile Sign In creates authenticated trader profile and persists', () async {
      final user = await authRepo.signInWithMobile(
        mobile: '9876543210',
        password: 'password',
      );

      expect(authRepo.isAuthenticated, isTrue);
      expect(user.phone, '+91 9876543210');
      expect(user.displayName, contains('9876543210'));

      final restoredRepo = AuthRepository(storage);
      expect(restoredRepo.isAuthenticated, isTrue);
      expect(restoredRepo.currentProfile?.phone, '+91 9876543210');
      restoredRepo.dispose();
    });

    test('Google Sign In creates authenticated Gmail profile with credentials', () async {
      await authRepo.signInWithGoogle();

      expect(authRepo.isAuthenticated, isTrue);
      final profile = authRepo.currentProfile;
      expect(profile, isNotNull);
      expect(profile!.email, contains('gmail.com'));
      expect(profile.isGoogle, isTrue);
      expect(profile.displayTitle, isNotEmpty);

      // Verify persistence
      final restoredRepo = AuthRepository(storage);
      expect(restoredRepo.isAuthenticated, isTrue);
      expect(restoredRepo.currentProfile?.isGoogle, isTrue);
      restoredRepo.dispose();
    });

    test('Demo sign in creates user profile and persists across repository recreation', () async {
      final user = await authRepo.signInDemoUser();

      expect(user.isDemo, isTrue);
      expect(user.displayName, 'Demo Trader');
      expect(authRepo.isAuthenticated, isTrue);

      // Recreate repository from storage to test persistence
      final newRepo = AuthRepository(storage);
      expect(newRepo.isAuthenticated, isTrue);
      expect(newRepo.currentProfile?.displayName, 'Demo Trader');
      newRepo.dispose();
    });

    test('Sign out clears user session and local storage', () async {
      await authRepo.signInWithMobile(mobile: '9876543210', password: 'password');
      expect(authRepo.isAuthenticated, isTrue);

      await authRepo.signOut();
      expect(authRepo.isAuthenticated, isFalse);
      expect(authRepo.currentProfile, isNull);

      final newRepo = AuthRepository(storage);
      expect(newRepo.isAuthenticated, isFalse);
      newRepo.dispose();
    });

    test('UserProfile formats displayTitle and initials properly', () {
      const googleUser = UserProfile(
        id: 'google_123',
        displayName: 'Sahil Patil',
        email: 'sahil.patil@gmail.com',
        provider: 'google',
        avatarUrl: 'https://lh3.googleusercontent.com/a/sample',
      );

      expect(googleUser.displayTitle, 'Sahil Patil');
      expect(googleUser.initials, 'SP');
      expect(googleUser.isGoogle, isTrue);
      expect(googleUser.formattedJoinedDate, isNotEmpty);

      const mobileUser = UserProfile(
        id: 'trader_9876543210',
        phone: '+91 9876543210',
        provider: 'mobile',
      );
      expect(mobileUser.displayTitle, '+91 9876543210');
      expect(mobileUser.initials, '+9');
    });

    test('DefaultFirebaseOptions provides platform-specific options', () {
      final androidOptions = DefaultFirebaseOptions.android;
      expect(androidOptions.apiKey, isNotEmpty);
      expect(androidOptions.appId, isNotEmpty);
      expect(androidOptions.projectId, isNotEmpty);

      final webOptions = DefaultFirebaseOptions.web;
      expect(webOptions.apiKey, isNotEmpty);
      expect(webOptions.projectId, isNotEmpty);
    });
  });
}
