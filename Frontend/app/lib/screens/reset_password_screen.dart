import 'package:flutter/material.dart';
import 'package:app/widgets/custom_scarffold.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _emailController = TextEditingController();

    return CustomScaffold(
      child: Center( // Center the entire container in the middle of the screen
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width * 0.85, // Make the container 85% of the screen width
          constraints: const BoxConstraints(maxWidth: 400), // Max width constraint for larger screens
          decoration: BoxDecoration(
            color: Colors.white, // Set a light background for the container
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Slight shadow for elevation effect
                blurRadius: 10.0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make the container as big as its contents
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Enter your email to receive password reset instructions',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Implement password reset logic here
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Rounded button
                  ),
                ),
                child: const Text('Send Reset Instructions'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
