import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/utils/global_state.dart';
class Ticket {
  final String id;
  final String farmerName;
  final String issue;
  final String category;
  final String issueDate;
  bool isSolved;
  String managerResponse;

  Ticket({
    required this.id,
    required this.farmerName,
    required this.issue,
    required this.category,
    required this.issueDate,
    this.isSolved = false,
    this.managerResponse = '',
  });
}

class TicketManagerPage extends StatefulWidget {
  @override
  _TicketManagerPageState createState() => _TicketManagerPageState();
}

class _TicketManagerPageState extends State<TicketManagerPage> {
  List<Ticket> tickets = [];
  final Map<String, TextEditingController> responseControllers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    try {
      
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/getAllTickets?email=${GlobalState().email}'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> fetchedTickets = responseData['data'];

        List<Ticket> loadedTickets = [];
        for (var i = 0; i < fetchedTickets.length; i++) {
          var ticketData = fetchedTickets[i];
          loadedTickets.add(Ticket(
            // Using index as ID (or you can use another unique field if available)
            id : ticketData['id'],
            farmerName: ticketData['name'] ?? '',
            issue: ticketData['issue'] ?? '',
            category: ticketData['category'] ?? '',
            issueDate: ticketData['issueDate'] ?? '',
            
          ));
        }

        setState(() {
          tickets = loadedTickets;
          isLoading = false;
        });
      } else {
        print('Failed to load tickets');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching tickets: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    responseControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

 void solveTicket(Ticket ticket) async {
  final managerResponseText = responseControllers[ticket.id]?.text ?? '';

  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/updateTickets'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': GlobalState().email,
        'id': ticket.id,
        'message': managerResponseText,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        final responseData = json.decode(response.body);
        final List<dynamic> fetchedTickets = responseData['data'];

        List<Ticket> loadedTickets = [];
        for (var i = 0; i < fetchedTickets.length; i++) {
          var ticketData = fetchedTickets[i];
          loadedTickets.add(Ticket(
            // Using index as ID (or you can use another unique field if available)
            id : ticketData['id'],
            farmerName: ticketData['name'] ?? '',
            issue: ticketData['issue'] ?? '',
            category: ticketData['category'] ?? '',
            issueDate: ticketData['issueDate'] ?? '',
            
          ));
        }

        setState(() {
          tickets = loadedTickets;
          isLoading = false;
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket marked as solved!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update ticket. Please try again.')),
      );
    }
  } catch (error) {
    print('Error updating ticket: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred. Please try again.')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Farmer Tickets'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tickets.isEmpty
              ? Center(child: Text('No tickets found.'))
              : ListView.builder(
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
                            SizedBox(height: 6),
                            Text('Category: ${ticket.category}'),
                            SizedBox(height: 6),
                            Text('Issue Date: ${ticket.issueDate.split('T')[0]}'), // To show only date part
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
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
