import 'package:app/widgets/custom_scarffold.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 500.0, vertical: 100.0), // Padding 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Vertically aligns to the top
              crossAxisAlignment: CrossAxisAlignment.center, // Horizontally aligns to the center
              children: [
                // Welcome Text
                Text(
                  'Welcome to Smart Agriculture',
                  style: TextStyle(
                    fontSize: 30.0, 
                    fontWeight: FontWeight.w900,
                    color: Colors.greenAccent[400], 
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center, 
                ),
                const SizedBox(height: 15.0),
                // const SizedBox(width: 100.0),

                // Description
                Text(
                  'Revolutionize your farming experience with data-driven solutions.',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9), 
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center, 
                ),
                const SizedBox(height: 40.0),

                // Start Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login'); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent[700], 
                    padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 8.0,
                    textStyle: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
