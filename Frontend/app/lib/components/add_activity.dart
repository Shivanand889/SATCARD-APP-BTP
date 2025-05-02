import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import http package for API requests
import 'dart:convert'; // Import for JSON encoding
import 'package:app/utils/global_state.dart';

void showAddActivityDialog(BuildContext context, String name) {
  showDialog(
    context: context,
    builder: (context) {
      return AddActivityForm(name: name); // Use the stateful form widget
    },
  );
}

class AddActivityForm extends StatefulWidget {
  final String name;
  const AddActivityForm({Key? key, required this.name}) : super(key: key);
  @override
  _AddActivityFormState createState() => _AddActivityFormState();
}

class _AddActivityFormState extends State<AddActivityForm> {
  final _formKey = GlobalKey<FormState>();

  // Activity options
  List<String> activityOptions = [
    'Plowing',
    'Sowing',
    'Irrigation',
    'Harvesting',
    'Fertilizing',
    'Weeding',
    'Spray',
    'Pruning',
    'Transplantion',
    'Mulching',
    'Scouting',
  ];

  // List to track selected activities
  late List<bool> selectedActivities;

  @override
  void initState() {
    super.initState();
    selectedActivities = List.generate(activityOptions.length, (index) => false);
  }

  // Method to send data to the backend
  Future<void> sendDataToBackend() async {
    List<String> selectedActivityNames = selectedActivities
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => activityOptions[entry.key])
        .toList();

    final Map<String, dynamic> payload = {
      'activities': selectedActivityNames,
      'name': widget.name,
      'email': GlobalState().email,
    };

    const String url = 'http://127.0.0.1:8000/add-activity';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        print('Activity added successfully: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Activity added successfully!')),
        );
      } else {
        print('Failed to add activity: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add activity: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Activity'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Activities'),
              activityOptions.length > 5
                  ? Container(
                      height: 200,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: List.generate(activityOptions.length, (index) {
                            return CheckboxListTile(
                              title: Text(activityOptions[index]),
                              value: selectedActivities[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  selectedActivities[index] = value ?? false;
                                });
                              },
                            );
                          }),
                        ),
                      ),
                    )
                  : Column(
                      children: List.generate(activityOptions.length, (index) {
                        return CheckboxListTile(
                          title: Text(activityOptions[index]),
                          value: selectedActivities[index],
                          onChanged: (bool? value) {
                            setState(() {
                              selectedActivities[index] = value ?? false;
                            });
                          },
                        );
                      }),
                    ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('Add'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              sendDataToBackend();
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
