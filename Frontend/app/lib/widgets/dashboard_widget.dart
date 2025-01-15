import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  const DashboardWidget({
    super.key,
    this.farmData = const [],
    this.weatherData = const {},
    this.name = "",
    this.activityData = const [],
  });

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  bool showSuggestions = false; // Track if the suggestions box is visible
  List<String> suggestions = []; // Store the fetched suggestions

  Future<void> fetchSuggestions() async {
    final url = Uri.parse('http://127.0.0.1:8000/suggestions');

    try {
      final response = await http.post(
        url,
        body: {'name': widget.name},
      );

      if (response.statusCode == 200) {
        // Decode the response and update suggestions
        final data = json.decode(response.body);
        setState(() {
          suggestions = List<String>.from(data['data']); // Extract from "data" key
          showSuggestions = true;
        });
      } else {
        print('Failed to fetch suggestions: ${response.body}');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  void toggleSuggestions() {
    setState(() {
      if (showSuggestions) {
        // Hide suggestions if already visible
        showSuggestions = false;
      } else {
        // Fetch suggestions if not visible
        fetchSuggestions();
      }
    });
  }

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
                          onPressed: toggleSuggestions,
                          child: Text(
                            showSuggestions ? "Hide Suggestions" : "Show Suggestions",
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
                                ...List.generate(suggestions.length, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text(
                                      "${index + 1}. ${suggestions[index]}",
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
