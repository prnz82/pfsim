import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/stock_card.dart';
import '../widgets/shimmer_loading.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/hover_scale.dart';
import '../widgets/mini_sparkline.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data after the widget is mounted to ensure Shimmer is seen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortfolioProvider>().fetchPortfolio();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            _buildHeader(context, currencyFormat),
            
            // Stock List
            Expanded(
              child: Consumer<PortfolioProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const StockListShimmer();
                  }
                  
                  if (provider.stocks.isEmpty) {
                    return Center(
                      child: Text(
                        "No holdings found.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    itemCount: provider.stocks.length,
                    itemBuilder: (context, index) {
                      return StockCard(stock: provider.stocks[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NumberFormat currencyFormat) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Top Row: Title & Theme Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Portfolio Simulator",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Consumer<ThemeProvider>(
                builder: (context, theme, _) => IconButton(
                  icon: Icon(theme.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () => theme.toggleTheme(!theme.isDarkMode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Total Value Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Consumer<PortfolioProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                
                final totalValue = provider.totalPortfolioValue;
                final totalPnL = provider.totalPnL;
                final totalPnLPercent = provider.totalPnLPercent;
                final isProfit = totalPnL >= 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Valuation",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currencyFormat.format(totalValue),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Mini Graph for Header
                          MiniSparkline(
                            data: provider.portfolioHistory,
                            isProfit: isProfit,
                            width: 80,
                            height: 40,
                            color: Colors.white.withOpacity(0.8), // Neutral/Light color for header
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                                color: isProfit ? AppColors.profitGreen : const Color(0xFFFF8A80),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${currencyFormat.format(totalPnL.abs())}  (${totalPnLPercent.toStringAsFixed(2)}%)",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
