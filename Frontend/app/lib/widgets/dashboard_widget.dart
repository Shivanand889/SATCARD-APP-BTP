import 'package:flutter/material.dart';
import 'package:app/components/header.dart';
import 'package:app/components/my_files.dart';
import 'package:app/components/recent_files.dart';
import 'package:app/components/storage_details.dart';
import 'package:app/responsive.dart';
import 'package:app/const/constant.dart';
import 'package:app/models/my_files.dart';

class DashboardWidget extends StatefulWidget {
  final List<CloudStorageInfo> farmData;
  final Map<String, dynamic> weatherData;
  final String name;
  final List<dynamic> activityData;
  final List<String> suggestionsData;  // Accept dynamic suggestions

  const DashboardWidget({
    super.key,
    this.farmData = const [],
    this.weatherData = const {},
    this.name = "",
    this.activityData = const [],
    this.suggestionsData = const ["Check irrigation levels",
    "Inspect crop health",
    "Update farm logs",
    "Plan for fertilization"],  // Default to an empty list
  });

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  bool showSuggestions = false; // Track if the suggestions box is visible

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      MyFiles(fileData: widget.farmData, name: widget.name),
                      SizedBox(height: defaultPadding),
                      RecentFiles(activityData: widget.activityData),
                      if (Responsive.isMobile(context)) SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context))
                        StorageDetails(weatherData: widget.weatherData),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context)) SizedBox(width: defaultPadding),
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        StorageDetails(weatherData: widget.weatherData),
                        SizedBox(height: defaultPadding),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showSuggestions = !showSuggestions; // Toggle visibility
                            });
                          },
                          child: Text(showSuggestions ? "Hide Suggestions" : "Show Suggestions",
                          style: TextStyle(height: 3),
                          ),
                        ),
                        if (showSuggestions)
                          Container(
                            margin: EdgeInsets.only(top: defaultPadding),
                            padding: EdgeInsets.all(defaultPadding),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                Text(
                                  "Suggested Activities",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                ...List.generate(widget.suggestionsData.length, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text(
                                      "${index + 1}. ${widget.suggestionsData[index]}",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
