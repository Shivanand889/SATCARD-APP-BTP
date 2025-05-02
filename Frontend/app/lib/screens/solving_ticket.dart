import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/utils/global_state.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class Ticket {
  final String id;
  final String farmerName;
  final String issue;
  final String category;
  final String issueDate;
  final Uint8List? imageData;  // Changed from imageUrl to imageData (bytes)
  bool isSolved;
  String managerResponse;

  Ticket({
    required this.id,
    required this.farmerName,
    required this.issue,
    required this.category,
    required this.issueDate,
    this.imageData,
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
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/getAllTickets?email=${GlobalState().email}'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> fetchedTickets = responseData['data'];

        List<Ticket> loadedTickets = [];
        for (var ticketData in fetchedTickets) {
          // Decode base64 image data if it exists
          Uint8List? imageBytes;
          if (ticketData['imageData'] != null) {
            imageBytes = base64Decode(ticketData['imageData']);
          }

          loadedTickets.add(Ticket(
            id: ticketData['id'],
            farmerName: ticketData['name'] ?? '',
            issue: ticketData['issue'] ?? '',
            category: ticketData['category'] ?? '',
            issueDate: ticketData['issueDate'] ?? '',
            imageData: imageBytes,
            isSolved: ticketData['isSolved'] ?? false,
            managerResponse: ticketData['managerResponse'] ?? '',
          ));
        }

        setState(() {
          tickets = loadedTickets;
          isLoading = false;
        });
      } else {
        print('Failed to load tickets: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (error) {
      print('Error fetching tickets: $error');
      setState(() => isLoading = false);
    }
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
        await fetchTickets(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket marked as solved!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update ticket: ${response.body}')),
        );
      }
    } catch (error) {
      print('Error updating ticket: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  @override
  void dispose() {
    responseControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Farmer Tickets'),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tickets.isEmpty
              ? Center(
                  child: Text(
                    'No pending tickets found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    responseControllers.putIfAbsent(
                      ticket.id, 
                      () => TextEditingController(
                        text: ticket.managerResponse,
                      ),
                    );

                    return Card(
                      margin: EdgeInsets.all(12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with farmer name and status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ticket.farmerName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    ticket.isSolved ? 'SOLVED' : 'PENDING',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: ticket.isSolved 
                                      ? Colors.green 
                                      : Colors.orange,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),

                            // Issue details
                            Text(
                              'Issue: ${ticket.issue}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Category: ${ticket.category}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Date: ${ticket.issueDate.split('T')[0]}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),

                            // Image display
                            if (ticket.imageData != null) ...[
                              SizedBox(height: 12),
                              Text(
                                'Attached Image:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _showFullImage(context, ticket.imageData!),
                                child: Container(
                                  height: 180,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: Image.memory(
                                      ticket.imageData!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error, color: Colors.red),
                                              Text('Failed to load image'),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // Solution section
                            SizedBox(height: 16),
                            if (!ticket.isSolved) ...[
                              TextField(
                                controller: responseControllers[ticket.id],
                                decoration: InputDecoration(
                                  labelText: 'Enter your response',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                maxLines: 3,
                                minLines: 2,
                              ),
                              SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => solveTicket(ticket),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'MARK AS SOLVED',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.shade100,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Response:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      ticket.managerResponse,
                                      style: TextStyle(color: Colors.grey.shade800),
                                    ),
                                  ],
                                ),
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

  void _showFullImage(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.memory(imageBytes),
        ),
      ),
    );
  }
}