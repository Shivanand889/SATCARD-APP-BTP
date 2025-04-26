import 'package:flutter/material.dart';

class Activity {
  final String id;
  final String activityName;
  final DateTime assignedDate;
  bool isCompleted;
  String workerMessage;

  Activity({
    required this.id,
    required this.activityName,
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
  List<Activity> activities = [
    Activity(id: 'a1', activityName: 'Water Tomato Field', assignedDate: DateTime.now().subtract(Duration(days: 1))),
    Activity(id: 'a2', activityName: 'Harvest Wheat Crop', assignedDate: DateTime.now().subtract(Duration(days: 2))),
  ];

  final Map<String, TextEditingController> messageControllers = {};

  @override
  void dispose() {
    messageControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void completeActivity(Activity activity) {
    setState(() {
      activity.isCompleted = true;
      activity.workerMessage = messageControllers[activity.id]?.text ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Activities'),
      ),
      body: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          messageControllers.putIfAbsent(activity.id, () => TextEditingController());

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
                  Text('Assigned Date: ${activity.assignedDate.toLocal().toString().split(' ')[0]}'),
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
