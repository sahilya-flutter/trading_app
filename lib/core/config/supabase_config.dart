import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  SupabaseConfig._();

  /// Loaded dynamically from .env with fallback
  static String get supabaseUrl {
    if (dotenv.isInitialized) {
      return dotenv.env['SUPABASE_URL'] ??
          'https://zrhavcjiuzqupgecsfjk.supabase.co';
    }
    return 'https://zrhavcjiuzqupgecsfjk.supabase.co';
  }

  /// Loaded dynamically from .env with fallback
  static String get supabaseAnonKey {
    if (dotenv.isInitialized) {
      return dotenv.env['SUPABASE_ANON_KEY'] ??
          'sb_publishable_fnbMW1xaa76O0oosjGoXMw_rA5qoDyx';
    }
    return 'sb_publishable_fnbMW1xaa76O0oosjGoXMw_rA5qoDyx';
  }

  /// Returns true if valid credentials have been configured
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
