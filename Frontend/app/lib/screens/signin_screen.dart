import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/widgets/custom_scarffold.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';  // Import the logging package

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  bool isEmailLogin = true;
  String errorMessage = '';

  // Create an instance of GoogleSignIn
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email', // Include this scope to request access to the email address
      'profile', // Include this scope to request access to the user's profile information
    ],
  );

  // Set up a logger
  final Logger _logger = Logger('LoginScreenLogger');

  Future<void> _login() async {
    final url = isEmailLogin
        ? 'http://127.0.0.1:8000/loginEmail'
        : 'http://127.0.0.1:8000/loginPhone';
    
    final data = isEmailLogin
        ? {
            'email': _emailController.text,
            'password': _passwordController.text,
            'type' : '1',
          }
        : {
            'phone': _mobileController.text,
            'password': _passwordController.text,
          };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == 1) {
        _logger.info('Login successful');
        // Redirect to another page on successful login
        Navigator.pushNamed(context, '/dashboard');
      } else {
        _logger.warning('Login failed: ${responseBody['message'] ?? 'Unknown error'}');
        setState(() {
          errorMessage = responseBody['message'] ?? 'Login failed';
        });
      }
    } catch (e) {
      _logger.severe('An error occurred during login: $e');
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  Future<void> _LoginGoogle() async {
    print("1") ;
    try {
      // Initiate the sign-in process
      _logger.info('Starting Google sign-in');
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _logger.info('Google sign-in canceled by the user.');
        return;
      }

      // Obtain the auth details from the request
      final String displayName = googleUser.displayName ?? "No name";
      final String email = googleUser.email;
      _logger.info('Google ID Token received: $displayName');
      _logger.info('Google Access Token received: $email');

     
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/loginEmail'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          // 'name': displayName,
          'email': email,
          'type' : '2',
        }),
      );

      if (response.statusCode == 200) {
        _logger.info('Google login successful');
        // Handle successful login or signup
        Navigator.pushNamed(context, '/dashboard');
      } else {
        _logger.warning('Google login failed: ${response.body}');
        setState(() {
          errorMessage = 'Google login failed: ${response.body}';
          return ;
        });
      }
    } catch (e) {
      _logger.severe('An error occurred during Google login: $e');
      setState(() {
        errorMessage = 'An error occurred during Google login: $e';
        return ;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              SwitchListTile(
                title: Text(isEmailLogin ? 'Login with Email' : 'Login with Mobile'),
                value: isEmailLogin,
                onChanged: (val) {
                  setState(() {
                    isEmailLogin = val;
                  });
                },
              ),
              const SizedBox(height: 20),
              if (isEmailLogin)
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                )
              else
                TextFormField(
                  controller: _mobileController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _LoginGoogle,
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Login with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
