import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'another_screen3.dart';
import '../widgets/colors.dart';

class AnotherScreen2 extends StatefulWidget {
  @override
  _AnotherScreenState createState() => _AnotherScreenState();
}

class _AnotherScreenState extends State<AnotherScreen2> {
  int _highlightedCircleIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Copy of Welcome - 1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Spacer(flex: 2),
              Text(
                'AI-Powered Task Analysis',
                style: TextStyle(
                  fontFamily: 'LeagueSpartan',
                  fontSize: 48,
                  color: yellow1,
                  height: 1,
                ),
              ),
              Spacer(flex: 1),
              Text(
                'TaskMate uses AI to analyze your task messages and automatically extract key details such as the person, time, and task.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'LeagueSpartanMedium',
                  fontSize: 33,
                  color: blue1,
                  height: 1.2,
                ),
              ),
              Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircle(1),
                  SizedBox(width: 10),
                  _buildCircle(0),
                  SizedBox(width: 10),
                  _buildCircle(2),
                ],
              ),
              Spacer(flex: 1),
              Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: CustomButton(
                      text: 'Next',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AnotherScreen3()),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20), // Add spacing between buttons
                ],
              ),
              Spacer(
                  flex:
                      1), // Adding a Spacer to ensure flexible spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(int index) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _highlightedCircleIndex == index ? Colors.white : Colors.grey,
      ),
    );
  }
}
