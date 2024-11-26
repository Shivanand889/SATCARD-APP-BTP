import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting

void showAddActivityDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AddActivityForm(); // Use the stateful form widget
    },
  );
}

class AddActivityForm extends StatefulWidget {
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
    'Pesticide application',
    'Seed planting',
    'Soil testing',
    // Add more activities as needed
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
              // Multi-checkbox list
              Text('Select Activities'),

              // Limiting the height and enabling scrolling after 5 activities
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

              // Date picker field
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

              // Land area input
              TextFormField(
                decoration: InputDecoration(labelText: 'Land Area'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the land area';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    landArea = value;
                  });
                },
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
              // Collect selected activities
              List<String> selectedActivityNames = selectedActivities
                  .asMap()
                  .entries
                  .where((entry) => entry.value)
                  .map((entry) => activityOptions[entry.key])
                  .toList();

              // Replace this with your backend logic or state management update
              print('Activities: $selectedActivityNames');
              print('Date: ${_dateController.text}');
              print('Land Area: $landArea');

              Navigator.of(context).pop(); // Close the dialog
            }
          },
        ),
      ],
    );
  }
}
