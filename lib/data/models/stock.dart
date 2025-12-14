class Stock {
  final String symbol;
  final String companyName;
  final String logoUrl;
  final int qty;
  final double avgPrice;
  final double currentPrice;
  final StockChanges changes;
  // Instead of single list, we store a map of timeframe -> prices
  final Map<String, List<double>> history; 
  final String insight;

  Stock({
    required this.symbol,
    required this.companyName,
    required this.logoUrl,
    required this.qty,
    required this.avgPrice,
    required this.currentPrice,
    required this.changes,
    required this.history,
    required this.insight,
  });

  // Helper to get prices for a key, default to 1M or empty
  List<double> getPriceHistory(String timeframe) {
    return history[timeframe] ?? history['1M'] ?? [];
  }

  double get pnlPercent {
    if (avgPrice == 0) return 0;
    return ((currentPrice - avgPrice) / avgPrice) * 100;
  }

  double get totalValue => qty * currentPrice;

  double get totalPnL => (currentPrice - avgPrice) * qty;

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'] ?? '',
      companyName: json['companyName'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      qty: json['qty'] ?? 0,
      avgPrice: (json['avgPrice'] ?? 0).toDouble(),
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      changes: StockChanges.fromJson(json['changes'] ?? {}),
      history: (json['history'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              (value as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
            ),
          ) ??
          {},
      insight: json['insight'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'companyName': companyName,
      'logoUrl': logoUrl,
      'qty': qty,
      'avgPrice': avgPrice,
      'currentPrice': currentPrice,
      'changes': changes.toJson(),
      'history': history,
      'insight': insight,
    };
  }
}

class StockChanges {
  final double day;
  final double week;
  final double month;

  StockChanges({
    required this.day,
    required this.week,
    required this.month,
  });

  factory StockChanges.fromJson(Map<String, dynamic> json) {
    return StockChanges(
      day: (json['day'] ?? 0).toDouble(),
      week: (json['week'] ?? 0).toDouble(),
      month: (json['month'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'week': week,
      'month': month,
    };
  }
}
