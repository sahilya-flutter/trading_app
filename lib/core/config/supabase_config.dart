class SupabaseConfig {
  SupabaseConfig._();

  /// User's active Supabase Project URL
  static const String supabaseUrl = 'https://zrhavcjiuzqupgecsfjk.supabase.co';

  /// User's active Supabase Anon / Publishable Key
  static const String supabaseAnonKey =
      'sb_publishable_fnbMW1xaa76O0oosjGoXMw_rA5qoDyx';

  /// Returns true if valid custom credentials have been configured
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
