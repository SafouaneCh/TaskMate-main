import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'contact_management_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import '../widgets/custom_bottom_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/add_new_task_cubit.dart';
import '../cubit/tasks_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/add_task_popup.dart';
import '../widgets/ai_task_popup.dart';
import '../widgets/task_card.dart';
import '../widgets/task_detail_popup.dart';
import '../widgets/edit_task_popup.dart';
import '../models/task_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Fetch tasks when screen loads
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
        return BlocProvider<AddNewTaskCubit>(
          create: (context) => AddNewTaskCubit(),
          child: AddTaskModal(
            onTaskAdded: (newTask) {
              // Refresh tasks after adding a new one
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthLoggedIn) {
                context.read<TasksCubit>().refreshTasks(
                      token: authState.user.token,
                      userId: authState.user.id,
                      date: _selectedDay,
                    );
              }
            },
          ),
        );
      },
    );
  }

  void _showAITaskModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider<AddNewTaskCubit>(
          create: (context) => AddNewTaskCubit(),
          child: AITaskModal(
            onTaskAdded: (newTask) {
              // Refresh tasks immediately and then close modal
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthLoggedIn) {
                // Refresh tasks for the currently selected date
                context.read<TasksCubit>().refreshTasks(
                      token: authState.user.token,
                      userId: authState.user.id,
                      date: _selectedDay,
                    );
              }
            },
            selectedDate: _selectedDay,
          ),
        );
      },
    );
  }

  void _showTaskCreationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create New Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF073F5C),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddTaskModal(context);
                      },
                      icon: Icon(Icons.add_task, color: Colors.white),
                      label: Text(
                        'Regular Task',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF073F5C),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAITaskModal(context);
                      },
                      icon: Icon(Icons.auto_awesome, color: Colors.white),
                      label: Text(
                        'AI Task',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0E81BD),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    return TaskCard(
      time: DateFormat('HH:mm').format(task.dueAt),
      description: task.description,
      priority: task.priority,
      isCompleted: task.status == 'completed',
      name: task.name,
      date: DateFormat('yyyy-MM-dd').format(task.dueAt),
      contacts: task.contact.isNotEmpty ? task.contact.split(',') : [],
      status: task.status,
      onTap: () => _showTaskDetailModal(context, task),
      onStatusChanged: (newStatus) =>
          _updateTaskStatus(context, task, newStatus),
    );
  }

  void _updateTaskStatus(
      BuildContext context, TaskModel task, String newStatus) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthLoggedIn) {
      context.read<TasksCubit>().updateTaskStatus(
            taskId: task.id,
            status: newStatus,
            token: authState.user.token,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Task status updated to ${newStatus.replaceAll('_', ' ')}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication error')),
      );
    }
  }

  void _showTaskDetailModal(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskDetailPopup(
          task: task,
          filterDate: _selectedDay,
          onEdit: () {
            Navigator.of(context).pop();
            _showEditTaskModal(context, task);
          },
          onDelete: () {
            Navigator.of(context).pop();
            _deleteTask(context, task);
          },
        );
      },
    );
  }

  void _showEditTaskModal(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTaskModal(
          task: task,
          filterDate: _selectedDay,
          onTaskUpdated: () {
            // Tasks are now automatically updated in the state
            // No need to manually refresh
          },
        );
      },
    );
  }

  void _deleteTask(BuildContext context, TaskModel task) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthLoggedIn) {
      context.read<TasksCubit>().deleteTask(
            taskId: task.id,
            token: authState.user.token,
          );
      // Refresh tasks for the current selected date after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task deleted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication error')),
      );
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
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
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    final now = DateTime.now();
    final dateFormat = DateFormat('MMMM d, yyyy');
    final formattedDate = dateFormat.format(now);

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
                AppBar(
                  toolbarHeight: screenHeight * 0.12,
                  backgroundColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  flexibleSpace: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.02),
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, authState) {
                        String userName = 'User';
                        if (authState is AuthLoggedIn) {
                          userName = authState.user.name;
                        }

                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SettingsScreen(),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: screenWidth * 0.075,
                                backgroundImage:
                                    AssetImage('assets/utilisateur.png'),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.025),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Hi, $userName',
                                    style: TextStyle(
                                      height: 1.2,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _getGreeting(),
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: screenWidth * 0.04,
                                      height: 1.2,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    children: [
                      Text(
                        'My tasks',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          height: 1.1,
                          fontSize: screenWidth * 0.075,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMMM d, yyyy').format(_selectedDay),
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          height: 1.1,
                          fontSize: screenWidth * 0.04,
                          color: Color(0xFF666666),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _selectedDay,
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
                            setState(() {
                              _selectedDay = focusedDay;
                            });
                          },
                          availableCalendarFormats: const {
                            CalendarFormat.week: 'Week',
                          },
                          headerVisible: false,
                          daysOfWeekHeight: screenHeight * 0.05,
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.04,
                            ),
                            weekendStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.04,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                          ),
                          headerStyle: HeaderStyle(
                            titleTextStyle: TextStyle(
                              fontSize: screenWidth * 0.04,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                          ),
                          calendarStyle: CalendarStyle(
                            defaultTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.04,
                            ),
                            defaultDecoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.025),
                            ),
                            todayTextStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.04,
                            ),
                            todayDecoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF074361), Color(0xFF0E81BB)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.025),
                            ),
                            selectedTextStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Color(0xFF073F5C),
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.025),
                            ),
                            weekendDecoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.025),
                            ),
                            outsideDecoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.025),
                            ),
                            markersMaxCount: 1,
                            isTodayHighlighted: true,
                            cellMargin: EdgeInsets.all(0),
                          ),
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              return Container(
                                margin: EdgeInsets.all(screenWidth * 0.006),
                                width: screenWidth * 0.12,
                                height: screenHeight * 0.08,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      screenWidth * 0.025),
                                ),
                                child: Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.045,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              );
                            },
                            todayBuilder: (context, day, focusedDay) {
                              return Container(
                                margin: EdgeInsets.all(screenWidth * 0.006),
                                width: screenWidth * 0.12,
                                height: screenHeight * 0.08,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Color(0xFF074361),
                                      width: screenWidth * 0.012),
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.04),
                                ),
                                child: Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                            selectedBuilder: (context, day, focusedDay) {
                              return Container(
                                margin: EdgeInsets.all(screenWidth * 0.006),
                                width: screenWidth * 0.12,
                                height: screenHeight * 0.08,
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
                                  borderRadius: BorderRadius.circular(
                                      screenWidth * 0.025),
                                ),
                                child: Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.045,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              );
                            },
                            outsideBuilder: (context, day, focusedDay) {
                              return Container(
                                alignment: Alignment.center,
                                width: screenWidth * 0.12,
                                height: screenHeight * 0.08,
                                margin: EdgeInsets.all(screenWidth * 0.006),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      screenWidth * 0.025),
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1),
                                ),
                                child: Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w700,
                                    fontSize: screenWidth * 0.045,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),
                      Container(
                        margin:
                            EdgeInsets.fromLTRB(0, 0, 0, screenHeight * 0.02),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFC3C0C0),
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.012),
                          ),
                          child: SizedBox(
                            width: screenWidth * 0.13,
                            height: screenHeight * 0.006,
                          ),
                        ),
                      ),
                      // Display tasks using BlocBuilder
                      BlocBuilder<TasksCubit, TasksState>(
                        builder: (context, state) {
                          if (state is TasksLoading) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(screenHeight * 0.02),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (state is TasksLoaded) {
                            if (state.tasks.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(screenHeight * 0.02),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.task_alt,
                                        size: screenWidth * 0.15,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: screenHeight * 0.02),
                                      Text(
                                        'No tasks yet',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.05,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Text(
                                        'Add your first task using the + button',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Column(
                                children: state.tasks
                                    .map((task) => _buildTaskCard(task))
                                    .toList(),
                              );
                            }
                          } else if (state is TasksError) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(screenHeight * 0.02),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: screenWidth * 0.15,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    Text(
                                      'Failed to load tasks',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.05,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Text(
                                      state.error,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    ElevatedButton(
                                      onPressed: () {
                                        final authState =
                                            context.read<AuthCubit>().state;
                                        if (authState is AuthLoggedIn) {
                                          context
                                              .read<TasksCubit>()
                                              .refreshTasks(
                                                token: authState.user.token,
                                                userId: authState.user.id,
                                                date: _selectedDay,
                                              );
                                        }
                                      },
                                      child: Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            // TasksInitial state - show empty state
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(screenHeight * 0.02),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.task_alt,
                                      size: screenWidth * 0.15,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    Text(
                                      'No tasks yet',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.05,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Text(
                                      'Add your first task using the + button',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => _showTaskCreationMenu(context),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
