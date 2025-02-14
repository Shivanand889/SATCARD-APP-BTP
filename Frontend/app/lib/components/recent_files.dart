import 'package:app/models/recent_file.dart';
import 'package:app/const/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RecentFiles extends StatelessWidget {
  final List<dynamic> activityData; // Activity data passed to the widget

  const RecentFiles({
    Key? key,
    required this.activityData, // Required parameter for activity data
  }) : super(key: key);

  // Function to handle the download action
  void downloadData() {
    // Implement the download logic here
    print('Downloading activity data...');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add a Row for the title and download button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Activities",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: Icon(Icons.download),
                onPressed: downloadData, // Call the download function
                tooltip: 'Download Activity Data',
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              columns: const [
                DataColumn(
                  label: Text("Activity Name"),
                ),
                DataColumn(
                  label: Text("Date"),
                ),
                DataColumn(
                  label: Text("Area"),
                ),
              ],
              rows: List.generate(
                activityData.length,
                (index) => recentFileDataRow(activityData[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Updated to use activity data fields
DataRow recentFileDataRow(dynamic activityData) {
  final activityName = activityData['name'];
  final activityDate = activityData['date'];
  final area = activityData['area'];

  return DataRow(
    cells: [
      DataCell(Text(activityName ?? 'No name')),
      DataCell(Text(activityDate ?? 'No date')),
      DataCell(Text(area ?? 'No area')),
    ],
  );
}
