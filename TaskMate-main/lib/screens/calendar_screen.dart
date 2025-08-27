import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/screens/settings_screen.dart';
import 'package:taskmate/cubit/tasks_cubit.dart';
import 'package:taskmate/cubit/auth_cubit.dart';
import 'package:taskmate/cubit/add_new_task_cubit.dart';
import 'contact_management_screen.dart';
import 'home_screen.dart' as home;
import '../widgets/add_task_popup.dart';
import '../widgets/view_task_popup.dart'; // Importez la nouvelle popup
import '../widgets/custom_bottom_bar.dart';
import '../widgets/task_card.dart';
// Added import for TaskDetailPopup

void showViewTasksPopup(
    BuildContext context, DateTime? selectedDate, VoidCallback onAddTask) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return BlocProvider.value(
        value: context.read<TasksCubit>(),
        child: ViewTasksPopup(
          onAddTask: onAddTask,
          selectedDate: selectedDate, // Pass the selected date
        ),
      );
    },
  );
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedIndex = 1;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    // Fetch tasks for today when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthLoggedIn) {
        context.read<TasksCubit>().fetchTasks(
              token: authState.user.token,
              userId: authState.user.id,
              date: _selectedDay,
            );
      }
    });
  }

  void _showAddTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return BlocProvider<AddNewTaskCubit>(
          create: (context) => AddNewTaskCubit(),
          child: AddTaskModal(
            onTaskAdded: (TaskCard newTask) {
              // Refresh tasks for the selected date after adding a new one
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthLoggedIn) {
                context.read<TasksCubit>().refreshTasks(
                      token: authState.user.token,
                      userId: authState.user.id,
                      date: _selectedDay,
                    );
              }
            },
            selectedDate: _selectedDay, // Pass the selected date
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => home.HomeScreen()),
        );
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

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    // Fetch tasks for the selected date
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthLoggedIn) {
      context.read<TasksCubit>().fetchTasks(
            token: authState.user.token,
            userId: authState.user.id,
            date: selectedDay,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.8),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Column(
            children: [
              SizedBox(height: 15),
              // AppBar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Text(
                  'Calendar',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      // Custom days of the week
                      // Your custom days of the week widget
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: _onDaySelected,
                          onFormatChanged: (format) {
                            if (_calendarFormat != format) {
                              setState(() {
                                _calendarFormat = format;
                              });
                            }
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                          availableCalendarFormats: const {
                            CalendarFormat.month:
                                'Month', // Only allow month view
                          },
                          daysOfWeekHeight: 40,
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              return Container(
                                alignment: Alignment.center,
                                width: 49.0,
                                height: 67.0,
                                margin: EdgeInsets.only(bottom: 12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1),
                                ),
                                child: Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      fontFamily: 'Roboto'),
                                ),
                              );
                            },
                            todayBuilder: (context, day, focusedDay) {
                              return Container(
                                alignment: Alignment.center,
                                width: 49.0,
                                height: 64.0,
                                margin: EdgeInsets.only(bottom: 12.0),
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
                            outsideBuilder: (context, day, focusedDay) {
                              return Container(
                                alignment: Alignment.center,
                                width: 49.0,
                                height: 67.0,
                                margin: EdgeInsets.only(bottom: 12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1),
                                ),
                                child: Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      fontFamily: 'Roboto'),
                                ),
                              );
                            },
                            selectedBuilder: (context, day, focusedDay) {
                              return Container(
                                alignment: Alignment.center,
                                width: 49.0,
                                height: 67.0,
                                margin: EdgeInsets.only(bottom: 12.0),
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
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            leftChevronVisible: true,
                            rightChevronVisible: true,
                            titleTextStyle: TextStyle(
                              fontSize: 32, // Custom font size
                              fontFamily: 'Roboto', // Custom font family
                              fontWeight: FontWeight.bold, // Custom font weight
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF074361),
                                    Color(0xFF0E81BB)
                                  ],
                                ).createShader(Rect.fromLTWH(
                                    0.0, 0.0, 200.0, 70.0)), // Gradient effect
                            ),
                            leftChevronIcon: Icon(
                              Icons.chevron_left,
                              size: 32,
                              color: Colors.blue.shade900,
                            ),
                            rightChevronIcon: Icon(
                              Icons.chevron_right,
                              size: 32,
                              color: Colors.blue.shade900,
                            ),
                            headerPadding: EdgeInsets.only(bottom: 30),
                          ),
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
                            cellMargin: EdgeInsets.all(10),
                          ),
                          rowHeight: 70.0,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Selected date display
                      if (_selectedDay != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            'Tasks for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF074361),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],

                      Container(
                        width: 220,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF073F5C), Color(0xFF0F85C2)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextButton(
                          onPressed: () {
                            showViewTasksPopup(context, _selectedDay, () {
                              _showAddTaskModal(context);
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            foregroundColor: Color(0xFFFFF0B6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'View tasks',
                              style:
                                  TextStyle(fontSize: 23, fontFamily: 'Roboto'),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
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
            child: SizedBox(
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
