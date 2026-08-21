import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/core/config/supabase_config.dart';
import 'package:trading_app/features/auth/data/auth_repository.dart';
import 'package:trading_app/features/auth/domain/user_profile.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  group('Auth & Gmail / Google Login Tests', () {
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
      await authRepo.signInWithGoogle();
      expect(authRepo.isAuthenticated, isTrue);

      await authRepo.signOut();
      expect(authRepo.isAuthenticated, isFalse);
      expect(authRepo.currentProfile, isNull);

      final newRepo = AuthRepository(storage);
      expect(newRepo.isAuthenticated, isFalse);
      newRepo.dispose();
    });

    test('UserProfile formats Google displayTitle and initials properly', () {
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

      const emailOnlyUser = UserProfile(
        id: 'google_456',
        email: 'trader.pro@gmail.com',
        provider: 'google',
      );
      expect(emailOnlyUser.displayTitle, 'trader.pro@gmail.com');
      expect(emailOnlyUser.initials, 'T');
      expect(emailOnlyUser.isGoogle, isTrue);
    });

    test('SupabaseConfig loads environment variables from dotenv accurately', () {
      dotenv.testLoad(fileInput: '''
SUPABASE_URL=https://custom-test.supabase.co
SUPABASE_ANON_KEY=test_anon_key_12345
''');

      expect(SupabaseConfig.supabaseUrl, 'https://custom-test.supabase.co');
      expect(SupabaseConfig.supabaseAnonKey, 'test_anon_key_12345');
      expect(SupabaseConfig.isConfigured, isTrue);
    });
  });
}
