import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/ContactProvider.dart';
import '../widgets/task_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taskmate/widgets/custom_bottom_bar.dart' as widget;
import 'package:taskmate/screens/home_screen.dart' as home;
import 'package:taskmate/screens/calendar_screen.dart';
import 'package:taskmate/screens/settings_screen.dart';
import 'package:taskmate/widgets/add_task_popup.dart';
import '../widgets/ContactService.dart';
import '../cubit/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  const ContactScreen({super.key});

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final ContactProvider _contactProvider = ContactProvider();
  int _selectedIndex = 2;
  String _searchQuery = '';
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
      return;
    }

    final contacts = await FlutterContacts.getContacts();
    setState(() {
      _contactProvider.setContacts(contacts);
    });
  }

  void _handleInvalidPermissions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact permissions denied. Please enable in settings.'),
      ),
    );
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
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => home.HomeScreen()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CalendarScreen()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ContactScreen()));
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SettingsScreen()));
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
              const SizedBox(height: 20),
              _buildSearchBar(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    String userName = 'User';
                    if (authState is AuthLoggedIn) {
                      userName = authState.user.name;
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/utilisateur.png'),
                      ),
                      title: Text(
                        userName,
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
                    );
                  },
                ),
              ),
              const Divider(thickness: 1),
              if (_permissionDenied)
                _buildPermissionDeniedWidget()
              else
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

  Widget _buildPermissionDeniedWidget() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Permission to access contacts was denied'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await openAppSettings();
                _fetchContacts();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      title: const Text(
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
          hintStyle: const TextStyle(
            fontSize: 18,
            fontFamily: 'Roboto',
            color: Colors.grey,
          ),
          prefixIcon: const Icon(Icons.search),
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
      String initial = contact.displayName.isNotEmpty
          ? contact.displayName.substring(0, 1).toUpperCase()
          : '';
      if (!groupedContacts.containsKey(initial)) {
        groupedContacts[initial] = [];
      }
      groupedContacts[initial]!.add(contact);
    }

    // Sort the map keys alphabetically
    final sortedKeys = groupedContacts.keys.toList()..sort();
    Map<String, List<Contact>> sortedMap = {};
    for (var key in sortedKeys) {
      sortedMap[key] = groupedContacts[key]!;
    }

    return sortedMap;
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  initial,
                  style: const TextStyle(
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
                      backgroundColor: Colors.blueAccent,
                      child: Text(_getInitials(contact)),
                    ),
                    title: Text(
                      contact.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    subtitle: contact.phones.isNotEmpty
                        ? Text(contact.phones.first.number)
                        : null,
                  ),
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getInitials(Contact contact) {
    if (contact.name.first.isEmpty && contact.name.last.isEmpty) {
      return contact.displayName.isNotEmpty
          ? contact.displayName.substring(0, 1).toUpperCase()
          : '?';
    }
    return '${contact.name.first.isNotEmpty ? contact.name.first[0] : ''}'
            '${contact.name.last.isNotEmpty ? contact.name.last[0] : ''}'
        .toUpperCase();
  }

  Widget _buildFloatingActionButton() {
    return GestureDetector(
      onTap: () => showAddTaskModal(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27.5),
          gradient: const LinearGradient(
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
          width: 55,
          height: 55,
          padding: const EdgeInsets.all(18.5),
          child: SvgPicture.asset(
            'assets/vectors/vector_7_x2.svg',
          ),
        ),
      ),
    );
  }
}
