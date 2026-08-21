import '../../features/market/domain/stock.dart';

class StockConstants {
  StockConstants._();

  static const List<Stock> initialStocks = [
    Stock(
      symbol: 'RELIANCE',
      companyName: 'Reliance Industries Ltd.',
      startingPricePaise: 142000,
      previousClosePaise: 141500, // UP (Green)
    ),
    Stock(
      symbol: 'TCS',
      companyName: 'Tata Consultancy Services',
      startingPricePaise: 398000,
      previousClosePaise: 396500, // UP (Green)
    ),
    Stock(
      symbol: 'HDFCBANK',
      companyName: 'HDFC Bank Limited',
      startingPricePaise: 176000,
      previousClosePaise: 175400, // UP (Green)
    ),
    Stock(
      symbol: 'INFY',
      companyName: 'Infosys Limited',
      startingPricePaise: 171200,
      previousClosePaise: 172000, // DOWN (Red)
    ),
    Stock(
      symbol: 'SBIN',
      companyName: 'State Bank of India',
      startingPricePaise: 82000,
      previousClosePaise: 82500, // DOWN (Red)
    ),
    Stock(
      symbol: 'ITC',
      companyName: 'ITC Limited',
      startingPricePaise: 46800,
      previousClosePaise: 47000, // DOWN (Red)
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
