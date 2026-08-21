import '../../features/market/domain/stock.dart';

class StockConstants {
  StockConstants._();

  static const List<Stock> initialStocks = [
    Stock(
      symbol: 'RELIANCE',
      companyName: 'Reliance Industries Ltd.',
      startingPricePaise: 298745,
      previousClosePaise: 295325, // UP +34.20 (+1.16%)
    ),
    Stock(
      symbol: 'TCS',
      companyName: 'Tata Consultancy Services',
      startingPricePaise: 389210,
      previousClosePaise: 387960, // UP +12.50 (+0.32%)
    ),
    Stock(
      symbol: 'HDFCBANK',
      companyName: 'HDFC Bank Limited',
      startingPricePaise: 164385,
      previousClosePaise: 163495, // UP +8.90 (+0.54%)
    ),
    Stock(
      symbol: 'INFY',
      companyName: 'Infosys Limited',
      startingPricePaise: 145620,
      previousClosePaise: 147160, // DOWN -15.40 (-1.05%)
    ),
    Stock(
      symbol: 'SBIN',
      companyName: 'State Bank of India',
      startingPricePaise: 75430,
      previousClosePaise: 75740, // DOWN -3.10 (-0.41%)
    ),
    Stock(
      symbol: 'ITC',
      companyName: 'ITC Limited',
      startingPricePaise: 43215,
      previousClosePaise: 43395, // DOWN -1.80 (-0.41%)
    ),
    Stock(
      symbol: 'ICICIBANK',
      companyName: 'ICICI Bank Limited',
      startingPricePaise: 132000,
      previousClosePaise: 131800,
    ),
    Stock(
      symbol: 'LT',
      companyName: 'Larsen & Toubro Ltd.',
      startingPricePaise: 365000,
      previousClosePaise: 364000,
    ),
    Stock(
      symbol: 'BHARTIARTL',
      companyName: 'Bharti Airtel Limited',
      startingPricePaise: 182000,
      previousClosePaise: 181000,
    ),
    Stock(
      symbol: 'AXISBANK',
      companyName: 'Axis Bank Limited',
      startingPricePaise: 126000,
      previousClosePaise: 126800,
    ),
  ];

  static const List<String> symbols = [
    'RELIANCE',
    'TCS',
    'HDFCBANK',
    'INFY',
    'SBIN',
    'ITC',
    'ICICIBANK',
    'LT',
    'BHARTIARTL',
    'AXISBANK',
  ];

  static final Map<String, Stock> stockMap = {
    for (final s in initialStocks) s.symbol: s,
  };
}
