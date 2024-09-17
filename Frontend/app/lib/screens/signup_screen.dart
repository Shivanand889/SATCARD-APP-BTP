import 'package:flutter/material.dart';
import 'package:app/widgets/custom_scarffold.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _mobileController = TextEditingController();

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
              TextField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/otp');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Rounded button
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
