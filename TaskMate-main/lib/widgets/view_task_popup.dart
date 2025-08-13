import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmate/cubit/tasks_cubit.dart';
import 'package:taskmate/cubit/auth_cubit.dart';
import 'package:taskmate/models/task_model.dart';
// Import the utility file for getTasks

class ViewTasksPopup extends StatefulWidget {
  final VoidCallback onAddTask;

  const ViewTasksPopup({super.key, required this.onAddTask});

  @override
  _ViewTasksPopupState createState() => _ViewTasksPopupState();
}

class _ViewTasksPopupState extends State<ViewTasksPopup> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // Format the current date
    String formattedDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 1.0,
      builder: (BuildContext context, ScrollController scrollController) {
        return Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Container(
              width: screenWidth,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.04),
                  topRight: Radius.circular(screenWidth * 0.04),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: screenWidth * 0.1,
                      height: screenHeight * 0.005,
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius:
                            BorderRadius.circular(screenWidth * 0.005),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star,
                          color: Colors.amber, size: screenWidth * 0.075),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: screenWidth * 0.067,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Divider(thickness: 1),
                  SizedBox(height: screenHeight * 0.01),
                  // Category filter buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCategoryButton('All', screenWidth, screenHeight),
                      _buildCategoryButton(
                          'Completed', screenWidth, screenHeight),
                      _buildCategoryButton(
                          'Pending', screenWidth, screenHeight),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Tasks list
                  Expanded(
                    child: BlocBuilder<TasksCubit, TasksState>(
                      builder: (context, state) {
                        if (state is TasksLoading) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is TasksLoaded) {
                          List<TaskModel> filteredTasks =
                              state.tasks.where((task) {
                            if (_selectedCategory == 'All') return true;
                            if (_selectedCategory == 'Completed') {
                              return task.status == 'completed';
                            }
                            if (_selectedCategory == 'Pending') {
                              return task.status == 'pending';
                            }
                            return true;
                          }).toList();

                          if (filteredTasks.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.task_alt,
                                    size: screenWidth * 0.15,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Text(
                                    'No tasks found',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Text(
                                    'Add a new task to get started',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: scrollController,
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return Container(
                                margin: EdgeInsets.only(
                                    bottom: screenHeight * 0.015),
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(
                                      screenWidth * 0.025),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: task.status == 'completed',
                                      onChanged: (value) {
                                        final authState =
                                            context.read<AuthCubit>().state;
                                        if (authState is AuthLoggedIn) {
                                          final newStatus = value == true
                                              ? 'completed'
                                              : 'pending';
                                          context
                                              .read<TasksCubit>()
                                              .updateTaskStatus(
                                                taskId: task.id,
                                                status: newStatus,
                                                token: authState.user.token,
                                              );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text('Task status updated'),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.name,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.bold,
                                              decoration: task.status ==
                                                      'completed'
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                          if (task.description.isNotEmpty)
                                            Text(
                                              task.description,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                color: Colors.grey[600],
                                                decoration: task.status ==
                                                        'completed'
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          SizedBox(
                                              height: screenHeight * 0.005),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: screenWidth * 0.04,
                                                color: Colors.grey[600],
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.01),
                                              Text(
                                                '${DateFormat('yyyy-MM-dd').format(task.dueAt)} ${DateFormat('HH:mm').format(task.dueAt)}',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.035,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                              height: screenHeight * 0.005),
                                          // Status indicator
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  _getStatusColor(task.status)
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: _getStatusColor(
                                                      task.status),
                                                  width: 1),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _getStatusIcon(task.status),
                                                  size: 12,
                                                  color: _getStatusColor(
                                                      task.status),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  _getStatusText(task.status),
                                                  style: TextStyle(
                                                    fontFamily: 'Roboto',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 10,
                                                    color: _getStatusColor(
                                                        task.status),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(
                            child: Text('No tasks available'),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    width: screenWidth * 0.55,
                    height: screenHeight * 0.06,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF073F5C), Color(0xFF0F85C2)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.075),
                    ),
                    child: TextButton(
                      onPressed: widget.onAddTask,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        foregroundColor: Color(0xFFFFF0B6),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.075),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Add task',
                          style: TextStyle(
                              fontSize: screenWidth * 0.057,
                              fontFamily: 'Roboto'),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryButton(
      String category, double screenWidth, double screenHeight) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.01,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF073F5C) : Colors.grey[200],
          borderRadius: BorderRadius.circular(screenWidth * 0.025),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'in_progress':
        return Icons.play_circle_outline;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
