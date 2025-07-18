import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/custom_bottom_bar.dart';
import 'home_screen.dart';
import 'EditProfileScreen.dart';
import 'calendar_screen.dart';
import 'contact_management_screen.dart';
import '../widgets/add_task_popup.dart';
import '../widgets/task_card.dart';

class SettingsScreen extends StatefulWidget {
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
          MaterialPageRoute(builder: (context) => HomeScreen()),
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
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            SizedBox(height: 10), // Adds space before the AppBar
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
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToEditProfile(context),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage('assets/utilisateur.png'),
                          radius: 21,
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit,
                              color: Colors.black,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Edit profile',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Poppins',
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              toolbarHeight: 100,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40),
                      Text(
                        'Notifications Settings',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 2.0),
                          title: Text(
                            'Enable/Disable notifications',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 17),
                          ),
                          trailing: Switch(
                            value: false,
                            onChanged: (bool value) {},
                          ),
                        ),
                      ),
                      Divider(thickness: 1.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 2.0),
                          title: Text(
                            'Notifications frequency',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 17),
                          ),
                          trailing: DropdownButton<String>(
                            items: [
                              DropdownMenuItem<String>(
                                value: 'Daily',
                                child: Text('Daily'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Weekly',
                                child: Text('Weekly'),
                              ),
                            ],
                            onChanged: (String? value) {},
                            hint: Text(
                              'Select one',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 17),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'General',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 2.0),
                          title: Text(
                            'Password',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 17),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {},
                        ),
                      ),
                      Divider(thickness: 1.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 2.0),
                          title: Text(
                            'Share App',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 17),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {},
                        ),
                      ),
                      Divider(thickness: 1.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 2.0),
                          title: Text(
                            'Data Backup',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 17),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {},
                        ),
                      ),
                      Divider(thickness: 1.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 2.0),
                          title: Text(
                            'Log out',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 17),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: GestureDetector(
          onTap: () => _showAddTaskModal(context),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27.5),
              gradient: LinearGradient(
                begin: Alignment(0, -1),
                end: Alignment(0, 1),
                colors: <Color>[Color(0xFF074666), Color(0xFF0E81BD), Color(0xFFFFFFFF)],
                stops: <double>[0, 1, 1],
              ),
            ),
            child: Container(
              width: 55,
              height: 55,
              padding: EdgeInsets.all(18.5),
              child: SvgPicture.asset(
                'assets/vectors/vector_7_x2.svg',
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: CustomBottomBar(
          selectedIndex: selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
