import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'another_screen2.dart';
import '../widgets/colors.dart';

class AnotherScreen extends StatefulWidget {
  const AnotherScreen({super.key});

  @override
  _AnotherScreenState createState() => _AnotherScreenState();
}

class _AnotherScreenState extends State<AnotherScreen> {
  final int _highlightedCircleIndex = 0;

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
                minHeight: screenHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: screenHeight * 0.1),
                      Text(
                        'Smart \nNotifications',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          fontSize: screenWidth * 0.12,
                          color: yellow1,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      Text(
                        'TaskMate sends timely notifications based on the task details and user defined frequency.',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'LeagueSpartanMedium',
                          fontSize: screenWidth * 0.08,
                          color: blue1,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCircle(0, screenWidth),
                          SizedBox(width: screenWidth * 0.02),
                          _buildCircle(1, screenWidth),
                          SizedBox(width: screenWidth * 0.02),
                          _buildCircle(2, screenWidth),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'Next',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AnotherScreen2()),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(int index, double screenWidth) {
    return Container(
      width: screenWidth * 0.025,
      height: screenWidth * 0.025,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _highlightedCircleIndex == index ? Colors.white : Colors.grey,
      ),
    );
  }
}
