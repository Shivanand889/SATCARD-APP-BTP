import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Support System Insights")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Total Tickets Raised", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(height: 300, child: LineChartWidget()),

            const SizedBox(height: 30),
            const Text("Ticket Status Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(height: 300, child: PieChartWidget()),

            const SizedBox(height: 30),
            const Text("Average Resolution Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(height: 300, child: BarChartWidget()),
          ],
        ),
      ),
    );
  }
}

// 1. Line Chart: Total Tickets Raised
class LineChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> ticketData = [
    {"date": "2025-03-01", "tickets": 5},
    {"date": "2025-03-02", "tickets": 7},
    {"date": "2025-03-03", "tickets": 9},
    {"date": "2025-03-04", "tickets": 8},
    {"date": "2025-03-05", "tickets": 6},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: const Text("Tickets Count", style: TextStyle(fontWeight: FontWeight.bold)),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString(), style: const TextStyle(fontSize: 12));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < ticketData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        ticketData[index]["date"].toString().substring(5), // MM-DD format
                        style: const TextStyle(fontSize: 12),
                      ),
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
              spots: ticketData
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value["tickets"].toDouble()))
                  .toList(),
              isCurved: true,
              barWidth: 4,
              belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
              color: Colors.blue,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Pie Chart: Ticket Status Breakdown
class PieChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> statusData = [
    {"status": "Open", "count": 15},
    {"status": "Resolved", "count": 30},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: statusData
              .map(
                (data) => PieChartSectionData(
                  value: data["count"].toDouble(),
                  title: "${data["status"]}\n${data["count"]}",
                  color: data["status"] == "Open" ? Colors.red : Colors.green,
                  radius: 60,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// 3. Bar Chart: Average Resolution Time
class BarChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> resolutionTimeData = [
    {"category": "Technical Issue", "avg_time": 4.5},
    {"category": "Billing", "avg_time": 2.1},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350, // Increased height to give more space for labels
      child: BarChart(
        BarChartData(
          barGroups: resolutionTimeData
              .asMap()
              .entries
              .map(
                (e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(toY: e.value["avg_time"].toDouble(), color: Colors.orange, width: 20),
                  ],
                ),
              )
              .toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(top: 20), // Increased padding for labels
                child: Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50, // Increased space for labels
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Transform.rotate(
                    angle: -0.4, // Rotate labels slightly for better fit
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        resolutionTimeData[value.toInt()]["category"],
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
      ),
    );
  }
}
