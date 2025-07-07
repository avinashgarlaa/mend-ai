import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ScoreChart extends StatelessWidget {
  final List<Map<String, dynamic>> scores; // Each is a Score + session info

  const ScoreChart({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    final labels = ["Emp", "Lis", "Cla", "Res", "Rsp", "OM"];
    final colors = [
      Colors.pink,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
    ];

    List<LineChartBarData> lines = [];

    for (int i = 0; i < labels.length; i++) {
      final data = scores
          .asMap()
          .entries
          .map(
            (entry) => FlSpot(
              entry.key.toDouble(),
              (entry.value["score"][i]).toDouble(),
            ),
          )
          .toList();

      lines.add(
        LineChartBarData(
          isCurved: true,
          color: colors[i],
          barWidth: 2,
          spots: data,
          dotData: FlDotData(show: true),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) => Text("S${value.toInt() + 1}"),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) => Text(
                  val.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: true),
          lineBarsData: lines,
        ),
      ),
    );
  }
}
