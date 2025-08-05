import 'package:flutter/material.dart';
import '../widgets/logo.dart';
import '../widgets/custom_button.dart';
import 'another_screen.dart'; // Import the AnotherScreen widget
import '../widgets/colors.dart'; // Assurez-vous que le chemin est correct

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Copy of Welcome - 1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Logo(),
            SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Enjoy your life with ',
                      style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 75,
                        height: 0.9,
                        fontWeight: FontWeight.bold,
                        color: blue1, // Couleur bleue pour "Welcome to"
                      ),
                    ),
                    TextSpan(
                      text: 'TaskMate',
                      style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 80,
                        height: 0.9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Couleur jaune pour "TaskMate"
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 60.0), // Ajoutez du padding ici
            ),
            SizedBox(height: 60),
            CustomButton(
              text: '   Welcome   ',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnotherScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
