import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;  // Import the http package
import 'dart:convert';  // Import to encode the data into JSON
import 'package:app/responsive.dart';

class AddFarm extends StatefulWidget {
  const AddFarm({super.key});

  @override
  _AddFarmState createState() => _AddFarmState();
}

class _AddFarmState extends State<AddFarm> {
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _cropNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _soilTypeController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  // Function to call API
  Future<void> addFarm() async {
    // Prepare the farm data
    final Map<String, String> farmData = {
      'name': _farmNameController.text,
      'crop': _cropNameController.text,
      'location': _locationController.text,
      'soil': _soilTypeController.text,
      'area': _areaController.text,
    };

    // Make the POST request
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/addFarm'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(farmData),
    );

    if (response.statusCode == 200) {
    // Success: Clear the fields and refresh the page
    _farmNameController.clear();
    _cropNameController.clear();
    _locationController.clear();
    _soilTypeController.clear();
    _areaController.clear();

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Farm added successfully!')),
    );

    
  } else {
    // Failure: Show an error message
    final errorMessage = json.decode(response.body)['message'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add farm: $errorMessage')),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 5),
                const Text(
                  "Add Your Farm Details",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? Responsive.widthOfScreen(context) * 0.9
                      : Responsive.widthOfScreen(context) * 0.7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0XFFC4ACA1),
                            blurRadius: 4,
                            spreadRadius: 2),
                      ],
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          farmField("Farm Name*", 1, "name", _farmNameController),
                          farmField("Crop Name*", 1, "crop", _cropNameController),
                          farmField("Location*", 1, "location", _locationController),
                          farmField("Soil Type*", 1, "soil", _soilTypeController),
                          farmField("Area in acres*", 1, "area", _areaController),
                          farmField("Assign the Co-worker*", 1, "worker", _areaController),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.blue),
                                  onPressed: addFarm, // Call addFarm on press
                                  child: const Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  farmField(String name, int maxLine, String hintText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextField(
              controller: controller,
              maxLines: maxLine,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}