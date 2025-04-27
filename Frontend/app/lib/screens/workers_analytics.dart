import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsDashboardPage extends StatelessWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A2E),
        title: Text('Analytics Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Audit Trails & User Activity
            Text(
              "Audit Trails & User Activity",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 16),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Most Active Users", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 200, child: MostActiveUsersChart()),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Action Type Distribution (CRUD)", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 200, child: ActionTypePieChart()),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            // Task Assignment & Progress
            Text(
              "Task Assignment & Progress",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 16),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Task Completion Rate", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 200, child: TaskCompletionLineChart()),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Task Distribution", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 200, child: TaskDistributionBarChart()),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Pending vs Completed Tasks", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 200, child: PendingCompletedDonutChart()),
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

// ----------------------
// Most Active Users (Bar Chart)
class MostActiveUsersChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              final users = ['John', 'Jane', 'Alice', 'Bob'];
              return Text(users[value.toInt()], style: TextStyle(fontSize: 10));
            }),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 15, color: Colors.blue)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 12, color: Colors.green)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 9, color: Colors.orange)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 7, color: Colors.red)]),
        ],
      ),
    );
  }
}

// ----------------------
// Action Type Distribution (Pie Chart)
class ActionTypePieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 30, title: 'Create', color: Colors.green),
          PieChartSectionData(value: 40, title: 'Read', color: Colors.blue),
          PieChartSectionData(value: 20, title: 'Update', color: Colors.orange),
          PieChartSectionData(value: 10, title: 'Delete', color: Colors.red),
        ],
        centerSpaceRadius: 40,
      ),
    );
  }
}

// ----------------------
// Task Completion Rate (Line Chart)
class TaskCompletionLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1, // Important: show titles every 1 unit
              getTitlesWidget: (value, meta) {
                final weeks = ['W1', 'W2', 'W3', 'W4'];
                if (value.toInt() >= 0 && value.toInt() < weeks.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(weeks[value.toInt()], style: TextStyle(fontSize: 10)),
                  );
                } else {
                  return const SizedBox.shrink(); // No label if outside bounds
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 2), // Y-axis interval
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        minX: 0,
        maxX: 3,
        minY: 0,
        maxY: 12,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.purple,
            barWidth: 3,
            dotData: FlDotData(show: true),
            spots: [
              FlSpot(0, 5),
              FlSpot(1, 8),
              FlSpot(2, 6),
              FlSpot(3, 10),
            ],
          ),
        ],
      ),
    );
  }
}


// ----------------------
// Task Distribution (Bar Chart)
class TaskDistributionBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              final workers = ['Worker1', 'Worker2', 'Worker3', 'Worker4'];
              return Text(workers[value.toInt()], style: TextStyle(fontSize: 10));
            }),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 10, color: Colors.teal)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 14, color: Colors.pink)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 8, color: Colors.cyan)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 12, color: Colors.amber)]),
        ],
      ),
    );
  }
}

// ----------------------
// Pending vs Completed Tasks (Donut Chart)
class PendingCompletedDonutChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 70,
            title: 'Completed',
            color: Colors.green,
            radius: 50,
          ),
          PieChartSectionData(
            value: 30,
            title: 'Pending',
            color: Colors.red,
            radius: 50,
          ),
        ],
        centerSpaceRadius: 40,
      ),
    );
  }
}
