import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'core/config/supabase_config.dart';
import 'features/market/presentation/market_providers.dart';
import 'persistence/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('dotenv loading notice (fallback active): $e');
  }

  // Initialize local persistence
  final storageService = await LocalStorageService.create();

  // Initialize Supabase client
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase init notice (running with demo fallback): $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storageService),
      ],
      child: const TradingApp(),
    ),
  );
}
