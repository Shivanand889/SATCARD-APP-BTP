
import 'package:app/const/constant.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class Chart extends StatelessWidget {
  const Chart({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
              sections: paiChartSelectionData,
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: defaultPadding),
                Text(
                  "74% ",
                  style: TextStyle(
                  color: Colors.black,  
                  fontSize: 22,         
                  fontWeight: FontWeight.w500, 
                ),
                ),
                Text("Humidity"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<PieChartSectionData> paiChartSelectionData = [
  
  PieChartSectionData(
    color: Color(0xFF26E5FF),
    value: 26,
    showTitle: false,
    radius: 16,
  ),
 
  PieChartSectionData(
    color: Color(0xFFEE2727),
    value: 74,
    showTitle: false,
    radius: 16,
  ),
];
