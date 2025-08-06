import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/colors.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import '../widgets/ContactService.dart'; // Import your ContactService class

class AnotherScreen3 extends StatefulWidget {
  const AnotherScreen3({super.key});

  @override
  _AnotherScreenState createState() => _AnotherScreenState();
}

class _AnotherScreenState extends State<AnotherScreen3> {
  final int _highlightedCircleIndex = 2;
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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: screenHeight * 0.1),
                      
                      Text(
                        'Contact-Centric Task Management',
                        style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          fontSize: screenWidth * 0.12,
                          color: yellow1,
                          height: 1,
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.05),
                      
                      Text(
                        'TaskMate organizes tasks around your contacts, allowing you to view and manage all tasks related to a specific person.',
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
                      
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: double.infinity,
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
                          ),
                          SizedBox(height: screenHeight * 0.02),
                        ],
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
