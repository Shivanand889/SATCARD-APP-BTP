import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting
import 'package:http/http.dart' as http; // Import http package for API requests
import 'dart:convert'; // Import for JSON encoding

void showAddActivityDialog(BuildContext context, String name) {
  showDialog(
    context: context,
    builder: (context) {
      return AddActivityForm(name:name); // Use the stateful form widget
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
  DateTime selectedDate = DateTime.now();
  TextEditingController _dateController = TextEditingController();

  // Activity options (you can add more activities here)
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

  String landArea = '';

  @override
  void initState() {
    super.initState();
    selectedActivities = List.generate(activityOptions.length, (index) => false); // Initialize list based on activity options
    _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate); // Format date
  }

  // Method to send data to the backend
  Future<void> sendDataToBackend() async {
    // Collect selected activities
    List<String> selectedActivityNames = selectedActivities
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => activityOptions[entry.key])
        .toList();

    // Create the payload
    final Map<String, dynamic> payload = {
      'activities': selectedActivityNames,
      'date': _dateController.text,
      'name': widget.name
    };

    // Define the backend endpoint
    const String url = 'http://127.0.0.1:8000/add-activity';

    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        // Success: Parse the response or show a success message
        print('Activity added successfully: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Activity added successfully!')),
        );
      } else {
        // Handle error
        print('Failed to add activity: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add activity: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      // Handle exception
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
                      height: 200, // Limit height, scrollable after 5 activities
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: List.generate(activityOptions.length, (index) {
                            return CheckboxListTile(
                              title: Text(activityOptions[index]),
                              value: selectedActivities[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  selectedActivities[index] = value ?? false; // Update selected state
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
                              selectedActivities[index] = value ?? false; // Update selected state
                            });
                          },
                        );
                      }),
                    ),
              SizedBox(height: 10),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Select Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                      _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate); // Format date to show only date
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              
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
              sendDataToBackend(); // Call the method to send data to the backend
              Navigator.of(context).pop(); // Close the dialog
            }
          },
        ),
      ],
    );
  }
}
