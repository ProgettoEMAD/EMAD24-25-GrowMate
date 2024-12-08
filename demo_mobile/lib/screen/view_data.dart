import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ViewData extends StatelessWidget {
  ViewData({super.key});

  final Map<String, int> _mockData = {
    "semi_rilevati": 160,
    "buchi_totali": 200,
  };
  final List<int> analisi_precedenti = [
    100,
    100,
    120,
    100,
    180,
    180,
    150,
    120,
    192,
    190,
    180,
    170,
    150,
    160,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analisi foto scattate"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sono stati rilevati ${_mockData['semi_rilevati']} semi cresciuti su ${_mockData['buchi_totali']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Percentuale di crescita: ${(_mockData['semi_rilevati']! / _mockData['buchi_totali']! * 100).toStringAsFixed(1)} %",
            ),
            const SizedBox(height: 20),
            const Text(
              "Andamento delle analisi precedenti:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(
                    show: true,
                    drawHorizontalLine: false,
                    drawVerticalLine: true,
                  ),
                  titlesData: const FlTitlesData(
                    bottomTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: analisi_precedenti
                          .asMap()
                          .entries
                          .map((e) =>
                              FlSpot(e.key.toDouble(), e.value.toDouble()))
                          .toList(),
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
