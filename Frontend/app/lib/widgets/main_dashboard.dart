import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app/const/constant.dart';
import 'package:app/components/header.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(),
          const SizedBox(height: 30),
          const Text(
            'Farms Information',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildInfoCard('Total Farms', subtitle: '10'),
              buildInfoCard('Total Land Area', subtitle: '20 acres'),
              buildInfoCard('Total Crops', subtitle: '20'),
              buildInfoCard('Total Yield', subtitle: '50 tones'),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'All Farms Suggestion',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                // Data Table
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Activity Name')),
                            DataColumn(label: Text('Farm Name')),
                            DataColumn(label: Text('Area')),
                          ],
                          rows: const [
                            DataRow(cells: [
                              DataCell(Text('Weeding')),
                              DataCell(Text('Farm 1')),
                              DataCell(Text('10')),
                            ]),
                            DataRow(cells: [
                              DataCell(Text('Fertilizing')),
                              DataCell(Text('Farm 2')),
                              DataCell(Text('10')),
                            ]),
                            DataRow(cells: [
                              DataCell(Text('Plowing')),
                              DataCell(Text('Farm 3')),
                              DataCell(Text('10')),
                            ]),
                            DataRow(cells: [
                              DataCell(Text('Irrigation')),
                              DataCell(Text('Farm 4')),
                              DataCell(Text('10')),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Bar Chart
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const FarmBarChart(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard(String title, {String? subtitle}) {
    return Container(
      width: 150,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
        ],
      ),
    );
  }
}

class FarmBarChart extends StatefulWidget {
  const FarmBarChart({super.key});

  @override
  _FarmBarChartState createState() => _FarmBarChartState();
}

class _FarmBarChartState extends State<FarmBarChart> {
  int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Monthly Crop Yield (in tons)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            LegendItem(color: Colors.blue, text: 'Crop A'),
            LegendItem(color: Colors.green, text: 'Crop B'),
            LegendItem(color: Colors.red, text: 'Crop C'),
          ],
        ),
        const SizedBox(height: 10),

        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 25,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toString()} tons',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        barTouchResponse == null ||
                        barTouchResponse.spot == null) {
                      hoveredIndex = null;
                    } else {
                      hoveredIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                    }
                  });
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text(
                    'Months',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        ['Jan', 'Feb', 'Mar'][value.toInt()],
                        style: const TextStyle(color: Colors.black, fontSize: 12),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: const Text(
                    'Yield (tons)',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(color: Colors.black, fontSize: 12),
                      );
                    },
                    reservedSize: 35,
                  ),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: _buildBarGroups(),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    List<List<double>> barValues = [
      [10, 15, 8],
      [12, 18, 9],
      [14, 20, 10],
    ];

    return List.generate(3, (index) {
      return BarChartGroupData(
        x: index,
        barsSpace: 4,
        barRods: List.generate(3, (barIndex) {
          return BarChartRodData(
            toY: hoveredIndex == index ? barValues[index][barIndex] + 2 : barValues[index][barIndex], // Animate on hover
            color: [Colors.blue, Colors.green, Colors.red][barIndex],
            width: hoveredIndex == index ? 18 : 16, // Slightly increase width on hover
            borderRadius: BorderRadius.circular(4),
          );
        }),
      );
    });
  }
}


class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}