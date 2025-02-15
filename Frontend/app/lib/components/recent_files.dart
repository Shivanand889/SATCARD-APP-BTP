import 'dart:convert';
import 'dart:html' as html; // Import for file download
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/models/recent_file.dart';
import 'package:app/const/constant.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RecentFiles extends StatelessWidget {
  final List<dynamic> activityData;
  final String farmName ;
  const RecentFiles({
    Key? key,
    required this.activityData,
    required this.farmName,
  }) : super(key: key);

  // Function to handle the download action
  Future<void> downloadData() async {
    const String url = "http://127.0.0.1:8000/downloadActivityDetails";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": farmName}), // Replace with actual farm name
      );

      if (response.statusCode == 200) {
        // Create a blob from response body and trigger download
        final blob = html.Blob([response.body]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "activity_data.csv")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        print("Failed to download: ${response.statusCode}");
      }
    } catch (e) {
      print("Error downloading file: $e");
    }
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Activities",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: Icon(Icons.download),
                onPressed: downloadData, // Updated function
                tooltip: 'Download Activity Data',
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              columns: const [
                DataColumn(label: Text("Activity Name")),
                DataColumn(label: Text("Date")),
                DataColumn(label: Text("Area")),
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
