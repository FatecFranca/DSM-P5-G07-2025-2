import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/models/heartbeat_data.dart';
import '/theme/app_theme.dart';

class HeartLineChart extends StatelessWidget {
  final String title;
  final List<HeartbeatData> data;
  final Color backgroundColor;

  const HeartLineChart({
    super.key,
    required this.title,
    required this.data,
    this.backgroundColor = AppColors.sand100,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("Sem dados para exibir."));
    }

    final values = data.map((d) => d.value).toList();
    final double minValue = values.reduce((a, b) => a < b ? a : b);
    final double maxValue = values.reduce((a, b) => a > b ? a : b);

    final double minY = (minValue ~/ 10) * 10; 
    final double maxY = ((maxValue + 9) ~/ 10) * 10; 

    const double interval = 10; 

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: AppColors.orange900,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.orange200.withAlpha(102),
                        strokeWidth: 1,
                        dashArray: [3, 3],
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= data.length) {
                            return const SizedBox();
                          }
                          // Extract the local date and time from the timestamp string without timezone conversion
                          // Format: "2025-10-17 20:00:00-03:00"
                          final dateString = data[index].date;
                          final datePart = dateString.substring(0, 10); // "2025-10-17"
                          final timePart = dateString.substring(11, 16); // "20:00"

                          // Format date as DD/MM
                          final parts = datePart.split('-');
                          final formattedDate = '${parts[2]}/${parts[1]}'; // "17/10"
                          final formatted = '$formattedDate\n$timePart'; // "17/10\n20:00"

                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              formatted,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: AppColors.orange900,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              value.toInt().toString(),
                              style: GoogleFonts.poppins(
                                color: AppColors.orange400,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        final i = entry.key;
                        final item = entry.value;
                        return FlSpot(i.toDouble(), item.value);
                      }).toList(),
                      isCurved: true,
                      color: AppColors.orange400,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.orange400.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
