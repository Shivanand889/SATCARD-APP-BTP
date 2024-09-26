import 'package:flutter/material.dart';
import 'package:app/widgets/custom_scarffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mobileController = TextEditingController();

    Future<void> sendOtp() async {
      final mobileNumber = mobileController.text;
      final url = Uri.parse('http://127.0.0.1:8000/otp?type=2'); // Your Django backend URL

      try {
        final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'phone': mobileNumber,  // Use 'phone' to match the Django backend
          }),
        );

        if (response.statusCode == 200) {
          // If the server returns an OK response
          final data = jsonDecode(response.body);
          print('OTP Sent Successfully: $data');
          
          // Check for the redirect URL in the response and navigate
          final redirectUrl = data['redirect_url'];
          if (redirectUrl != null) {
            Navigator.pushNamed(context, '/otp'); // Navigate to the OTP input screen
          }
        } else {
          // If the server returns an error response
          print('Failed to send OTP: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }

    return CustomScaffold(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10.0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: sendOtp, // Call the function to send OTP
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Get OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
