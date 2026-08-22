import 'dart:async';
import 'dart:math';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/stock_constants.dart';
import '../domain/price_tick.dart';

class MockMarketFeed {
  final Random _random = Random();
  final StreamController<PriceTick> _tickController =
      StreamController<PriceTick>.broadcast();

  final Map<String, PriceTick> _latestTicks = {};
  Timer? _timer;
  int _ticksPerSecond = 5;
  bool _isStressMode = false;
  bool _isRunning = false;

  MockMarketFeed({int initialTickRate = 5}) : _ticksPerSecond = initialTickRate {
    _initStartingPrices();
  }

  void _initStartingPrices() {
    for (final stock in StockConstants.initialStocks) {
      final tick = PriceTick.initial(
        symbol: stock.symbol,
        startingPricePaise: stock.startingPricePaise,
        previousClosePaise: stock.previousClosePaise,
      );
      _latestTicks[stock.symbol] = tick;
    }
  }

  Stream<PriceTick> get tickStream => _tickController.stream;

  bool get isRunning => _isRunning;
  bool get isStressMode => _isStressMode;
  int get ticksPerSecond => _ticksPerSecond;

  Map<String, PriceTick> get allCurrentTicks => Map.unmodifiable(_latestTicks);

  PriceTick? getCurrentTick(String symbol) => _latestTicks[symbol];

  int getLtpPaise(String symbol) {
    final tick = _latestTicks[symbol];
    if (tick != null) return tick.ltpPaise;
    final stock = StockConstants.stockMap[symbol];
    return stock?.startingPricePaise ?? 10000;
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _scheduleTicks();
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  void setStressMode(bool enableStress) {
    if (_isStressMode == enableStress) return;
    _isStressMode = enableStress;
    if (_isRunning) {
      _timer?.cancel();
      _scheduleTicks();
    }
  }

  void setTickRate(int rate) {
    if (rate <= 0) return;
    _ticksPerSecond = rate;
    if (_isRunning && !_isStressMode) {
      _timer?.cancel();
      _scheduleTicks();
    }
  }

  int _calculateIntervalMs() {
    if (_isStressMode) {
      return AppConstants.stressTickIntervalMs;
    }
    switch (_ticksPerSecond) {
      case 1:
        return 1000;
      case 5:
        return 200;
      case 10:
        return 100;
      case 20:
        return 50;
      case 50:
        return 20;
      default:
        return (1000 / _ticksPerSecond).round().clamp(20, 2000);
    }
  }

  void _scheduleTicks() {
    final intervalMs = _calculateIntervalMs();

    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      _generateNextTick();
    });
  }

  void _generateNextTick() {
    if (StockConstants.symbols.isEmpty) return;

    // Pick a random stock from the universe to simulate a real market tick
    final randomIndex = _random.nextInt(StockConstants.symbols.length);
    final symbol = StockConstants.symbols[randomIndex];
    final currentTick = _latestTicks[symbol];
    if (currentTick == null) return;

    final currentLtp = currentTick.ltpPaise;
    final prevClose = currentTick.previousClosePaise;

    // Generate basis points move between -maxBasisPoints and +maxBasisPoints
    // E.g. -50 to +50 bps (0.50% move)
    final bps = (_random.nextInt(AppConstants.maxBasisPointsMovement * 2 + 1)) -
        AppConstants.maxBasisPointsMovement;

    // Convert bps to delta in paise (1 bps = 0.01% = 0.0001)
    var deltaPaise = (currentLtp * bps) ~/ 10000;

    // Ensure minimum move of at least 10 paise if non-zero
    if (deltaPaise == 0) {
      deltaPaise = _random.nextBool() ? 10 : -10;
    }

    var newLtp = currentLtp + deltaPaise;
    // Bound price so it never becomes zero or negative (min ₹10.00 = 1000 paise)
    if (newLtp < 1000) {
      newLtp = 1000;
    }

    final updatedTick = PriceTick.fromUpdate(
      symbol: symbol,
      newLtpPaise: newLtp,
      previousLtpPaise: currentLtp,
      previousClosePaise: prevClose,
    );

    _latestTicks[symbol] = updatedTick;

    if (!_tickController.isClosed) {
      _tickController.add(updatedTick);
    }
  }

  void dispose() {
    stop();
    _tickController.close();
  }
}
