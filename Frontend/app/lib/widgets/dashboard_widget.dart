import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/components/my_files.dart';
import 'package:app/components/recent_files.dart';
import 'package:app/components/storage_details.dart';
import 'package:app/responsive.dart';
import 'package:app/const/constant.dart';
import 'package:app/models/my_files.dart';
import 'package:app/utils/global_state.dart';

class DashboardWidget extends StatefulWidget {
  final List<CloudStorageInfo> farmData;
  final Map<String, dynamic> weatherData;
  final String name;
  final List<dynamic> activityData;

  const DashboardWidget({
    Key? key,
    this.farmData = const [],
    this.weatherData = const {},
    this.name = "",
    this.activityData = const [],
  }) : super(key: key);

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  List<List<String>> suggestions = [];
  List<List<String>> workerNames = []; // Changed to List<List<String>>
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSuggestions();
  }

  Future<void> fetchSuggestions() async {
    final url = Uri.parse('http://127.0.0.1:8000/suggestions');

    try {
      final response = await http.post(
        url,
        body: {'name': widget.name, 'email': GlobalState().email},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("API Response: $data"); // Debug print
        
        setState(() {
          suggestions = List<List<String>>.from(
            data['data']?.map((item) => List<String>.from(item)) ?? [],
          );
          
          // Simplified workerNames parsing
          workerNames = List<List<String>>.from(
            data['workerNames']?.map((worker) => List<String>.from(worker)) ?? [],
          );
          
          isLoading = false;
        });
        
        print("Parsed workerNames: $workerNames"); // Debug print
      } else {
        print('Failed to fetch suggestions: ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      setState(() => isLoading = false);
    }
  }

  Widget suggestionBox() {
    return Container(
      width: double.infinity,
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
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (suggestions.isEmpty)
            Text(
              "No suggestions found.",
              style: TextStyle(fontSize: 14),
            )
          else
            ...List.generate(suggestions.length, (index) {
              return _SuggestedActivityTile(
                activityName: suggestions[index][0],
                workerList: workerNames, // Pass the complete worker list
                farmName: widget.name,
              );
            }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MyFiles(fileData: widget.farmData, name: widget.name),
                      SizedBox(height: defaultPadding),
                      RecentFiles(activityData: widget.activityData, farmName: widget.name),
                      SizedBox(height: defaultPadding),
                      suggestionBox(),
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
                    child: StorageDetails(weatherData: widget.weatherData),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedActivityTile extends StatefulWidget {
  final String activityName;
  final List<List<String>> workerList;
  final String farmName;

  const _SuggestedActivityTile({
    Key? key,
    required this.activityName,
    required this.workerList,
    required this.farmName,
  }) : super(key: key);

  @override
  State<_SuggestedActivityTile> createState() => _SuggestedActivityTileState();
}

class _SuggestedActivityTileState extends State<_SuggestedActivityTile> {
  bool showDropdown = false;
  List<String>? selectedWorker;

  Future<void> assignActivity() async {
    if (selectedWorker != null && selectedWorker!.length >= 2) {
      final url = Uri.parse('http://127.0.0.1:8000/addTasks');

      try {
        final response = await http.post(
          url,
          body: {
            'workerEmail': selectedWorker![1],
            'activity': widget.activityName,
            'farmName': widget.farmName,
          },
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Assigned "${widget.activityName}" to ${selectedWorker![0]}')),
          );
          setState(() {
            showDropdown = false;
            selectedWorker = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to assign task: ${response.body}')),
          );
        }
      } catch (e) {
        print('Error assigning task: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning task')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.activityName,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showDropdown = !showDropdown;
                  });
                },
                child: Text('Assign'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  backgroundColor: Colors.purple[50],
                  foregroundColor: Colors.deepPurple,
                  elevation: 0,
                ),
              ),
            ],
          ),
          if (showDropdown && widget.workerList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<List<String>>(
                      hint: Text("Select Person"),
                      value: selectedWorker,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          selectedWorker = value;
                        });
                      },
                      items: widget.workerList.map((worker) {
                        if (worker.length >= 2) {
                          return DropdownMenuItem<List<String>>(
                            value: worker,
                            child: Text(worker[0]),
                          );
                        }
                        return DropdownMenuItem<List<String>>(
                          value: ['Invalid', ''],
                          child: Text('Invalid worker data'),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: assignActivity,
                    child: Text('Confirm'),
                  ),
                ],
              ),
            ),
          if (showDropdown && widget.workerList.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('No workers available for this activity'),
            ),
        ],
      ),
    );
  }
}