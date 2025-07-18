import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'another_screen2.dart';
import 'welcome_screen.dart';
import '../widgets/colors.dart';

class AnotherScreen extends StatefulWidget {
  @override
  _AnotherScreenState createState() => _AnotherScreenState();
}

class _AnotherScreenState extends State<AnotherScreen> {
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
                'Smart \nNotifications',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'LeagueSpartan',
                  fontSize: 48,
                  color: yellow1,
                  height: 1,
                ),
              ),
              Spacer(flex: 1),
              Text(
                'TaskMate sends timely notifications based on the task details and user defined frequency.',
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
                  _buildCircle(0),
                  SizedBox(width: 10),
                  _buildCircle(1),
                  SizedBox(width: 10),
                  _buildCircle(2),
                ],
              ),
              Spacer(flex: 1),
              Align(
                alignment: Alignment.center,
                child: CustomButton(
                  text: 'Next',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AnotherScreen2()),
                    );
                  },
                ),
              ),
              Spacer(flex: 2),
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