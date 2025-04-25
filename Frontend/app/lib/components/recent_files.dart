import 'dart:convert';
import 'dart:html' as html; // Import for file download
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/models/recent_file.dart';
import 'package:app/const/constant.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:app/utils/global_state.dart';
class RecentFiles extends StatefulWidget {
  final List<dynamic> activityData;
  final String farmName;

  const RecentFiles({
    Key? key,
    required this.activityData,
    required this.farmName,
  }) : super(key: key);

  @override
  State<RecentFiles> createState() => _RecentFilesState();
}

class _RecentFilesState extends State<RecentFiles> {
  List<dynamic> filteredData = [];
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    filteredData = widget.activityData;
  }

  // Function to handle the download action
  Future<void> downloadData() async {
    const String url = "http://127.0.0.1:8000/downloadActivityDetails";
    print("From Date: ${fromDate}");
print("To Date: ${toDate}");
print("Formatted From Date: ${fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : 'null'}");
print("Formatted To Date: ${toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : 'null'}");

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": widget.farmName,
        "from_date": fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : null,
        "to_date": toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : null,
        "email" : GlobalState().email
      }),
    );

    if (response.statusCode == 200) {
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

  // Function to filter data based on selected dates
  void filterData() {
    if (fromDate == null || toDate == null) {
      setState(() {
        filteredData = widget.activityData;
      });
      return;
    }

    setState(() {
      filteredData = widget.activityData.where((activity) {
        DateTime activityDate = DateTime.parse(activity['date']);
        return activityDate.isAfter(fromDate!.subtract(const Duration(days: 1))) &&
            activityDate.isBefore(toDate!.add(const Duration(days: 1)));
      }).toList();
    });
  }

  // Function to pick date
  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  // Function to handle assignment of an activity
  void assignActivity(String activityName) {
    // Here, you can implement logic to assign the activity
    print("Assigned: $activityName");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Assigned activity: $activityName")),
    );
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
              Row(
                children: [
                  // Filter Label
                  Text(
                    "Filter:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  // From Date Picker
                  TextButton.icon(
                    icon: Icon(Icons.date_range),
                    label: Text(fromDate == null
                        ? "From"
                        : DateFormat('yyyy-MM-dd').format(fromDate!)),
                    onPressed: () => _selectDate(context, true),
                  ),
                  SizedBox(width: 8),
                  // To Date Picker
                  TextButton.icon(
                    icon: Icon(Icons.date_range),
                    label: Text(toDate == null
                        ? "To"
                        : DateFormat('yyyy-MM-dd').format(toDate!)),
                    onPressed: () => _selectDate(context, false),
                  ),
                  SizedBox(width: 8),
                  // Go Button for Filtering
                  ElevatedButton(
                    onPressed: filterData,
                    child: Text("Go"),
                  ),
                  SizedBox(width: 8),
                  // Download Button
                  IconButton(
                    icon: Icon(Icons.download),
                    onPressed: downloadData,
                    tooltip: 'Download Activity Data',
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              columns: const [
                DataColumn(label: Text("Activity Name")),
                DataColumn(label: Text("Date")),
                DataColumn(label: Text("Area")),
                DataColumn(label: Text("Assign")), // New Column
              ],
              rows: List.generate(
                filteredData.length,
                (index) => recentFileDataRow(filteredData[index], assignActivity),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Updated function to add Assign button
DataRow recentFileDataRow(dynamic activityData, Function(String) assignActivity) {
  final activityName = activityData['name'] ?? 'No name';
  final activityDate = activityData['date'] ?? 'No date';
  final area = activityData['area'] ?? 'No area';

  return DataRow(
    cells: [
      DataCell(Text(activityName)),
      DataCell(Text(activityDate)),
      DataCell(Text(area)),
      DataCell(
        ElevatedButton(
          onPressed: () => assignActivity(activityName),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Assign button color
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text("Assign", style: TextStyle(color: Colors.white)),
        ),
      ),
    ],
  );
}
