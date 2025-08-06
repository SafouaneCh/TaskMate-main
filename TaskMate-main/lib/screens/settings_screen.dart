import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/custom_bottom_bar.dart';
import 'home_screen.dart' as home;
import 'EditProfileScreen.dart';
import 'calendar_screen.dart';
import 'contact_management_screen.dart';
import '../widgets/add_task_popup.dart';
import '../widgets/task_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final int selectedIndex = 3;

  void _showAddTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddTaskModal(
          onTaskAdded: (TaskCard newTask) {
            // Handle the task addition logic here
          },
        );
      },
    );
  }

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

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
                AppBar(
                  automaticallyImplyLeading: false,
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Settings',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                SizedBox(height: screenHeight * 0.03),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    children: [
                      // Profile Section
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.025),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: screenWidth * 0.08,
                              backgroundImage:
                                  AssetImage('assets/utilisateur.png'),
                            ),
                            SizedBox(width: screenWidth * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Akram',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.055,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'akram@example.com',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _navigateToEditProfile(context),
                              icon: Icon(
                                Icons.edit,
                                size: screenWidth * 0.06,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      // Settings Options
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.025),
                        ),
                        child: Column(
                          children: [
                            _buildSettingsItem(
                              icon: Icons.notifications,
                              title: 'Notifications',
                              subtitle: 'Manage your notifications',
                              onTap: () {},
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                            ),
                            Divider(height: 1, color: Colors.grey[300]),
                            _buildSettingsItem(
                              icon: Icons.security,
                              title: 'Privacy & Security',
                              subtitle: 'Manage your privacy settings',
                              onTap: () {},
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                            ),
                            Divider(height: 1, color: Colors.grey[300]),
                            _buildSettingsItem(
                              icon: Icons.help,
                              title: 'Help & Support',
                              subtitle: 'Get help and contact support',
                              onTap: () {},
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                            ),
                            Divider(height: 1, color: Colors.grey[300]),
                            _buildSettingsItem(
                              icon: Icons.info,
                              title: 'About',
                              subtitle: 'App version and information',
                              onTap: () {},
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      // Logout Button
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle logout
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.025),
                            ),
                          ),
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: GestureDetector(
            onTap: () => _showAddTaskModal(context),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth * 0.07),
                gradient: LinearGradient(
                  begin: Alignment(0, -1),
                  end: Alignment(0, 1),
                  colors: <Color>[
                    Color(0xFF074666),
                    Color(0xFF0E81BD),
                    Color(0xFFFFFFFF)
                  ],
                  stops: <double>[0, 1, 1],
                ),
              ),
              child: Container(
                width: screenWidth * 0.14,
                height: screenWidth * 0.14,
                padding: EdgeInsets.all(screenWidth * 0.045),
                child: SizedBox(
                  width: screenWidth * 0.075,
                  height: screenWidth * 0.075,
                  child: SizedBox(
                    width: screenWidth * 0.045,
                    height: screenWidth * 0.045,
                    child: SvgPicture.asset(
                      'assets/vectors/vector_7_x2.svg',
                    ),
                  ),
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: CustomBottomBar(
            selectedIndex: selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required double screenWidth,
    required double screenHeight,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: screenWidth * 0.06,
        color: Colors.blue,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
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
      onTap: onTap,
    );
  }
}
