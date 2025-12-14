import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PriceChart extends StatelessWidget {
  final List<double> prices;
  final bool isProfit;

  const PriceChart({
    super.key,
    required this.prices,
    required this.isProfit,
  });

  @override
  Widget build(BuildContext context) {
    if (prices.isEmpty) return const SizedBox.shrink();

    final color = isProfit ? Colors.green : Colors.red;
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    
    // Smooth the chart data
    final spots = prices.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxPrice - minPrice) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.1),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: (prices.length / 5).floorToDouble(), // Show ~5 labels
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= prices.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _getDateLabel(value.toInt()),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (prices.length - 1).toDouble(),
        minY: minPrice * 0.99, // Add some padding
        maxY: maxPrice * 1.01,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
           enabled: true,
           touchSpotThreshold: 50, // Increase threshold
           handleBuiltInTouches: true,
           touchTooltipData: LineTouchTooltipData(
             tooltipBgColor: Colors.black87,
             getTooltipItems: (touchedSpots) {
               return touchedSpots.map((LineBarSpot touchedSpot) {
                 return LineTooltipItem(
                   '${touchedSpot.y.toStringAsFixed(2)}\n',
                   const TextStyle(
                     color: Colors.white,
                     fontWeight: FontWeight.bold,
                   ),
                   children: [
                     TextSpan(
                       text: _getDateLabel(touchedSpot.x.toInt()),
                       style: const TextStyle(
                         color: Colors.white70,
                         fontWeight: FontWeight.normal,
                         fontSize: 10,
                       ),
                     ),
                   ],
                 );
               }).toList();
             },
           )
        ),
      ),
    );
  }

  // Helper to generate dynamic date label based on index (assuming reverse chronological or timeframe based)
  // For simplicity in this simulation, we map index to a date relative to "Now"
  String _getDateLabel(int index) {
     // Assumption: prices are provided in chronological order (oldest -> newest)
     // Length of prices depends on timeframe.
     // Recent price (last index) is "Now".
     
     final totalPoints = prices.length;
     final stepsBack = totalPoints - 1 - index;
     final now = DateTime.now();
     
     // Determine step size based on total points to guess timeframe
     // 1D (24 pts) -> 1 hour steps
     // 1W (7 pts) -> 1 day steps
     // 1M (30 pts) -> 1 day steps
     // 1Y (52 pts) -> 1 week steps
     
     Duration step;
     // 1W has 7 points (< 10)
     if (totalPoints <= 10) { 
       step = const Duration(days: 1);
     } 
     // 1D has 24 points (approx 24-25)
     else if (totalPoints <= 25) { 
       step = const Duration(hours: 1);
     } 
     // 1M has 30 points
     else if (totalPoints <= 31) { 
       step = const Duration(days: 1);
     } else { // 1Y or All
       step = const Duration(days: 7);
     }
     
     final date = now.subtract(step * stepsBack);
     
     // 1D shows Time, others show Date
     if (totalPoints > 10 && totalPoints <= 25) { 
       return "${date.hour}:00";
     } else { 
       return "${date.day}/${date.month}";
     }
  }
}
