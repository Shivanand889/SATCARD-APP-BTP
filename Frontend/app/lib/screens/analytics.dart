import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/utils/global_state.dart';
// Dummy global state class for demonstration

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
    const url = 'http://127.0.0.1:8000/ticketAnalytics'; // Change to your backend URL
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

        print("open ${openCount}");
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

// Line Chart: Total Tickets Raised
class LineChartWidget extends StatelessWidget {
  final Map<String, dynamic> ticketsOverTime;

  const LineChartWidget({super.key, required this.ticketsOverTime});

  @override
  Widget build(BuildContext context) {
    final sortedKeys = ticketsOverTime.keys.toList()..sort();
    final spots = sortedKeys.asMap().entries.map((entry) {
      int index = entry.key;
      String date = entry.value;
      return FlSpot(index.toDouble(), ticketsOverTime[date].toDouble());
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

// Pie Chart: Ticket Status Breakdown
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
            value: data["count"]!.toDouble(),
            title: "${data["status"]}\n${data["count"]}",
            color: data["status"] == "Open" ? Colors.red : Colors.green,
            radius: 60,
          );
        }).toList(),
      ),
    );
  }
}

extension on Object {
  toDouble() {}
}

// Bar Chart: Average Resolution Time
class BarChartWidget extends StatelessWidget {
  final Map<String, dynamic> resolution;

  const BarChartWidget({super.key, required this.resolution});

  @override
  Widget build(BuildContext context) {
    final categories = resolution.keys.toList();
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < categories.length; i++) {
      final avgValues = resolution[categories[i]] as Map<String, dynamic>;
      double avgTime = avgValues.values.fold(0.0, (sum, time) => sum + (time as num)) / avgValues.length;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: avgTime.toDouble(), color: Colors.orange, width: 20),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: barGroups,
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
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text("Avg Resolution Time", style: TextStyle(fontWeight: FontWeight.bold)),
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }
}
