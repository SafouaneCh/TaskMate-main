import 'package:flutter/material.dart';
import '../widgets/custom_bottom_bar.dart';
import 'home_screen.dart' as home;
import 'calendar_screen.dart';
import 'contact_management_screen.dart';
import 'settings_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  _HelpSupportScreenState createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
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

  void _showFAQDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Frequently Asked Questions'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Q: How do I create a new task?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                    'A: Tap the + button in the center of the bottom navigation bar.'),
                SizedBox(height: 16),
                Text(
                  'Q: How do I edit my profile?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('A: Go to Settings and tap on your profile card.'),
                SizedBox(height: 16),
                Text(
                  'Q: How do I sync my data?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                    'A: Go to Settings > Privacy & Security and enable Data Sync.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showContactSupportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact Support'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Email Support'),
                subtitle: Text('support@taskmate.com'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email support opened')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('Phone Support'),
                subtitle: Text('+1 (555) 123-4567'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Phone support opened')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.chat),
                title: Text('Live Chat'),
                subtitle: Text('Available 24/7'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Live chat opened')),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
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
              'Help & Support',
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(screenWidth * 0.025),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.question_answer,
                            size: screenWidth * 0.06,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'FAQ',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'Frequently asked questions',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: screenWidth * 0.05,
                            color: Colors.grey[400],
                          ),
                          onTap: _showFAQDialog,
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        ListTile(
                          leading: Icon(
                            Icons.contact_support,
                            size: screenWidth * 0.06,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Contact Support',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'Get help from our support team',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: screenWidth * 0.05,
                            color: Colors.grey[400],
                          ),
                          onTap: _showContactSupportDialog,
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        ListTile(
                          leading: Icon(
                            Icons.book,
                            size: screenWidth * 0.06,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'User Guide',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'Learn how to use TaskMate',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: screenWidth * 0.05,
                            color: Colors.grey[400],
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('User guide opened')),
                            );
                          },
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        ListTile(
                          leading: Icon(
                            Icons.bug_report,
                            size: screenWidth * 0.06,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Report a Bug',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'Help us improve the app',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: screenWidth * 0.05,
                            color: Colors.grey[400],
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Bug report form opened')),
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
