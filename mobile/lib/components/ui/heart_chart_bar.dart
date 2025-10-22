import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/models/heartbeat_data.dart';
import '/theme/app_theme.dart';

class HeartChartBar extends StatelessWidget {
  final String title;
  final List<HeartbeatData> data;
  final Color backgroundColor;

  const HeartChartBar({
    super.key,
    required this.title,
    required this.data,
    this.backgroundColor = AppColors.sand100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: _buildChartContent(),
    );
  }

  Widget _buildChartContent() {
    if (data.isEmpty) {
      return const Center(child: Text("Sem dados para exibir."));
    }

    final values = data.map((d) => d.value).toList();
    final minY = values.reduce((a, b) => a < b ? a : b) - 10;
    final maxY = values.reduce((a, b) => a > b ? a : b) + 10;

    return AspectRatio(
      aspectRatio: 1.7,
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
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: minY,
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.orange200.withAlpha(102),
                      strokeWidth: 1,
                      dashArray: [3, 3],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value == minY || value == maxY)
                          return const SizedBox();
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.poppins(
                            color: AppColors.orange400,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= data.length) return const SizedBox();

                        // Extract the local date from the timestamp string without timezone conversion
                        // Format: "2025-10-17 20:00:00-03:00"
                        final dateString = data[index].date;
                        final localDatePart = dateString.substring(0, 10); // "2025-10-17"
                        final parts = localDatePart.split('-');
                        final formattedDate = '${parts[2]}/${parts[1]}'; // "17/10"

                        return Text(
                          formattedDate,
                          style: GoogleFonts.poppins(
                            color: AppColors.brown,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item.value,
                        color: AppColors.orange400,
                        width: 40,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
