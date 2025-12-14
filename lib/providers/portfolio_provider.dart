import 'package:flutter/material.dart';
import '../data/models/stock.dart';
import '../data/services/stock_service.dart';

class PortfolioProvider extends ChangeNotifier {
  final StockService _stockService = StockService();
  
  List<Stock> _stocks = [];
  bool _isLoading = true; // Start loading by default to prevent "No Data" flash
  final Set<String> _starredSymbols = {};

  List<Stock> get stocks => _stocks;
  bool get isLoading => _isLoading;
  Set<String> get starredSymbols => _starredSymbols;

  double get totalPortfolioValue {
    if (_stocks.isEmpty) return 0;
    return _stocks.fold(0, (sum, item) => sum + item.totalValue);
  }

  double get totalPnL {
    if (_stocks.isEmpty) return 0;
    return _stocks.fold(0, (sum, item) => sum + item.totalPnL);
  }

  double get totalPnLPercent {
     double totalCost = _stocks.fold(0, (sum, item) => sum + (item.avgPrice * item.qty));
     if (totalCost == 0) return 0;
     return (totalPnL / totalCost) * 100;
  }

  void toggleStar(String symbol) {
    if (_starredSymbols.contains(symbol)) {
      _starredSymbols.remove(symbol);
    } else {
      _starredSymbols.add(symbol);
    }
    notifyListeners();
  }

  bool isStarred(String symbol) => _starredSymbols.contains(symbol);
  
  // Aggregate history for the 'All' timeframe to show in the header
  List<double> get portfolioHistory {
    if (_stocks.isEmpty) return [];
    
    // Assuming all stocks have 'All' history of same length (simplification)
    // If lengths simulated differ, we take the min length or normalize.
    // For this mock, they are consistent.
    final firstHistory = _stocks.first.history['All'] ?? [];
    if (firstHistory.isEmpty) return [];
    
    int length = firstHistory.length;
    List<double> aggregated = List.filled(length, 0.0);
    
    for (int i = 0; i < length; i++) {
        double sumAtPoint = 0;
        for (var stock in _stocks) {
           final hist = stock.history['All'] ?? [];
           if (i < hist.length) {
              sumAtPoint += (hist[i] * stock.qty);
           }
        }
        aggregated[i] = sumAtPoint;
    }
    return aggregated;
  }

  Future<void> fetchPortfolio() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stocks = await _stockService.getHoldings();
    } catch (e) {
      debugPrint("Error fetching stocks: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
