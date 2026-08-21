import '../../features/market/domain/stock.dart';

class StockConstants {
  StockConstants._();

  static const List<Stock> initialStocks = [
    Stock(
      symbol: 'RELIANCE',
      companyName: 'Reliance Industries Ltd.',
      startingPricePaise: 142000,
      previousClosePaise: 141500,
    ),
    Stock(
      symbol: 'TCS',
      companyName: 'Tata Consultancy Services',
      startingPricePaise: 398000,
      previousClosePaise: 399500,
    ),
    Stock(
      symbol: 'INFY',
      companyName: 'Infosys Limited',
      startingPricePaise: 172000,
      previousClosePaise: 171200,
    ),
    Stock(
      symbol: 'HDFCBANK',
      companyName: 'HDFC Bank Limited',
      startingPricePaise: 176000,
      previousClosePaise: 175400,
    ),
    Stock(
      symbol: 'ICICIBANK',
      companyName: 'ICICI Bank Limited',
      startingPricePaise: 132000,
      previousClosePaise: 131800,
    ),
    Stock(
      symbol: 'SBIN',
      companyName: 'State Bank of India',
      startingPricePaise: 82000,
      previousClosePaise: 82500,
    ),
    Stock(
      symbol: 'ITC',
      companyName: 'ITC Limited',
      startingPricePaise: 47000,
      previousClosePaise: 46800,
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
    'INFY',
    'HDFCBANK',
    'ICICIBANK',
    'SBIN',
    'ITC',
    'LT',
    'BHARTIARTL',
    'AXISBANK',
  ];

  static final Map<String, Stock> stockMap = {
    for (final s in initialStocks) s.symbol: s,
  };
}
