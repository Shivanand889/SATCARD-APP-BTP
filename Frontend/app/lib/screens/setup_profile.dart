import 'dart:convert'; // To use jsonEncode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the http package
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package
import 'package:google_sign_in/google_sign_in.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});
  
  @override
  _SetupProfileScreenState createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // final GoogleSignIn _googleSignIn = GoogleSignIn(); // Initialize GoogleSignIn
  bool _obscurePassword = true; // For password visibility toggle
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email', // Include this scope to request access to the email address
      'profile', // Include this scope to request access to the user's profile information
    ],
  );
  Future<void> _handleSignup() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    } else {
      try {
        // Sending a POST request to the server
        var response = await http.post(
          Uri.parse('http://127.0.0.1:8000/otp?type=1'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'name': name,
            'email': email,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          // Navigate to the OTP screen on success
          Navigator.pushNamed(context, '/otp');
        } else {
          // Show error message if the status code isn't 200
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}')),
          );
        }
      } catch (e) {
        // Show an error message in case of a failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign up: $e')),
        );
      }
    }
  }

  // Google Sign-Up Button Handler
  Future<void> _handleGoogleSignup() async {
    try {
      // Initiate the sign-in process
      print('Starting Google sign-in');
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('Google sign-in canceled by the user.');
        return;
      }

      // Obtain the auth details from the request
      final String displayName = googleUser.displayName ?? "No name";
      final String email = googleUser.email;
      print('Google ID Token received: $displayName');
      print('Google Access Token received: $email');

     
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/gauth'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': displayName,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        print('Google login successful');
        // Handle successful login or signup
        Navigator.pushNamed(context, '/');
      } else {
        print('Google login failed: ${response.body}');
       
      }
    } catch (e) {
      print('An error occurred during Google login: $e');
      
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width * 0.85, // 85% of the screen width
          constraints: const BoxConstraints(maxWidth: 400), // Max width for larger screens
          decoration: BoxDecoration(
            color: Colors.white, // Background color of the container
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Shadow for elevation effect
                blurRadius: 10.0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Container adjusts to its contents
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Name Field
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Email Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign-Up Button
                ElevatedButton(
                  onPressed: _handleSignup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Rounded button
                    ),
                  ),
                  child: const Text('Sign Up'),
                ),
                const SizedBox(height: 20),

                // OR Divider
                const Row(
                  children: [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),

                // Google Sign-Up Button
                ElevatedButton.icon(
                  onPressed: _handleGoogleSignup, // Handle Google Sign-Up here
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Sign Up with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Google branding color
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Rounded button
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Sign-Up Button Handler
  
}
