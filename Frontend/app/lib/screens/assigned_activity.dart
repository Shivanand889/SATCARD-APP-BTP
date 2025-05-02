import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/utils/global_state.dart';

class Activity {
  final String id;
  final String activityName;
  final String farmName;
  final DateTime assignedDate;
  bool isCompleted;
  String workerMessage;

  Activity({
    required this.id,
    required this.activityName,
    required this.farmName,
    required this.assignedDate,
    this.isCompleted = false,
    this.workerMessage = '',
  });
}

class WorkerActivityPage extends StatefulWidget {
  @override
  _WorkerActivityPageState createState() => _WorkerActivityPageState();
}

class _WorkerActivityPageState extends State<WorkerActivityPage> {
  List<Activity> activities = [];
  final Map<String, TextEditingController> messageControllers = {};
  final String workerEmail = GlobalState().email; // Replace with actual worker email logic

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  void dispose() {
    messageControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> fetchTasks() async {
    try {
      final url = Uri.parse('http://127.0.0.1:8000/getTasks');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({'workerEmail': workerEmail}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List tasks = data['Tasks'];

        setState(() {
          activities = tasks.map((task) {
            return Activity(
              id: task[3], // Corrected: fetch id from 4th entry
              activityName: task[0],
              farmName: task[1],
              assignedDate: DateTime.parse(task[2]),
            );
          }).toList();
        });
      } else {
        print('Failed to fetch tasks: ${response.body}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  Future<void> completeActivity(Activity activity) async {
    setState(() {
      activity.isCompleted = true;
      activity.workerMessage = messageControllers[activity.id]?.text ?? '';
    });

    try {
      final url = Uri.parse('http://127.0.0.1:8000/updateTasks');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'workerEmail': workerEmail,
          'activityId': activity.id, // Use correct id
          'name' : activity.farmName, 
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List tasks = data['Tasks'];

        setState(() {
          activities = tasks.map((task) {
            return Activity(
              id: task[3], // Corrected: fetch id from 4th entry
              activityName: task[0],
              farmName: task[1],
              assignedDate: DateTime.parse(task[2]),
            );
          }).toList();
        });
      } else {
        print('Failed to update tasks: ${response.body}');
      }
    } catch (e) {
      print('Error updating tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Activities'),
      ),
      body: activities.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                messageControllers.putIfAbsent(
                    activity.id, () => TextEditingController());

                return Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity: ${activity.activityName}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Farm Name: ${activity.farmName}',
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Assigned Date: ${activity.assignedDate.toLocal().toString().split(' ')[0]}',
                        ),
                        SizedBox(height: 10),
                        if (!activity.isCompleted) ...[
                          TextField(
                            controller: messageControllers[activity.id],
                            decoration: InputDecoration(
                              labelText: 'Enter message for manager',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => completeActivity(activity),
                            child: Text('Mark as Completed'),
                          ),
                        ] else ...[
                          Text(
                            'Completed Message: ${activity.workerMessage}',
                            style: TextStyle(color: Colors.green),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
