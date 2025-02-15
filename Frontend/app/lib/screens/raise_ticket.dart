import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/const/constant.dart'; // Importing constants

class TicketPortalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TicketPortalScreen();
  }
}

class Ticket {
  String issue;
  String category;
  String status;

  Ticket({required this.issue, required this.category, this.status = "Pending"});

  // Factory constructor to create a Ticket from JSON
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      issue: json['issue'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }
}

class TicketPortalScreen extends StatefulWidget {
  @override
  _TicketPortalScreenState createState() => _TicketPortalScreenState();
}

class _TicketPortalScreenState extends State<TicketPortalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _issueController = TextEditingController();
  String? _selectedCategory;
  List<Ticket> tickets = [];
  bool isLoading = true; // To show a loading indicator while fetching data

  @override
  void initState() {
    super.initState();
    fetchTickets(); // Fetch ticket data when the screen loads
  }

  Future<void> fetchTickets() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/getTickets'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey("data")) {
          List<Ticket> loadedTickets = (responseData["data"] as List)
              .map((ticketJson) => Ticket.fromJson(ticketJson))
              .toList();

          setState(() {
            tickets = loadedTickets;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load tickets');
      }
    } catch (error) {
      print("Error fetching tickets: $error");
      setState(() => isLoading = false);
    }
  }

void addTicket() async {
  if (_formKey.currentState!.validate()) {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/raiseIssue'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'issue': _issueController.text,
          'category': _selectedCategory,
        }),
      );

      if (response.statusCode == 200) {
        // Clear the form inputs
        _issueController.clear();
        setState(() => _selectedCategory = null);
        
        // Fetch updated tickets list
        fetchTickets();
      } else {
        print("Failed to raise issue: ${response.body}");
      }
    } catch (error) {
      print("Error adding ticket: $error");
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Ticket Raising Portal", style: TextStyle(color: secondaryColor)),
        backgroundColor: cardBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Raise a Ticket", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: secondaryColor)),
                  SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: _issueController,
                    style: TextStyle(color: secondaryColor),
                    decoration: InputDecoration(
                      labelText: "Describe your issue",
                      labelStyle: TextStyle(color: selectionColor),
                      border: OutlineInputBorder(borderSide: BorderSide(color: selectionColor)),
                    ),
                    validator: (value) => value!.isEmpty ? "Issue cannot be empty" : null,
                  ),
                  SizedBox(height: defaultPadding),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: Text("Select a Category", style: TextStyle(color: selectionColor)),
                    dropdownColor: secondaryColor2,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide(color: selectionColor)),
                    ),
                    items: ["Pest Control", "Irrigation", "Soil Health", "Fertilizers", "Machinery"]
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category, style: TextStyle(color: secondaryColor)),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value),
                    validator: (value) => value == null ? "Please select a category" : null,
                  ),
                  SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: addTicket,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    child: Text("Submit Ticket", style: TextStyle(color: secondaryColor2)),
                  ),
                  SizedBox(height: defaultPadding),
                  Text("Raised Tickets", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: secondaryColor)),
                  SizedBox(height: defaultPadding),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryColor))
                  : tickets.isEmpty
                      ? Center(child: Text("No tickets raised yet!", style: TextStyle(color: secondaryColor)))
                      : ListView.builder(
                          itemCount: tickets.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: cardBackgroundColor,
                              elevation: 3,
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(tickets[index].issue, style: TextStyle(color: secondaryColor)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Category: ${tickets[index].category}", style: TextStyle(color: selectionColor)),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text("Status: ", style: TextStyle(color: secondaryColor)),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: tickets[index].status == "Pending"
                                                ? Colors.orange
                                                : tickets[index].status == "Resolved"
                                                    ? Colors.green
                                                    : Colors.red,
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            tickets[index].status,
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
