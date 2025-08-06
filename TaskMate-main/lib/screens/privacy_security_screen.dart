import 'package:flutter/material.dart';
import '../widgets/custom_bottom_bar.dart';
import 'home_screen.dart' as home;
import 'calendar_screen.dart';
import 'contact_management_screen.dart';
import 'settings_screen.dart';
import '../core/services/sp_service.dart';
import '../repository/auth_remote_repository.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  _PrivacySecurityScreenState createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final int selectedIndex = 3;
  final SpService _spService = SpService();
  final AuthRemoteRepository _authRepository = AuthRemoteRepository();
  bool biometricAuth = false;
  bool autoLock = true;
  bool dataSync = true;
  bool analytics = false;

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  Future<void> _loadSecuritySettings() async {
    final settings = await _spService.getSecuritySettings();
    setState(() {
      biometricAuth = settings['biometric_auth']!;
      autoLock = settings['auto_lock']!;
      dataSync = settings['data_sync']!;
      analytics = settings['analytics']!;
    });
  }

  Future<void> _saveSecuritySettings() async {
    await _spService.setSecuritySettings(
      biometricAuth: biometricAuth,
      autoLock: autoLock,
      dataSync: dataSync,
      analytics: analytics,
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

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentPassword = currentPasswordController.text;
                final newPassword = newPasswordController.text;
                final confirmPassword = confirmPasswordController.text;

                if (currentPassword.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('New passwords do not match')),
                  );
                  return;
                }

                try {
                  await _authRepository.changePassword(
                    currentPassword: currentPassword,
                    newPassword: newPassword,
                  );

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password changed successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: Text('Change'),
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
              'Privacy & Security',
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
                        _buildSecurityItem(
                          icon: Icons.fingerprint,
                          title: 'Biometric Authentication',
                          subtitle: 'Use fingerprint or face ID to unlock',
                          value: biometricAuth,
                          onChanged: (value) async {
                            setState(() {
                              biometricAuth = value;
                            });
                            await _saveSecuritySettings();
                          },
                          screenWidth: screenWidth,
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        _buildSecurityItem(
                          icon: Icons.lock,
                          title: 'Auto Lock',
                          subtitle: 'Lock app when inactive',
                          value: autoLock,
                          onChanged: (value) async {
                            setState(() {
                              autoLock = value;
                            });
                            await _saveSecuritySettings();
                          },
                          screenWidth: screenWidth,
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        _buildSecurityItem(
                          icon: Icons.sync,
                          title: 'Data Sync',
                          subtitle: 'Sync data across devices',
                          value: dataSync,
                          onChanged: (value) async {
                            setState(() {
                              dataSync = value;
                            });
                            await _saveSecuritySettings();
                          },
                          screenWidth: screenWidth,
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        _buildSecurityItem(
                          icon: Icons.analytics,
                          title: 'Analytics',
                          subtitle: 'Share usage data to improve app',
                          value: analytics,
                          onChanged: (value) async {
                            setState(() {
                              analytics = value;
                            });
                            await _saveSecuritySettings();
                          },
                          screenWidth: screenWidth,
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        ListTile(
                          leading: Icon(
                            Icons.lock_outline,
                            size: screenWidth * 0.06,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'Update your account password',
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
                          onTap: _showChangePasswordDialog,
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

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required double screenWidth,
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }
}
