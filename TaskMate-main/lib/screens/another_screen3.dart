import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/colors.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import '../widgets/ContactService.dart'; // Import your ContactService class

class AnotherScreen3 extends StatefulWidget {
  @override
  _AnotherScreenState createState() => _AnotherScreenState();
}

class _AnotherScreenState extends State<AnotherScreen3> {
  int _highlightedCircleIndex = 0;
  final ContactService _contactService = ContactService();

  @override
  void initState() {
    super.initState();
    _checkAndRequestContactPermission();
  }

  Future<void> _checkAndRequestContactPermission() async {
    PermissionStatus permissionStatus = await _contactService.requestPermission();

    if (permissionStatus != PermissionStatus.granted) {
      _showPermissionDialog();
    }
  }

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
                'Contact-Centric Task Management',
                style: TextStyle(
                  fontFamily: 'LeagueSpartan',
                  fontSize: 48,
                  color: yellow1,
                  height: 1,
                ),
              ),
              Spacer(flex: 1),
              Text(
                'TaskMate organizes tasks around your contacts, allowing you to view and manage all tasks related to a specific person.',
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
                  _buildCircle(2),
                  SizedBox(width: 10),
                  _buildCircle(0),
                ],
              ),
              Spacer(flex: 1),
              Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: CustomButton(
                      text: 'Log in',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20), // Add spacing between buttons
                ],
              ),
              Spacer(flex: 1),
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

  // Method to show a permission dialog if contacts are not authorized
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contacts Permission Required'),
          content: Text('This app requires permission to access contacts. Please grant permission in your device settings.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
