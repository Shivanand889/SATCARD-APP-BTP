import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/utils/global_state.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  Map<String, dynamic> resolution = {};
  int openCount = 0;
  int resolvedCount = 0;
  Map<String, dynamic> ticketsOverTime = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    sendPostRequest();
  }

  void sendPostRequest() async {
    const url = 'http://127.0.0.1:8000/ticketAnalytics';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"email": GlobalState().email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          resolution = Map<String, dynamic>.from(data['resolution']);
          openCount = data['openCount'];
          resolvedCount = data['resolvedCount'];
          ticketsOverTime = Map<String, dynamic>.from(data['ticketsOverTime']);
          isLoading = false;
        });
      } else {
        print("POST failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending POST: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Support System Insights")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Tickets Raised", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(height: 300, child: LineChartWidget(ticketsOverTime: ticketsOverTime)),

                  const SizedBox(height: 30),
                  const Text("Ticket Status Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(height: 300, child: PieChartWidget(openCount: openCount, resolvedCount: resolvedCount)),

                  const SizedBox(height: 30),
                  const Text("Average Resolution Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(height: 300, child: BarChartWidget(resolution: resolution)),
                ],
              ),
            ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final Map<String, dynamic> ticketsOverTime;

  const LineChartWidget({super.key, required this.ticketsOverTime});

  @override
  Widget build(BuildContext context) {
    final sortedKeys = ticketsOverTime.keys.toList()..sort();
    final spots = sortedKeys.asMap().entries.map((entry) {
      int index = entry.key;
      String date = entry.value;
      return FlSpot(index.toDouble(), (ticketsOverTime[date] as num).toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: const Text("Tickets Count", style: TextStyle(fontWeight: FontWeight.bold)),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 12)),
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < sortedKeys.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(sortedKeys[index].substring(5), style: const TextStyle(fontSize: 12)),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 4,
            belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
            color: Colors.blue,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final int openCount;
  final int resolvedCount;

  const PieChartWidget({super.key, required this.openCount, required this.resolvedCount});

  @override
  Widget build(BuildContext context) {
    final statusData = [
      {"status": "Open", "count": openCount},
      {"status": "Resolved", "count": resolvedCount},
    ];

    return PieChart(
      PieChartData(
        sections: statusData.map((data) {
          return PieChartSectionData(
            value: (data["count"] as num).toDouble(),
            title: "${data["status"]}\n${data["count"]}",
            color: data["status"] == "Open" ? Colors.red : Colors.green,
            radius: 60,
          );
        }).toList(),
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final Map<String, dynamic> resolution;

  const BarChartWidget({super.key, required this.resolution});

  // Define colors for each category
  final Map<String, Color> categoryColors = const {
    'Irrigation': Colors.blue,
    'Soil Health': Colors.green,
    'Fertilizers': Colors.orange,
    'Machinery': Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    final categories = resolution.keys.toList();
    final barGroups = <BarChartGroupData>[];

    // Find max value for Y-axis scaling
    double maxY = resolution.values.reduce((a, b) => a > b ? a : b).toDouble();
    maxY = maxY.ceilToDouble(); // Round up to nearest integer

    for (int i = 0; i < categories.length; i++) {
      final avgTime = resolution[categories[i]];
      if (avgTime != null) {
        final doubleValue = (avgTime as num).toDouble();
        final color = categoryColors[categories[i]] ?? Colors.grey;
        
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: doubleValue,
                color: color,
                width: 20,
              ),
            ],
          ),
        );
      }
    }

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        maxY: maxY, // Set max Y value based on data
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < categories.length) {
                  return Transform.rotate(
                    angle: -0.4,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        categories[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text("Average Time (days)", style: TextStyle(fontWeight: FontWeight.bold)),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1, // Show labels at 1 unit intervals
              getTitlesWidget: (value, meta) {
                // Show decimal places only if needed
                if (value == value.toInt()) {
                  return Text(value.toInt().toString(), style: const TextStyle(fontSize: 12));
                }
                return Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 12));
              },
            ),
          ),
          rightTitles: AxisTitles(),
          topTitles: AxisTitles(),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false, // Only show horizontal grid lines
        ),
        borderData: FlBorderData(show: true),
        barTouchData: BarTouchData(enabled: false),
      ),
    );
  }
}