import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MiniSparkline extends StatelessWidget {
  final List<double> data;
  final bool isProfit;
  final double height;
  final double width;
  final Color? color;

  const MiniSparkline({
    super.key,
    required this.data,
    required this.isProfit,
    this.height = 30,
    this.width = 60,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: height, width: width);

    final lineColor = color ?? (isProfit ? Colors.green : Colors.red);
    final spots = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    final minData = data.reduce((a, b) => a < b ? a : b);
    final maxData = data.reduce((a, b) => a > b ? a : b);
    
    return SizedBox(
      height: height,
      width: width,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: minData,
          maxY: maxData,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: lineColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }
}
