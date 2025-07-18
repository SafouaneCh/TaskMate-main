import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/ContactService.dart';
import '../widgets/ContactProvider.dart';
import '../widgets/task_card.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:taskmate/widgets/custom_bottom_bar.dart' as widget;
import 'package:taskmate/screens/home_screen.dart';
import 'package:taskmate/screens/calendar_screen.dart';
import 'package:taskmate/screens/settings_screen.dart';
import 'package:taskmate/widgets/add_task_popup.dart';

void showAddTaskModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return AddTaskModal(
        onTaskAdded: (TaskCard task) {
          // Handle the added task here
        },
      );
    },
  );
}

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final ContactService _contactService = ContactService();
  final ContactProvider _contactProvider = ContactProvider();

  int _selectedIndex = 2;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _getPermissionsAndFetchContacts();
  }

  Future<void> _getPermissionsAndFetchContacts() async {
    PermissionStatus permissionStatus = await _contactService.getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      List<Contact> contacts = await _contactService.fetchContacts();
      setState(() {
        _contactProvider.setContacts(contacts);
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied to access contacts')),
      );
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission permanently denied. Please enable in settings.')),
      );
    }
  }

  void _filterContacts(String query) {
    setState(() {
      _searchQuery = query;
      _contactProvider.filterContacts(query);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => ContactScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              _buildAppBar(),
              SizedBox(height: 20),
              _buildSearchBar(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/utilisateur.png'),
                  ),
                  title: Text(
                    'Akram Zouitni',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Me',
                    style: TextStyle(
                      fontSize: 18,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF727F86),
                    ),
                  ),
                ),
              ),
              Divider(thickness: 1),
              _buildContactList(),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: widget.CustomBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      title: Text(
        'Contacts',
        style: TextStyle(
          color: Colors.black,
          fontSize: 45,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: _filterContacts,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            fontSize: 18,
            fontFamily: 'Roboto',
            color: Colors.grey,
          ),
          prefixIcon: Icon(Icons.search),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
  Map<String, List<Contact>> _groupContactsByInitial() {
    Map<String, List<Contact>> groupedContacts = {};
    for (var contact in _contactProvider.filteredContacts) {
      String initial = contact.displayName?.substring(0, 1).toUpperCase() ?? '';
      if (!groupedContacts.containsKey(initial)) {
        groupedContacts[initial] = [];
      }
      groupedContacts[initial]!.add(contact);
    }
    return groupedContacts;
  }


  Widget _buildContactList() {
    final groupedContacts = _groupContactsByInitial();

    return Expanded(
      child: ListView(
        children: groupedContacts.entries.map((entry) {
          String initial = entry.key;
          List<Contact> contacts = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 19,
                    color: Color(0xFF727F86),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...contacts.map((contact) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(contact.initials()),
                      backgroundColor: Colors.blueAccent,
                    ),
                    title: Text(
                      contact.displayName ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }



  Widget _buildFloatingActionButton() {
    return GestureDetector(
      onTap: () => showAddTaskModal(context),
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
    );
  }
}
