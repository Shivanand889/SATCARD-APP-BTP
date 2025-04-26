import 'package:flutter/material.dart';

class Ticket {
  final String id;
  final String farmerName;
  final String issue;
  bool isSolved;
  String managerResponse;

  Ticket({
    required this.id,
    required this.farmerName,
    required this.issue,
    this.isSolved = false,
    this.managerResponse = '',
  });
}

class TicketManagerPage extends StatefulWidget {
  @override
  _TicketManagerPageState createState() => _TicketManagerPageState();
}

class _TicketManagerPageState extends State<TicketManagerPage> {
  List<Ticket> tickets = [
    Ticket(id: '1', farmerName: 'Ravi', issue: 'Crop disease in field'),
    Ticket(id: '2', farmerName: 'Sita', issue: 'Irrigation system not working'),
  ];

  final Map<String, TextEditingController> responseControllers = {};

  @override
  void dispose() {
    responseControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void solveTicket(Ticket ticket) {
    setState(() {
      ticket.isSolved = true;
      ticket.managerResponse = responseControllers[ticket.id]?.text ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Farmer Tickets'),
      ),
      body: ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          responseControllers.putIfAbsent(ticket.id, () => TextEditingController());

          return Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farmer: ${ticket.farmerName}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text('Issue: ${ticket.issue}'),
                  SizedBox(height: 10),
                  if (!ticket.isSolved) ...[
                    TextField(
                      controller: responseControllers[ticket.id],
                      decoration: InputDecoration(
                        labelText: 'Enter solution message',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => solveTicket(ticket),
                      child: Text('Solve Ticket'),
                    ),
                  ] else ...[
                    Text(
                      'Solved Message: ${ticket.managerResponse}',
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
