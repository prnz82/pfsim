import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/models/stock.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/price_chart.dart';
import '../../providers/portfolio_provider.dart'; 
import 'package:intl/intl.dart';

class StockDetailScreen extends StatefulWidget {
  final Stock stock;

  const StockDetailScreen({super.key, required this.stock});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  String _selectedTimeframe = '1M';
  
  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    
    // Get prices for selected timeframe
    final prices = widget.stock.getPriceHistory(_selectedTimeframe);
    
    // Calculate profit dynamically for the selected range
    double dynamicPercent = widget.stock.pnlPercent; // Default to Total PnL if empty
    if (prices.isNotEmpty) {
      final start = prices.first;
      final end = prices.last;
      if (start != 0) {
        dynamicPercent = ((end - start) / start) * 100;
      }
    }
    
    final isProfit = dynamicPercent >= 0;
    final color = isProfit ? AppColors.profitGreen : AppColors.lossRed;
    final icon = isProfit ? Icons.arrow_upward : Icons.arrow_downward;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          Consumer<PortfolioProvider>(
            builder: (context, provider, _) {
              final isStarred = provider.isStarred(widget.stock.symbol);
              return IconButton(
                icon: Icon(isStarred ? Icons.star : Icons.star_border),
                color: isStarred ? Colors.amber : null,
                onPressed: () {
                   provider.toggleStar(widget.stock.symbol);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final text = "Check out ${widget.stock.companyName} at ${currencyFormat.format(widget.stock.currentPrice)} on Portfolio Simulator!";
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Stock info copied to clipboard! (Simulation)")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Hero(
                tag: 'avatar_${widget.stock.symbol}',
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      widget.stock.logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            alignment: Alignment.center,
                            child: Text(
                              widget.stock.symbol[0],
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                          );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Hero(
                tag: 'symbol_${widget.stock.symbol}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    widget.stock.symbol,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                widget.stock.companyName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Price Big
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  currencyFormat.format(widget.stock.currentPrice),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20, color: color),
                    const SizedBox(width: 4),
                    Text(
                      "${dynamicPercent.abs().toStringAsFixed(2)}%",
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Chart
            SizedBox(
              height: 250,
              width: double.infinity,
              child: PriceChart(
                prices: prices,
                isProfit: isProfit,
              ),
            ),
            
            // Timeframe Selector
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["1D", "1W", "1M", "1Y", "All"].map((e) {
                return _TimeframeSelector(
                  label: e,
                  isSelected: e == _selectedTimeframe,
                  onTap: () {
                     setState(() {
                      _selectedTimeframe = e;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Statistics Grid
            Text(
              "Performance",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard(context, "1 Day", "${widget.stock.changes.day.toStringAsFixed(2)}%", widget.stock.changes.day >= 0)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, "1 Week", "${widget.stock.changes.week.toStringAsFixed(2)}%", widget.stock.changes.week >= 0)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, "1 Month", "${widget.stock.changes.month.toStringAsFixed(2)}%", widget.stock.changes.month >= 0)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Holdings Info
             Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                   _buildRow(context, "Quantity", "${widget.stock.qty}"),
                  const Divider(height: 24),
                  _buildRow(context, "Avg. Price", currencyFormat.format(widget.stock.avgPrice)),
                   const Divider(height: 24),
                  _buildRow(context, "Invested Value", currencyFormat.format(widget.stock.avgPrice * widget.stock.qty)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // AI Insight
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade900,
                    Colors.deepPurple.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "AI Insight",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.stock.insight,
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.5,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, bool isPositive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: isPositive ? AppColors.profitGreen : AppColors.lossRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.lightTextSecondary)),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _TimeframeSelector extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeframeSelector({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TimeframeSelector> createState() => _TimeframeSelectorState();
}

class _TimeframeSelectorState extends State<_TimeframeSelector> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? Theme.of(context).primaryColor 
                : (_isHovering ? Colors.grey.withOpacity(0.1) : Colors.transparent),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected 
                  ? Colors.white 
                  : (_isHovering ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).textTheme.bodySmall?.color),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
