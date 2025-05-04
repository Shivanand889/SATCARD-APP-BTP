import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:app/const/constant.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  @override
  _DiseaseDetectionScreenState createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _result;
  bool _isLoading = false;

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      setState(() {
        _selectedImage = File(pickedImage.path);
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> detectDisease() async {
  if (_selectedImageBytes == null) return;

  setState(() {
    _isLoading = true;
    _result = null;
  });

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/diseaseDetection'),
    );

    // Using MultipartFile.fromBytes
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      _selectedImageBytes!,
      filename: 'disease_image.jpg',
    ));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      setState(() {
        _result = responseBody;
      });
    } else {
      print("Failed: $responseBody");
      setState(() {
        _result = "Failed to detect disease.";
      });
    }
  } catch (e) {
    print("Error during detection: $e");
    setState(() {
      _result = "Error: $e";
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Disease Detection", style: TextStyle(color: secondaryColor)),
        backgroundColor: cardBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickImage,
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: Text("Pick Image", style: TextStyle(color: secondaryColor2)),
            ),
            if (_selectedImageBytes != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.memory(_selectedImageBytes!, height: 150, width: 150),
              ),
            SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: detectDisease,
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: Text("Detect Disease", style: TextStyle(color: secondaryColor2)),
            ),
            SizedBox(height: defaultPadding),
            if (_isLoading)
              CircularProgressIndicator(color: primaryColor)
            else if (_result != null)
              Text(_result!, style: TextStyle(color: secondaryColor)),
          ],
        ),
      ),
    );
  }
}
