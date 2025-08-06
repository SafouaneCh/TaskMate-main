import 'package:flutter/material.dart';
import '../widgets/logo.dart';
import '../widgets/custom_button.dart';
import 'another_screen.dart'; // Import the AnotherScreen widget
import '../widgets/colors.dart'; // Assurez-vous que le chemin est correct

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Copy of Welcome - 1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Top spacer
                    SizedBox(height: screenHeight * 0.05),
                    
                    // Logo with responsive sizing
                    Container(
                      width: screenWidth * 0.6,
                      height: screenWidth * 0.6,
                      constraints: BoxConstraints(
                        maxWidth: 300,
                        maxHeight: 300,
                        minWidth: 200,
                        minHeight: 200,
                      ),
                      child: Logo(),
                    ),
                    
                    // Text section with responsive sizing
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.02,
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Enjoy your life with ',
                              style: TextStyle(
                                fontFamily: 'LeagueSpartan',
                                fontSize: screenWidth * 0.06,
                                height: 0.9,
                                fontWeight: FontWeight.bold,
                                color: blue1,
                              ),
                            ),
                            TextSpan(
                              text: 'TaskMate',
                              style: TextStyle(
                                fontFamily: 'LeagueSpartan',
                                fontSize: screenWidth * 0.065,
                                height: 0.9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Button section
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.02,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: '   Welcome   ',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AnotherScreen()),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    // Bottom spacer
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
