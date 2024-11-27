import 'package:app/models/recent_file.dart';
import 'package:app/const/constant.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RecentFiles extends StatelessWidget {
  final List<dynamic> activityData; // Activity data passed to the widget

  const RecentFiles({
    Key? key,
    required this.activityData, // Required parameter for activity data
  }) : super(key: key);

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
          Text(
            "Your Activities",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              // minWidth: 600,
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
                activityData.length, // Use the activityData length
                (index) => recentFileDataRow(activityData[index]), // Pass each activity data
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
  // Extract the relevant fields from activityData
  final activityName = activityData['name']; // Assuming activity data has 'name'
  final activityDate = activityData['date']; // Assuming activity data has 'date'
  final area = activityData['area']; // Assuming activity data has 'area'

  return DataRow(
    cells: [
      DataCell(Text(activityName ?? 'No name')), // Default value if null
      DataCell(Text(activityDate ?? 'No date')), // Default value if null
      DataCell(Text(area ?? 'No area')), // Default value if null
    ],
  );
}
