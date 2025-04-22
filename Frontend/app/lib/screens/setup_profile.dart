import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  final _managerEmailController = TextEditingController();
  bool _obscurePassword = true;
  String _workingType = "Manager"; // default selection

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<void> _handleSignup() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final workingType = _workingType;
    final managerEmail = _managerEmailController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || (_workingType == "Worker" && managerEmail.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('http://127.0.0.1:8000/otp?type=1'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'working_type': workingType,
          'manager_email': workingType == "Worker" ? managerEmail : "",
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushNamed(context, '/otp');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign up: $e')),
      );
    }
  }

  Future<void> _handleGoogleSignup() async {
    try {
      print('Starting Google sign-in');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('Google sign-in canceled by the user.');
        return;
      }

      final String displayName = googleUser.displayName ?? "No name";
      final String email = googleUser.email;

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/gauth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': displayName, 'email': email}),
      );

      if (response.statusCode == 200) {
        print('Google login successful');
        Navigator.pushNamed(context, '/dashboard');
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
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

                // Working Type (Radio Buttons)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Working Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                RadioListTile<String>(
                  title: const Text('Manager'),
                  value: 'Manager',
                  groupValue: _workingType,
                  onChanged: (value) {
                    setState(() {
                      _workingType = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Worker'),
                  value: 'Worker',
                  groupValue: _workingType,
                  onChanged: (value) {
                    setState(() {
                      _workingType = value!;
                    });
                  },
                ),

                // Conditional Manager Email Field
                if (_workingType == 'Worker') ...[
                  TextField(
                    controller: _managerEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Manager Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                ElevatedButton(
                  onPressed: _handleSignup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Sign Up'),
                ),
                const SizedBox(height: 20),
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
                ElevatedButton.icon(
                  onPressed: _handleGoogleSignup,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Sign Up with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
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
}
