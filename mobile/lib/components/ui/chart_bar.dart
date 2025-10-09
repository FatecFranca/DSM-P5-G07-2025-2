import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/models/heartbeat_data.dart';
import '/theme/app_theme.dart';

class ChartBar extends StatelessWidget {
  final List<HeartbeatData> data;

  const ChartBar({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("Sem dados para exibir."));
    }

    final maxY = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return AspectRatio(
      aspectRatio: 1.5,
      child: Column(
        // 👇 MUDANÇA 1: Alinhamento da coluna para 'center'
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          Text(
            'Média de batimentos dos últimos cinco dias:',
            style: GoogleFonts.poppins(
              color: AppColors.orange900,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: (maxY * 1.2).ceilToDouble(),
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: AppColors.orange200,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value > maxY * 1.2) return const SizedBox();
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.poppins(color: AppColors.orange400, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= data.length) return const SizedBox();
                        return Text(
                          data[index].value.toInt().toString(),
                          style: GoogleFonts.poppins(color: AppColors.black400, fontSize: 10),
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
                        borderRadius: BorderRadius.circular(4),
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