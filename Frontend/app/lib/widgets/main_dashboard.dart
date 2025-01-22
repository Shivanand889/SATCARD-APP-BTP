import 'package:flutter/material.dart';
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
          SizedBox(height: 30),
          const Text(
            'Farms Information',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7, 
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
