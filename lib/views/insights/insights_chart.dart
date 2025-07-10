import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ScoreChart extends StatelessWidget {
  final List<Map<String, dynamic>> scores; // Each is a CommunicationScore map

  const ScoreChart({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    final scoreKeys = [
      "empathy",
      "listening",
      "clarity",
      "respect",
      "responsiveness",
      "openMindedness",
    ];

    // final labels = [
    //   "Empathy",
    //   "Listening",
    //   "Clarity",
    //   "Respect",
    //   "Response",
    //   "Open-Minded"
    // ];

    final colors = [
      Colors.pink,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    List<LineChartBarData> lines = [];

    for (int i = 0; i < scoreKeys.length; i++) {
      final data = scores.asMap().entries.map((entry) {
        final index = entry.key;
        final sessionData = entry.value;
        final value = (sessionData[scoreKeys[i]] ?? 0).toDouble();
        return FlSpot(index.toDouble(), value);
      }).toList();

      lines.add(
        LineChartBarData(
          isCurved: true,
          color: colors[i],
          barWidth: 3,
          spots: data,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 10,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 32,
                getTitlesWidget: (value, _) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "S${value.toInt() + 1}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (val, _) {
                  return Text(
                    val.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: Colors.black26),
              bottom: BorderSide(color: Colors.black26),
            ),
          ),
          lineBarsData: lines,
        ),
      ),
    );
  }
}
