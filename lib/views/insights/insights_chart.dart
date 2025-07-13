import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreChart extends StatefulWidget {
  final List<Map<String, dynamic>> scores;

  const ScoreChart({super.key, required this.scores});

  @override
  State<ScoreChart> createState() => _ScoreChartState();
}

class _ScoreChartState extends State<ScoreChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final scoreKeys = [
    "empathy",
    "listening",
    "clarity",
    "respect",
    "responsiveness",
    "openMindedness",
  ];

  final colors = [
    Color(0xFF0EA5E9), // Blue
    Color(0xFF22C55E), // Green
    Colors.blueAccent, // Indigo
    Color.fromARGB(255, 239, 153, 82), // Orange
    Color(0xFFF43F5E), // Rose
    Colors.blueAccent, // Violet
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutExpo,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<LineChartBarData> _buildAnimatedLines(double t) {
    return List.generate(scoreKeys.length, (i) {
      final spots = widget.scores.asMap().entries.map((entry) {
        final x = entry.key.toDouble();
        final y = ((entry.value[scoreKeys[i]] ?? 0) as num).toDouble() * t;
        return FlSpot(x, y);
      }).toList();

      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: colors[i],
        barWidth: 3,
        isStrokeCapRound: true,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [colors[i].withOpacity(0.3), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, _, bar, __) => FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeColor: bar.color!,
            strokeWidth: 2.5,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            spreadRadius: 4,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.blueAccent.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AI Reflection Over Time",
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 10,
                      backgroundColor: Colors.transparent,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 2,
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: Colors.black12, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 2,
                            reservedSize: 28,
                            getTitlesWidget: (value, _) => Text(
                              value.toInt().toString(),
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, _) => Text(
                              "S${value.toInt() + 1}",
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          left: BorderSide(color: Colors.black26),
                          bottom: BorderSide(color: Colors.black26),
                        ),
                      ),
                      lineBarsData: _buildAnimatedLines(_animation.value),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
