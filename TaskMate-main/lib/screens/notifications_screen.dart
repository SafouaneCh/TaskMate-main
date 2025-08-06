import 'package:flutter/material.dart';
import '../widgets/custom_bottom_bar.dart';
import 'home_screen.dart' as home;
import 'calendar_screen.dart';
import 'contact_management_screen.dart';
import 'settings_screen.dart';
import '../core/services/sp_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final int selectedIndex = 3;
  final SpService _spService = SpService();
  bool pushNotifications = true;
  bool emailNotifications = false;
  bool taskReminders = true;
  bool dailyDigest = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final settings = await _spService.getNotificationSettings();
    setState(() {
      pushNotifications = settings['push_notifications']!;
      emailNotifications = settings['email_notifications']!;
      taskReminders = settings['task_reminders']!;
      dailyDigest = settings['daily_digest']!;
    });
  }

  Future<void> _saveNotificationSettings() async {
    await _spService.setNotificationSettings(
      pushNotifications: pushNotifications,
      emailNotifications: emailNotifications,
      taskReminders: taskReminders,
      dailyDigest: dailyDigest,
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
              'Notifications',
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
                        _buildNotificationItem(
                          title: 'Push Notifications',
                          subtitle: 'Receive notifications on your device',
                          value: pushNotifications,
                          onChanged: (value) async {
                            setState(() {
                              pushNotifications = value;
                            });
                            await _saveNotificationSettings();
                          },
                          screenWidth: screenWidth,
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        _buildNotificationItem(
                          title: 'Email Notifications',
                          subtitle: 'Receive notifications via email',
                          value: emailNotifications,
                          onChanged: (value) async {
                            setState(() {
                              emailNotifications = value;
                            });
                            await _saveNotificationSettings();
                          },
                          screenWidth: screenWidth,
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        _buildNotificationItem(
                          title: 'Task Reminders',
                          subtitle: 'Get reminded about upcoming tasks',
                          value: taskReminders,
                          onChanged: (value) async {
                            setState(() {
                              taskReminders = value;
                            });
                            await _saveNotificationSettings();
                          },
                          screenWidth: screenWidth,
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        _buildNotificationItem(
                          title: 'Daily Digest',
                          subtitle: 'Receive a daily summary of your tasks',
                          value: dailyDigest,
                          onChanged: (value) async {
                            setState(() {
                              dailyDigest = value;
                            });
                            await _saveNotificationSettings();
                          },
                          screenWidth: screenWidth,
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

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required double screenWidth,
  }) {
    return ListTile(
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }
}
