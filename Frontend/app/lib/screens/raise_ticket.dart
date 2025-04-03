import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
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
  String? imageUrl;

  Ticket({required this.issue, required this.category, this.status = "Pending", this.imageUrl});

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      issue: json['issue'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 'Pending',
      imageUrl: json['imageUrl'],
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
  File? _selectedImage;
  List<Ticket> tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTickets();
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

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> addTicket() async {
    if (_formKey.currentState!.validate()) {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://127.0.0.1:8000/raiseIssue'),
        );

        request.fields['issue'] = _issueController.text;
        request.fields['category'] = _selectedCategory!;

        if (_selectedImage != null) {
          request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
        }

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          _issueController.clear();
          setState(() {
            _selectedCategory = null;
            _selectedImage = null;
          });

          fetchTickets();
        } else {
          print("Failed to raise issue: $responseBody");
        }
      } catch (error) {
        print("Error adding ticket: $error");
      }
    }
  }

  void _showTicketDetails(BuildContext context, Ticket ticket) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: cardBackgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Keeps title & status separate
          children: [
            Text("Ticket Details", style: TextStyle(color: secondaryColor)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ticket.status == "Pending" ? Colors.orange : Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ticket.status,
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Issue: ${ticket.issue}", style: TextStyle(color: secondaryColor)),
            SizedBox(height: 8),
            Text("Category: ${ticket.category}", style: TextStyle(color: selectionColor)),
            SizedBox(height: 8),
            Text("Image:", style: TextStyle(color: selectionColor)),
            SizedBox(height: 8),
            if (ticket.imageUrl != null)
              Image.network(ticket.imageUrl!, height: 150, width: 150, fit: BoxFit.cover),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(color: Color.fromARGB(255, 184, 187, 199))),
          ),
        ],
      );
    },
  );
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
                    onPressed: pickImage,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    child: Text("Upload Photo", style: TextStyle(color: secondaryColor2)),
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.file(_selectedImage!, height: 100, width: 100),
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
            SizedBox(height: defaultPadding),
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
                              child: ListTile(
                                title: Text(tickets[index].issue, style: TextStyle(color: secondaryColor)),
                                subtitle: Text("Category: ${tickets[index].category}\nStatus: ${tickets[index].status}",
                                    style: TextStyle(color: selectionColor)),
                                onTap: () => _showTicketDetails(context, tickets[index]),
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
