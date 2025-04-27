import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:app/components/header.dart';
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
  List<List<String>> suggestions = [];
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
        setState(() {
          suggestions = List<List<String>>.from(
            data['data'].map((item) => List<String>.from(item))
          );
          isLoading = false;
        });
      } else {
        print('Failed to fetch suggestions: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget suggestionBox() {
   // Example list of people for assignment
   final List<String> peopleList = ['John', 'Jane', 'Alice', 'Bob'];

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
                peopleList: peopleList,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
                    children: [
                      MyFiles(fileData: widget.farmData, name: widget.name),
                      SizedBox(height: defaultPadding),
                      RecentFiles(activityData: widget.activityData, farmName: widget.name),
                      SizedBox(height: defaultPadding),
                      suggestionBox(), // <-- Suggestion box
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
  final List<String> peopleList;

  const _SuggestedActivityTile({
    Key? key,
    required this.activityName,
    required this.peopleList,
  }) : super(key: key);

  @override
  State<_SuggestedActivityTile> createState() => _SuggestedActivityTileState();
}

class _SuggestedActivityTileState extends State<_SuggestedActivityTile> {
  bool showDropdown = false;
  String? selectedPerson;

  void assignActivity() {
    if (selectedPerson != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assigned "${widget.activityName}" to $selectedPerson')),
      );
      setState(() {
        showDropdown = false;
        selectedPerson = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0), // <--- ADD THIS padding between tiles
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
                  backgroundColor: Colors.purple[50], // matching your UI
                  foregroundColor: Colors.deepPurple,  // text color
                  elevation: 0,
                ),
              ),
            ],
          ),
          if (showDropdown)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text("Select Person"),
                      value: selectedPerson,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          selectedPerson = value;
                        });
                      },
                      items: widget.peopleList.map((person) {
                        return DropdownMenuItem<String>(
                          value: person,
                          child: Text(person),
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
        ],
      ),
    );
  }

}

