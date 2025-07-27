import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:amazon_clone_app/features/admin/models/sales.dart';
import 'package:intl/intl.dart';

class CategoryProductsChart extends StatelessWidget {
  final List<Sales> salesData;

  const CategoryProductsChart({Key? key, required this.salesData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceBetween,
            maxY: getMaxY(),
            minY: 0,

            // ✅ Tooltips
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.black.withOpacity(0.75),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final label = salesData[group.x.toInt()].label;
                  final value = salesData[group.x.toInt()].earning;
                  return BarTooltipItem(
                    '$label\n\$${NumberFormat.compact().format(value)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),

            // ✅ Axis titles
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: getStepSize(), // <- exact same as grid line spacing
                  getTitlesWidget: (value, meta) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        NumberFormat.compact().format(value),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: getBottomTitles,
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),

            // ✅ Grid
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              verticalInterval: 2,
              horizontalInterval: getStepSize(), // <- clean interval
              getDrawingVerticalLine: (value) =>
                  FlLine(color: Colors.grey.shade300, strokeWidth: 0.5),
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.grey.shade300, strokeWidth: 0.7),
            ),

            // ✅ Border
            borderData: FlBorderData(
              show: true,
              border: const Border(
                left: BorderSide(color: Colors.grey, width: 1),
                bottom: BorderSide(color: Colors.grey, width: 1),
              ),
            ),

            // ✅ Bars
            barGroups: salesData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data.earning.toDouble(),
                    width: 18,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    gradient: LinearGradient(
                      colors: [Colors.deepPurpleAccent, Colors.deepPurple],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: getMaxY(),
                      color: Colors.deepPurple.withOpacity(0.1),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          swapAnimationDuration: const Duration(milliseconds: 800),
          swapAnimationCurve: Curves.easeOutBack,
        ),
      ),
    );
  }

  /// Calculate dynamic maxY for chart
  double getMaxY() {
    if (salesData.isEmpty) return 10;
    final max = salesData.map((e) => e.earning).reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble(); // add 20% padding
  }

  /// Clean step size for Y axis & grid lines
  double getStepSize() {
    final maxY = getMaxY();
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    if (maxY <= 5000) return 500;
    if (maxY <= 10000) return 1000;
    if (maxY <= 20000) return 2000;
    if (maxY <= 50000) return 5000;
    if (maxY <= 100000) return 10000;
    return 20000;
  }

  /// Bottom axis labels (e.g. Mobiles, Books)
  Widget getBottomTitles(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index >= 0 && index < salesData.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 6,
        child: Text(
          salesData[index].label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
