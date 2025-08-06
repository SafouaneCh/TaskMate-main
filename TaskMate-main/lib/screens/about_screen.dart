import 'package:flutter/material.dart';
import '../widgets/custom_bottom_bar.dart';
import 'home_screen.dart' as home;
import 'calendar_screen.dart';
import 'contact_management_screen.dart';
import 'settings_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final int selectedIndex = 3;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => home.HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CalendarScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ContactScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return SafeArea(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'About',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  // App Logo and Version
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(screenWidth * 0.025),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            width: screenWidth * 0.2,
                            height: screenWidth * 0.2,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            'TaskMate',
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  // App Information
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(screenWidth * 0.025),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.description,
                            size: screenWidth * 0.06,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Description',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'TaskMate is a powerful task management app designed to help you organize your life and boost productivity.',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        ListTile(
                          leading: Icon(
                            Icons.developer_mode,
                            size: screenWidth * 0.06,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Developer',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'TaskMate Development Team',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        ListTile(
                          leading: Icon(
                            Icons.email,
                            size: screenWidth * 0.06,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Contact',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'support@taskmate.com',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Email client opened')),
                            );
                          },
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        ListTile(
                          leading: Icon(
                            Icons.language,
                            size: screenWidth * 0.06,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Website',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'www.taskmate.com',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Website opened')),
                            );
                          },
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        ListTile(
                          leading: Icon(
                            Icons.privacy_tip,
                            size: screenWidth * 0.06,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'Read our privacy policy',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Privacy policy opened')),
                            );
                          },
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        ListTile(
                          leading: Icon(
                            Icons.description_outlined,
                            size: screenWidth * 0.06,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Terms of Service',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'Read our terms of service',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Terms of service opened')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
          ),
          bottomNavigationBar: CustomBottomBar(
            selectedIndex: selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
