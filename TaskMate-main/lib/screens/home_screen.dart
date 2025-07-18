import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'contact_management_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import '../widgets/custom_bottom_bar.dart';
import '../widgets/task_data.dart'; // Ensure this import matches the location of your task_data.dart
import '../widgets/add_task_popup.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        setState(() {
          _selectedIndex = index;
        });
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalendarScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ContactScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
        break;
    }
  }

  void _showAddTaskModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTaskModal(
          onTaskAdded: (newTask) {
            setState(() {
              TaskManager.addTask(newTask); // Add task to TaskManager
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('MMMM d, yyyy');
    final formattedDate = dateFormat.format(now);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 15),
              AppBar(
                toolbarHeight: 100,
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                elevation: 0,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/utilisateur.png'),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hi, Akram',
                            style: TextStyle(
                              height: 1.2,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Good Morning!',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              height: 1.2,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Text(
                      'My tasks',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        height: 1.1,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$formattedDate Today',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        height: 1.1,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 20),
                    SingleChildScrollView(
                      physics:
                          NeverScrollableScrollPhysics(), // Disable vertical scrolling
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 10, 16),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: _onDaySelected,
                        calendarFormat: _calendarFormat,
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        availableCalendarFormats: const {
                          CalendarFormat.week: 'Week', // Only allow month view
                        },
                        headerVisible: false,
                        daysOfWeekHeight: 40,
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          weekendStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          defaultDecoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          todayTextStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          todayDecoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF074361), Color(0xFF0E81BB)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          selectedTextStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          weekendDecoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          outsideDecoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          markersMaxCount: 1,
                          isTodayHighlighted: true,
                          cellMargin: EdgeInsets.all(0),
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            return Container(
                              margin: EdgeInsets.all(2.5),
                              width: 49.0,
                              height:
                                  67.0, // Margin to create space between tiles
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                day.day.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            );
                          },
                          todayBuilder: (context, day, focusedDay) {
                            return Container(
                              margin: EdgeInsets.all(2.5),
                              width: 49.0,
                              height:
                                  67.0, // Margin to create space between tiles
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Color(0xFF074361), width: 5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                day.day.toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                          selectedBuilder: (context, day, focusedDay) {
                            return Container(
                              margin: EdgeInsets.all(2.5),
                              width: 49.0,
                              height:
                                  67.0, // Margin to create space between tiles
                              alignment: Alignment.center,

                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF074361),
                                    Color(0xFF0E81BB)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                day.day.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            );
                          },
                          outsideBuilder: (context, day, focusedDay) {
                            return Container(
                              alignment: Alignment.center,
                              width: 49.0,
                              height: 67.0,
                              margin: EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1),
                              ),
                              child: Text(
                                day.day.toString(),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 30),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 17),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFC3C0C0),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Container(
                          width: 53,
                          height: 5,
                        ),
                      ),
                    ),
                    // Display tasks

                    Column(
                      children:
                          TaskManager.getTasks(), // Call getTasks directly
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => showAddTaskModal(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27.5),
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
            width: 55,
            height: 55,
            padding: EdgeInsets.all(18.5),
            child: Container(
              width: 31,
              height: 31,
              child: SizedBox(
                width: 18.1,
                height: 18.1,
                child: SvgPicture.asset(
                  'assets/vectors/vector_7_x2.svg',
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
