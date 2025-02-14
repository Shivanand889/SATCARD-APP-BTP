import 'package:app/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/welcome_screen.dart';
import 'package:app/screens/signin_screen.dart';
import 'package:app/screens/signup_screen.dart';
import 'package:app/screens/reset_password_screen.dart';
import 'package:app/screens/otp_screen.dart';
import 'package:app/screens/setup_profile.dart';
import 'package:app/screens/raise_ticket.dart';
import 'package:logging/logging.dart';
void main() {
  _initializeLogger();

  runApp(const MyApp());
}

void _initializeLogger() {
  // Set the root logger level
  Logger.root.level = Level.ALL; // Set the desired log level

  // Listen for log records
  Logger.root.onRecord.listen((LogRecord rec) {
    // You can change this to log to a file, remote server, etc.
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/otp': (context) => const OtpScreen(),
        '/setup-profile': (context) => const SetupProfileScreen(),
        '/dashboard': (context) => const Dashboard(),
        '/raise_ticket': (context) => TicketPortalApp(),
      },
    );
  }
}
