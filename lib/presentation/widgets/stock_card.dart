import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/stock.dart';
import '../../core/theme/app_colors.dart';
import '../screens/stock_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/portfolio_provider.dart';
import 'mini_sparkline.dart';

class StockCard extends StatefulWidget {
  final Stock stock;

  const StockCard({super.key, required this.stock});

  @override
  State<StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<StockCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final pnlColor = widget.stock.totalPnL >= 0 ? AppColors.profitGreen : AppColors.lossRed;
    final pnlIcon = widget.stock.totalPnL >= 0 ? Icons.arrow_upward : Icons.arrow_downward;
    
    final isStarred = context.select<PortfolioProvider, bool>(
      (p) => p.isStarred(widget.stock.symbol),
    );

    // Apply hover color blending
    final cardColor = Theme.of(context).cardColor;
    final hoverColor = Theme.of(context).hoverColor; // Typically a light overlay
    final effectiveColor = _isHovering 
        ? Color.alphaBlend(hoverColor, cardColor)
        : cardColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StockDetailScreen(stock: widget.stock),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: _isHovering ? Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)) : null,
          ),
          child: Row(
            children: [
              // Symbol Avatar (Network Image with fallback)
              Hero(
                tag: 'avatar_${widget.stock.symbol}',
                child: Container(
                  width: 48,
                  height: 48,
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
                                fontSize: 20,
                              ),
                            ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Stock Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'symbol_${widget.stock.symbol}',
                      child: Material(
                        color: Colors.transparent,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.stock.symbol,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isStarred) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                            ]
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${widget.stock.qty} shares",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              // Price & PnL
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MiniSparkline(
                        data: widget.stock.history['1M'] ?? [],
                        isProfit: widget.stock.changes.month >= 0,
                        width: 50,
                        height: 25,
                      ),
                      const SizedBox(width: 8),
                      // Display Total Value (Equity) to match Portfolio Total
                      Text(
                        currencyFormat.format(widget.stock.totalValue),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Text(
                        "@ ${currencyFormat.format(widget.stock.currentPrice)}",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: pnlColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(pnlIcon, size: 10, color: pnlColor),
                            const SizedBox(width: 2),
                            Builder(
                              builder: (context) {
                                // Calculate 1M change dynamically to match the mini-graph
                                final history1M = widget.stock.history['1M'] ?? [];
                                double percent = 0.0;
                                if (history1M.isNotEmpty && history1M.first != 0) {
                                  percent = ((history1M.last - history1M.first) / history1M.first) * 100;
                                }
                                return Text(
                                  "${percent.abs().toStringAsFixed(2)}% (1M)",
                                  style: TextStyle(
                                    color: pnlColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
