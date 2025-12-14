import 'dart:math';
import '../models/stock.dart';

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockService {
  Future<List<Stock>> getHoldings() async {
    final prefs = await SharedPreferences.getInstance();
    const String cacheKey = 'portfolio_cache';

    // 1. Try to read from cache
    final String? cachedJson = prefs.getString(cacheKey);
    if (cachedJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        final stocks = decoded.map((json) => Stock.fromJson(json)).toList();
        debugPrint("💰 CACHE HIT: Loaded ${stocks.length} stocks from local storage.");
        return stocks;
      } catch (e) {
        debugPrint("⚠️ CACHE ERROR: $e");
      }
    } else {
        debugPrint("⚠️ CACHE MISS: No local data found.");
    }

    // 2. Simulate Network & Fetch
    debugPrint("🌐 NETWORK FETCH: Simulating 1s delay...");
    await Future.delayed(const Duration(seconds: 1)); // Fake network delay
    final freshData = _mockData;

    // 3. Save to cache
    try {
      final String jsonString = jsonEncode(freshData.map((e) => e.toJson()).toList());
      await prefs.setString(cacheKey, jsonString);
      debugPrint("💾 CACHE SAVED: Persisted data to local storage.");
    } catch (e) {
      debugPrint("❌ CACHE WRITE ERROR: $e");
    }

    return freshData;
  }

  // Generate history WALKING BACKWARDS from current price to ensure consistency
  static List<double> _generateHistoryBackwards(double currentPrice, int points, {double volatility = 0.02}) {
    final random = Random();
    List<double> prices = List.filled(points, 0.0);
    prices[points - 1] = currentPrice;

    double current = currentPrice;
    for (int i = points - 2; i >= 0; i--) {
      // Inverse change to walk back
      double change = current * volatility * (random.nextDouble() - 0.45); 
      current -= change; 
      prices[i] = current;
    }
    return prices;
  }

  // Calculate change % based on history
  static double _calculateChange(List<double> history) {
    if (history.isEmpty) return 0.0;
    final start = history.first;
    final end = history.last;
    return ((end - start) / start) * 100;
  }

  static List<Stock> get _mockData {
    // We define current price first, then generate history
    const double tcsPrice = 3500;
    const double infyPrice = 1500;
    const double hdfcPrice = 1550;

    final tcsHistory = {
        '1D': _generateHistoryBackwards(tcsPrice, 24, volatility: 0.002),
        '1W': _generateHistoryBackwards(tcsPrice, 7, volatility: 0.01),
        '1M': _generateHistoryBackwards(tcsPrice, 30, volatility: 0.015),
        '1Y': _generateHistoryBackwards(tcsPrice, 52, volatility: 0.02),
        'All': _generateHistoryBackwards(tcsPrice, 100, volatility: 0.03),
    };

    final infyHistory = {
        '1D': _generateHistoryBackwards(infyPrice, 24, volatility: 0.002),
        '1W': _generateHistoryBackwards(infyPrice, 7, volatility: 0.01),
        '1M': _generateHistoryBackwards(infyPrice, 30, volatility: 0.015),
        '1Y': _generateHistoryBackwards(infyPrice, 52, volatility: 0.02),
        'All': _generateHistoryBackwards(infyPrice, 100, volatility: 0.03),
    };

    final hdfcHistory = {
        '1D': _generateHistoryBackwards(hdfcPrice, 24, volatility: 0.002),
        '1W': _generateHistoryBackwards(hdfcPrice, 7, volatility: 0.01),
        '1M': _generateHistoryBackwards(hdfcPrice, 30, volatility: 0.015),
        '1Y': _generateHistoryBackwards(hdfcPrice, 52, volatility: 0.02),
        'All': _generateHistoryBackwards(hdfcPrice, 100, volatility: 0.03),
    };

    return [
      Stock(
        symbol: "TCS",
        companyName: "Tata Consultancy Services",
        logoUrl: "",
        qty: 5,
        avgPrice: 3200,
        currentPrice: tcsPrice,
        changes: StockChanges(
          day: _calculateChange(tcsHistory['1D']!),
          week: _calculateChange(tcsHistory['1W']!),
          month: _calculateChange(tcsHistory['1M']!),
        ),
        history: tcsHistory,
        insight: "TCS has shown consistent upward movement this month due to strong quarterly results.",
      ),
      Stock(
        symbol: "INFY",
        companyName: "Infosys Limited",
        logoUrl: "",
        qty: 10,
        avgPrice: 1400,
        currentPrice: infyPrice,
        changes: StockChanges(
          day: _calculateChange(infyHistory['1D']!),
          week: _calculateChange(infyHistory['1W']!),
          month: _calculateChange(infyHistory['1M']!),
        ),
        history: infyHistory,
        insight: "Infosys is consolidating near all-time highs with positive sector outlook.",
      ),
      Stock(
        symbol: "HDFCBANK",
        companyName: "HDFC Bank",
        logoUrl: "",
        qty: 7,
        avgPrice: 1500,
        currentPrice: hdfcPrice,
        changes: StockChanges(
          day: _calculateChange(hdfcHistory['1D']!),
          week: _calculateChange(hdfcHistory['1W']!),
          month: _calculateChange(hdfcHistory['1M']!),
        ),
        history: hdfcHistory,
        insight: "HDFC Bank remains a defensive pick with steady growth despite market volatility.",
      ),
    ];
  }
}
