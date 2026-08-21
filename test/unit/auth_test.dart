import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/core/config/supabase_config.dart';
import 'package:trading_app/features/auth/data/auth_repository.dart';
import 'package:trading_app/features/auth/domain/user_profile.dart';
import 'package:trading_app/persistence/local_storage_service.dart';

void main() {
  group('Auth Tests', () {
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
      await authRepo.signInDemoUser();
      expect(authRepo.isAuthenticated, isTrue);

      await authRepo.signOut();
      expect(authRepo.isAuthenticated, isFalse);
      expect(authRepo.currentProfile, isNull);

      final newRepo = AuthRepository(storage);
      expect(newRepo.isAuthenticated, isFalse);
      newRepo.dispose();
    });

    test('UserProfile formats displayTitle and initials properly', () {
      const u1 = UserProfile(id: '1', displayName: 'Sahil Patil');
      expect(u1.displayTitle, 'Sahil Patil');
      expect(u1.initials, 'SP');

      const u2 = UserProfile(id: '2', email: 'trader@gmail.com');
      expect(u2.displayTitle, 'trader@gmail.com');
      expect(u2.initials, 'T');

      const u3 = UserProfile(id: '3', phone: '+919876543210');
      expect(u3.displayTitle, '+919876543210');
      expect(u3.initials, '+');
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
