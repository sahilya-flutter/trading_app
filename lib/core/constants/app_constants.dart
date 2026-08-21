class AppConstants {
  AppConstants._();

  static const String appName = '021 Trading App';

  // Money & Quantity Precision
  // 1 Rupee = 100 Paise
  static const int paisePerRupee = 100;

  // 1 Share quantity unit = 1000 minor units (allows up to 3 decimal places: 1.250 shares = 1250 units)
  static const int quantityMultiplier = 1000;
  static const int maxQuantityDecimalPlaces = 3;

  // Initial simulated cash balance: ₹1,00,000.00 (10,000,000 paise)
  static const int initialWalletBalancePaise = 100000 * paisePerRupee;

  // Feed settings
  static const int defaultTickIntervalMs = 800; // Normal rate (~1.25 ticks/sec)
  static const int stressTickIntervalMs = 20;   // Stress rate (~50 ticks/sec total)

  // Max basis-point price movement per tick (+/- 50 bps = 0.50%)
  static const int maxBasisPointsMovement = 50;

  // Default watchlist ID & Name
  static const String defaultWatchlistId = 'default_watchlist';
  static const String defaultWatchlistName = 'My Watchlist';
  static const List<String> defaultWatchlistSymbols = [
    'RELIANCE',
    'TCS',
    'HDFCBANK',
    'INFY',
    'SBIN',
    'ITC',
  ];
}
