class SupabaseConfig {
  SupabaseConfig._();

  /// Replace with your Supabase Project URL from https://supabase.com/dashboard/project/_/settings/api
  static const String supabaseUrl = 'https://demo-trading-app.supabase.co';

  /// Replace with your Supabase Anon Public Key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRlbW8tdHJhZGluZy1hcHAiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYyODc2NzYwMCwiZXhwIjoxOTQ0MzQzNjAwfQ.demo-key-signature';

  /// Returns true if valid custom credentials have been configured
  static bool get isConfigured =>
      supabaseUrl != 'https://demo-trading-app.supabase.co' &&
      supabaseAnonKey.isNotEmpty;
}
